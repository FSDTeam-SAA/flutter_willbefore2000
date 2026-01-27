import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutx_core/flutx_core.dart';
import 'package:go_router/go_router.dart';
import 'package:country_picker/country_picker.dart';
import 'package:smilestreats/core/constants/app_colors.dart';
import 'package:smilestreats/core/routes/route_endpoint.dart';
import 'package:smilestreats/core/utils/extensions/button_extensions.dart';
import 'package:smilestreats/feature/auth/presentation/providers/auth_provider.dart';
import '../../../../core/constants/app_icons_const.dart';
import '../../../../core/services/shipo_service.dart';
import '../../../../core/services/stripe_service.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../order/domain/entities/order_entities.dart';
import '../../../order/presentation/providers/order_provider.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../providers/checkout_form_proivder.dart';
import '../../../../core/services/geo_service.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final CartItem? buyNowItem;
  const CheckoutScreen({super.key, this.buyNowItem});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  // TextEditingControllers for each field
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  String _selectedCountryCode = '+1'; // Default to US country code
  bool _isLoading = false;

  final GeoService _geoService = GeoService();
  List<String> _cities = [];
  bool _isLoadingStates = false;
  bool _isLoadingCities = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill form with user data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillFormWithUserData();
    });
  }

  void _prefillFormWithUserData() {
    final user = ref.read(authProvider).user;
    if (user != null) {
      // Split display name into first and last name
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        final nameParts = user.displayName!.split(' ');
        if (nameParts.length >= 2) {
          _firstNameController.text = nameParts[0];
          _lastNameController.text = nameParts.sublist(1).join(' ');
        } else {
          _firstNameController.text = user.displayName!;
        }
      }

      // Fill email if available
      if (user.email != null && user.email!.isNotEmpty) {
        _emailController.text = user.email!;
      }

      // Fill phone number if available
      if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
        _phoneNumberController.text = user.phoneNumber!;
      }

      // Fill address information if available
      if (user.streetAddress != null && user.streetAddress!.isNotEmpty) {
        _addressController.text = user.streetAddress!;
      }

      if (user.city != null && user.city!.isNotEmpty) {
        _cityController.text = user.city!;
      }

      if (user.state != null && user.state!.isNotEmpty) {
        _stateController.text = user.state!;
      }

      if (user.zipCode != null && user.zipCode!.isNotEmpty) {
        _zipCodeController.text = user.zipCode!;
      }

      // Set default country to United States if user doesn't have country data
      _countryController.text = 'United States';

      // Update the form provider with initial values
      final formNotifier = ref.read(checkoutFormProvider.notifier);
      formNotifier.updateField('firstName', _firstNameController.text);
      formNotifier.updateField('lastName', _lastNameController.text);
      formNotifier.updateField('email', _emailController.text);
      formNotifier.updateField('phoneNumber', _phoneNumberController.text);
      formNotifier.updateField('address', _addressController.text);
      formNotifier.updateField('city', _cityController.text);
      formNotifier.updateField('state', _stateController.text);
      formNotifier.updateField('zipCode', _zipCodeController.text);
      formNotifier.updateField('country', _countryController.text);

      // Fetch cities if country is already pre-filled (new flow: Country -> City)
      if (_countryController.text.isNotEmpty) {
        _fetchAllCities(_countryController.text);
      }
    }
  }

  Future<void> _fetchAllCities(String countryName) async {
    setState(() {
      _isLoadingCities = true;
      _cities = [];
    });
    final cities = await _geoService.getAllCities(countryName);
    if (mounted) {
      setState(() {
        _cities = cities;
        _isLoadingCities = false;
      });
    }
  }

  Future<void> _findStateForCity(String countryName, String cityName) async {
    setState(() {
      _isLoadingStates = true;
    });

    // Fetch all states for the country
    final states = await _geoService.getStates(countryName);

    // Check each state to find which one contains this city
    for (final state in states) {
      final citiesInState = await _geoService.getCities(countryName, state);
      if (citiesInState.any((c) => c.toLowerCase() == cityName.toLowerCase())) {
        if (mounted) {
          setState(() {
            _stateController.text = state;
            _isLoadingStates = false;
          });
          _updateFormField('state', state);
        }
        return;
      }
    }

    // If no state found, clear the loading state
    if (mounted) {
      setState(() {
        _isLoadingStates = false;
      });
    }
  }

  void _showCountryPicker(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: true, // Show phone codes
      countryListTheme: CountryListThemeData(
        flagSize: 25,
        backgroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16, color: Colors.blueGrey),
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.7,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        inputDecoration: InputDecoration(
          labelText: 'Search',
          hintText: 'Start typing to search',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xFF8C98A8).withOpacity(0.2),
            ),
          ),
        ),
      ),
      onSelect: (Country country) {
        setState(() {
          _countryController.text = country.name;
          _selectedCountryCode = '+${country.phoneCode}';
          // Reset dependent fields
          _stateController.clear();
          _cityController.clear();
          _cities = [];
        });
        _updateFormField('country', country.name);
        _updateFormField('state', '');
        _updateFormField('city', '');
        _fetchAllCities(country.name);
      },
    );
  }

  void _showCityPicker() {
    if (_countryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a country first')),
      );
      return;
    }

    if (_isLoadingCities) return;

    if (_cities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No cities found for this country')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _buildSearchableList(
          title: 'Select City',
          items: _cities,
          onSelect: (city) {
            setState(() {
              _cityController.text = city;
            });
            _updateFormField('city', city);
            // Auto-detect state based on selected city
            _findStateForCity(_countryController.text, city);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget _buildSearchableList({
    required String title,
    required List<String> items,
    required Function(String) onSelect,
  }) {
    List<String> filteredItems = List.from(items);
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  setModalState(() {
                    filteredItems = items
                        .where(
                          (item) =>
                              item.toLowerCase().contains(value.toLowerCase()),
                        )
                        .toList();
                  });
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(filteredItems[index]),
                      onTap: () => onSelect(filteredItems[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // Dispose all controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _updateFormField(String field, String value) {
    ref.read(checkoutFormProvider.notifier).updateField(field, value);
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final formState = ref.watch(checkoutFormProvider);
    final user = ref.watch(authProvider).user;

    final checkoutItems = widget.buyNowItem != null
        ? [widget.buyNowItem!]
        : cartState.items;
    final double total = widget.buyNowItem != null
        ? widget.buyNowItem!.totalPrice
        : cartState.total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: cartState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartState.errorMessage != null
          ? Center(child: Text('Error: ${cartState.errorMessage}'))
          : checkoutItems.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // User info banner
                  if (user != null) _buildUserInfoBanner(user),
                  _buildShippingSection(ref, formState, context),
                  const SizedBox(height: 24),
                  _buildPaymentSection(),
                  const SizedBox(height: 32),
                  _buildContinueButton(ref, checkoutItems, total, formState),
                  if (_isLoading) ...[
                    const SizedBox(height: 12),
                    Text(
                      _loadingMessage,
                      style: const TextStyle(
                        color: AppColors.primaryLaurel,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildUserInfoBanner(UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryLaurel.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryLaurel.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.person_outline, color: AppColors.primaryLaurel, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shipping to your account',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryLaurel,
                  ),
                ),
                if (user.displayName != null && user.displayName!.isNotEmpty)
                  Text(
                    user.displayName!,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingSection(
    WidgetRef ref,
    CheckoutFormState formState,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shipping Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryLaurel,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _firstNameController,
                  field: 'firstName',
                  label: 'First Name',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _lastNameController,
                  field: 'lastName',
                  label: 'Last Name',
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Email and Phone Stacked
          _buildTextField(
            controller: _emailController,
            field: 'email',
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text(
                    'Phone Number',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.iconDeselectedColor,
                    ),
                  ),
                  Text(
                    ' *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      showCountryPicker(
                        context: context,
                        showPhoneCode: true,
                        onSelect: (Country country) {
                          setState(() {
                            _selectedCountryCode = '+${country.phoneCode}';
                          });
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.iconDeselectedColor,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _selectedCountryCode,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                      onChanged: (value) {
                        _updateFormField('phoneNumber', value);
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            color: AppColors.iconDeselectedColor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                            color: AppColors.iconDeselectedColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                            color: AppColors.iconDeselectedColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Country moved before Address
          const Text(
            'Country',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showCountryPicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _countryController.text.isEmpty
                          ? 'Select Country'
                          : _countryController.text,
                      style: TextStyle(
                        color: _countryController.text.isEmpty
                            ? Colors.grey
                            : Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _addressController,
            field: 'address',
            label: 'Address',
            isRequired: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCascadingPicker(
                  label: 'City',
                  controller: _cityController,
                  onTap: _showCityPicker,
                  isLoading: _isLoadingCities,
                  enabled: _countryController.text.isNotEmpty,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildReadOnlyField(
                  label: 'State',
                  controller: _stateController,
                  isLoading: _isLoadingStates,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _zipCodeController,
                  field: 'zipCode',
                  label: 'ZIP Code',
                  isRequired: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pay',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Radio<String>(
                  value: 'stripe',
                  groupValue: 'stripe',
                  onChanged: (value) {},
                  activeColor: Colors.blue,
                ),
                const Text(
                  'Pay With Stripe',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),
                const Spacer(),
                Image.asset(AssetsPath.stripeLogo, height: 40, width: 40),
                Gap.w8,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCascadingPicker({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
    bool isLoading = false,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.iconDeselectedColor,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.iconDeselectedColor),
              borderRadius: BorderRadius.circular(4),
              color: enabled ? Colors.white : Colors.grey[100],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? 'Select $label' : controller.text,
                    style: TextStyle(
                      color: controller.text.isEmpty
                          ? Colors.grey
                          : Colors.black,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    Icons.arrow_drop_down,
                    color: Colors.grey[600],
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required TextEditingController controller,
    bool isLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.iconDeselectedColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.iconDeselectedColor),
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey[50],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  controller.text.isEmpty ? 'Auto-filled' : controller.text,
                  style: TextStyle(
                    color: controller.text.isEmpty ? Colors.grey : Colors.black,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (controller.text.isNotEmpty)
                Icon(Icons.check_circle, color: Colors.green[600], size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String field,
    required String label,
    TextInputType? keyboardType,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.iconDeselectedColor,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.red,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: (value) {
            _updateFormField(field, value);
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: AppColors.iconDeselectedColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: AppColors.iconDeselectedColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(
                color: AppColors.iconDeselectedColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(
    WidgetRef ref,
    List<CartItem> cartItems,
    double total,
    CheckoutFormState formState,
  ) {
    return SizedBox(
      width: 181,
      child: ref.context.primaryButton(
        isLoading: _isLoading,
        onPressed: () {
          if (formState.isValid) {
            _processPayment(ref, cartItems, total, formState);
          } else {
            ScaffoldMessenger.of(ref.context).showSnackBar(
              const SnackBar(
                content: Text('Please fill all required fields'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        text: 'Continue to Payment',
      ),
    );
  }

  String _loadingMessage = 'Continue to Payment';

  Future<void> _processPayment(
    WidgetRef ref,
    List<CartItem> cartItems,
    double total,
    CheckoutFormState formState,
  ) async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Verifying Address...';
    });
    try {
      DPrint.log('Step 1: Verifying Shipping Address with Shippo...');

      // Create Shippo address
      final shippoService = ShippoService();

      // Format phone number with selected country code
      String phoneInput = formState.phoneNumber.trim();
      String formattedPhone;
      if (phoneInput.startsWith('+')) {
        formattedPhone = phoneInput; // User entered full international number
      } else {
        // Prepend selected country code
        formattedPhone = '$_selectedCountryCode$phoneInput';
      }
      // Remove any non-numeric characters (except +)
      formattedPhone = formattedPhone.replaceAll(RegExp(r'[^0-9+]'), '');

      final addressResult = await shippoService.createAddress(
        name: '${formState.firstName} ${formState.lastName}',
        street1: formState.address,
        city: formState.city,
        state: formState.state,
        zip: formState.zipCode,
        country: _getCountryCode(formState.country),
        phone: formattedPhone,
        email: formState.email,
        isResidential: true,
        metadata: 'Customer Order',
      );

      DPrint.log('Shippo address creation result: $addressResult');

      if (addressResult == null) {
        throw Exception(
          'Failed to connect to shipping service. Please check your internet connection.',
        );
      }

      // Check for explicit API errors (like 400 Bad Request results provided by Shippo)
      if (addressResult['__all__'] != null ||
          addressResult['status'] == 'error') {
        String apiError = 'Validation Error';
        if (addressResult['__all__'] != null &&
            (addressResult['__all__'] as List).isNotEmpty) {
          apiError = (addressResult['__all__'] as List).join('\n');
        } else if (addressResult['message'] != null) {
          apiError = addressResult['message'];
        }
        throw Exception(apiError);
      }

      // Check if address is valid. Shippo returns validation_results with messages.
      final bool isComplete = addressResult['is_complete'] ?? false;
      final validationResults = addressResult['validation_results'];

      // If validation_results is empty (null or {}), it means validation is not available for this country.
      // In this case, we trust is_complete.
      final bool hasValidationResult =
          validationResults != null && validationResults.isNotEmpty;
      final bool isValid =
          !hasValidationResult || (validationResults['is_valid'] ?? false);
      final List<dynamic> messages = validationResults?['messages'] ?? [];

      // Also check root level messages for errors
      final List<dynamic> rootMessages = addressResult['messages'] ?? [];
      final bool hasErrorInMessages =
          messages.any(
            (m) => m['code'] == 'user_input_problem' || m['source'] == 'error',
          ) ||
          rootMessages.any(
            (m) => m['code'] == 'user_input_problem' || m['source'] == 'error',
          );

      if ((hasValidationResult && !isValid) ||
          !isComplete ||
          hasErrorInMessages) {
        String errorMessage = 'Invalid shipping address.';
        if (messages.isNotEmpty) {
          errorMessage = messages
              .map((m) => m['text']?.toString() ?? 'Unknown error')
              .join('\n');
        } else if (rootMessages.isNotEmpty) {
          errorMessage = rootMessages
              .map((m) => m['text']?.toString() ?? 'Unknown error')
              .join('\n');
        }
        throw Exception(errorMessage);
      }

      DPrint.log('Step 2: Address Verified. Proceeding to Stripe Payment...');
      setState(() {
        _loadingMessage = 'Processing Payment...';
      });

      // Process payment with Stripe
      final paymentResult = await StripeService.processPayment(
        amount: total,
        currency: 'usd',
        metadata: {
          'customer_email': formState.email,
          'order_items': cartItems.length.toString(),
          'shippo_address_id': addressResult['object_id'],
        },
      );

      if (!paymentResult['success']) {
        throw Exception(paymentResult['error'] ?? 'Payment failed');
      }

      final String realPaymentIntentId = paymentResult['paymentIntentId'];

      DPrint.log(
        "Payment processed successfully. PaymentIntent ID: $realPaymentIntentId",
      );

      DPrint.log('Step 3: Creating Order in Database...');
      setState(() {
        _loadingMessage = 'Finalizing Order...';
      });

      // Create shipping address entity
      final shippingAddress = ShippingAddress(
        firstName: formState.firstName,
        lastName: formState.lastName,
        email: formState.email,
        phoneNumber: formattedPhone,
        address: formState.address,
        city: formState.city,
        state: formState.state,
        zipCode: formState.zipCode,
        country: formState.country,
      );

      // Create order with Shippo address ID
      final order = await ref
          .read(orderProvider.notifier)
          .createOrder(
            items: cartItems,
            shippingAddress: shippingAddress,
            paymentIntentId: realPaymentIntentId,
            metadata: {'shippo_address_id': addressResult['object_id']},
          );

      // Clear cart ONLY if NOT a "Buy Now" order
      if (widget.buyNowItem == null) {
        await ref.read(cartProvider.notifier).clearCart();
      }
      ref.read(checkoutFormProvider.notifier).reset();

      // Navigate to success page
      if (ref.context.mounted) {
        GoRouter.of(ref.context).go(RoutePaths.orderConfirm, extra: order);
      }
    } catch (e) {
      DPrint.error('Checkout Error: $e');
      if (ref.context.mounted) {
        showDialog(
          context: ref.context,
          builder: (context) => AlertDialog(
            title: const Text('Checkout Error'),
            content: Text(e.toString().replaceAll('Exception: ', '')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMessage = 'Continue to Payment';
        });
      }
    }
  }

  String _getCountryCode(String countryName) {
    try {
      final country = Country.tryParse(countryName);
      return country?.countryCode ?? 'US';
    } catch (e) {
      return 'US'; // Default fallback
    }
  }

  String _formatPhoneNumber(String phone, String countryName) {
    // Remove all non-numeric characters except +
    String cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');

    // Handle specific cases like "00" prefix for international calls
    if (cleaned.startsWith('00')) {
      cleaned = '+' + cleaned.substring(2);
    }

    // If it doesn't start with + and we have a country code, we could try to prepend it.
    // For many carriers, + is essential for international shipments.
    // But since the user might have already typed it, we just clean it.

    return cleaned;
  }
}
