import 'package:flutter_riverpod/flutter_riverpod.dart';

class CheckoutFormState {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final bool isValid;

  const CheckoutFormState({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phoneNumber = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.zipCode = '',
    this.country = 'United States',
    this.isValid = false,
  });

  CheckoutFormState copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    bool? isValid,
  }) {
    return CheckoutFormState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      isValid: isValid ?? this.isValid,
    );
  }

  bool get _isFormValid {
    return firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        email.isNotEmpty &&
        email.contains('@') &&
        phoneNumber.isNotEmpty &&
        address.isNotEmpty &&
        city.isNotEmpty &&
        state.isNotEmpty &&
        zipCode.isNotEmpty;
  }
}

class CheckoutFormNotifier extends StateNotifier<CheckoutFormState> {
  CheckoutFormNotifier() : super(const CheckoutFormState());

  void updateField(String field, String value) {
    switch (field) {
      case 'firstName':
        state = state.copyWith(firstName: value);
        break;
      case 'lastName':
        state = state.copyWith(lastName: value);
        break;
      case 'email':
        state = state.copyWith(email: value);
        break;
      case 'phoneNumber':
        state = state.copyWith(phoneNumber: value);
        break;
      case 'address':
        state = state.copyWith(address: value);
        break;
      case 'city':
        state = state.copyWith(city: value);
        break;
      case 'state':
        state = state.copyWith(state: value);
        break;
      case 'zipCode':
        state = state.copyWith(zipCode: value);
        break;
      case 'country':
        state = state.copyWith(country: value);
        break;
    }
    // Update validation status
    state = state.copyWith(isValid: state._isFormValid);
  }

  void reset() {
    state = const CheckoutFormState();
  }
}

final checkoutFormProvider = StateNotifierProvider<CheckoutFormNotifier, CheckoutFormState>(
  (ref) => CheckoutFormNotifier(),
);
