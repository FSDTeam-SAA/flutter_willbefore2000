import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:smilestreats/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  // This is your Privacy Policy converted from HTML → Markdown
  static const String privacyPolicyMarkdown = '''
# Privacy Policy for SmilesTreats App

**Effective Date:** November 22, 2025

Welcome to **SmilesTreats App** (“the App”, “we”, “our”, or “us”). This Privacy Policy explains how **LFM, LLC** (“Company”) collects, uses, and protects your information when you use the SmilesTreats App, available on the Apple App Store and Google Play Store.

By using the SmilesTreats App, you agree to the terms of this Privacy Policy.

---

## 1. Information We Collect

We collect information to operate effectively and enhance your experience.

### a. Personal Information
When you create an account or use the app, we may collect:  
- Name, email address, and contact details  
- Profile picture or images you choose to upload  
- Account credentials or login information  
- Purchase and order details

### b. Usage Data
We automatically collect certain technical and activity-related information, including:  
- Device details (model, OS version, unique identifiers)  
- IP address and general location (city-level only)  
- App activity (pages visited, features used, time spent in-app)

### c. Media and Uploaded Content
If you upload photos, profile images, or other media:  
- We only access files you explicitly choose to share.  
- Uploaded media is stored securely and used solely for in-app display and functionality.  
- We do not access your camera roll or files without permission.

---

## 2. How We Use Your Information

We use your information to:  
- Operate, maintain, and improve the SmilesTreats App  
- Process transactions and fulfill orders  
- Send important updates, push notifications, and promotional offers  
- Manage user accounts and customer support  
- Ensure security and prevent fraudulent or unauthorized activity

We may use non-identifiable information (e.g., usage stats) for analytics and app improvements.

---

## 3. Sharing of Information

We do **not** sell or rent your personal data.  
We may share limited data only with:  
- **Service providers** that assist with app hosting, analytics, payment processing, and notifications  
- **Legal authorities**, if required by law or to protect rights, property, or safety

All third parties are required to maintain strict confidentiality and comply with applicable privacy laws.

---

## 4. Data Retention

We retain your information as long as needed to provide services or comply with legal obligations.  
You may request account deletion and data removal at any time by contacting **support@lfmcorp.com**.

---

## 5. Security

We use industry-standard security measures, including encryption and secure server storage, to protect your data.  
While we take every reasonable precaution, no digital system is completely immune from breaches.

---

## 6. Your Rights

Depending on your region, you may have rights to:  
- Access or request a copy of your data  
- Request correction or deletion of personal information  
- Withdraw consent to marketing communications

To exercise these rights, please contact **support@lfmcorp.com**.

---

## 7. Children’s Privacy

The SmilesTreats App is intended for users **18 years of age or older**.  
We do not knowingly collect data from individuals under 18.  
If we become aware that we have inadvertently collected information from a minor, we will delete it immediately.

---

## 8. Third-Party Services and Links

The App may include links to third-party websites or services (e.g., payment gateways or social media platforms).  
We are not responsible for their privacy practices or content. We encourage you to review their policies before engaging with them.

---

## 9. Push Notifications

The App may send push notifications related to your account, purchases, or promotions.  
You can control notification preferences in your device or app settings at any time.

---

## 10. Updates to This Policy

We may update this Privacy Policy periodically. Any changes will be reflected with an updated “Effective Date” and made available within the app and on our website.

---

## 11. Contact Us

If you have questions or concerns about this Privacy Policy or our data practices, contact us at:

**LFM, LLC**  
📧 **support@lfmcorp.com**  
📱 SmilesTreats App
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Policy"), elevation: 0),
      body: SafeArea(
        child: Markdown(
          data: privacyPolicyMarkdown,
          selectable: true,
          styleSheet: MarkdownStyleSheet(
            h1: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            h2: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            p: const TextStyle(fontSize: 16, height: 1.6),
            listBullet: const TextStyle(fontSize: 16),
            blockquoteDecoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(
                left: BorderSide(color: Colors.pink.shade300, width: 4),
              ),
            ),
            blockquotePadding: const EdgeInsets.all(16),
            codeblockDecoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            a: TextStyle(color: AppColors.primaryLaurel),
          ),
          onTapLink: (text, href, title) async {
            if (href == null) return;

            final uri = Uri.tryParse(href);
            if (uri == null) return;

            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
        ),
      ),
    );
  }
}

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  static const String termsMarkdown = '''
# Terms and Conditions for SmilesTreats App

**Last Updated:** November 22, 2025

Welcome to **SmilesTreats** ("the App", "we", "us", or "our"), operated by **LFM, LLC** ("Company"). By downloading, accessing, or using the SmilesTreats mobile application, you agree to be bound by these Terms and Conditions ("Terms"). If you do not agree with any part of these Terms, you must not use the App.

---

## 1. Acceptance of Terms

These Terms constitute a legally binding agreement between you and LFM, LLC. We may update these Terms at any time. Continued use of the App after changes constitutes your acceptance of the updated Terms. The latest version will always be available within the App and on our website.

---

## 2. Eligibility

You must be at least **18 years old** or the age of majority in your jurisdiction to use the SmilesTreats App. By using the App, you represent and warrant that you meet this age requirement.

---

## 3. Account Registration

To access certain features, you must create an account. You agree to:
- Provide accurate, current, and complete information during registration
- Maintain the security of your password and account
- Notify us immediately of any unauthorized use of your account
- Accept responsibility for all activities that occur under your account

We reserve the right to suspend or terminate accounts that violate these Terms.

---

## 4. Purchases and Payments

- All purchases made through the App are final and non-refundable, except as required by applicable law.
- Prices are displayed in the App and may change without notice.
- You are responsible for all charges incurred, including applicable taxes.
- We use third-party payment processors (e.g., Apple App Store, Google Play) to handle transactions securely.

---

## 5. User Content

You retain ownership of any photos, text, or other content you upload ("User Content"). By uploading, you grant LFM, LLC a worldwide, royalty-free, perpetual, irrevocable license to use, display, modify, and distribute your User Content solely for the purpose of operating and promoting the App.

You are solely responsible for your User Content and agree not to upload anything that:
- Infringes on intellectual property or privacy rights
- Is unlawful, harmful, defamatory, obscene, or harassing
- Contains viruses or malicious code

We may remove any User Content at our discretion without notice.

---

## 6. Prohibited Activities

You agree not to:
- Use the App for any illegal or unauthorized purpose
- Interfere with or disrupt the App or servers
- Attempt to gain unauthorized access to accounts or systems
- Copy, modify, or create derivative works of the App
- Reverse engineer, decompile, or disassemble the App
- Use bots, scrapers, or automated tools to access the App

---

## 7. Intellectual Property

The SmilesTreats App, including its design, text, graphics, logos, and software, is owned by LFM, LLC and protected by copyright, trademark, and other laws. You are granted a limited, non-transferable license to use the App for personal, non-commercial purposes only.

---

## 8. Termination

We may suspend or terminate your access to the App at any time, with or without cause or notice, including if we believe you have violated these Terms. Upon termination, your right to use the App ceases immediately.

---

## 9. Disclaimer of Warranties

The App is provided "AS IS" and "AS AVAILABLE" without warranties of any kind, either express or implied, including but not limited to implied warranties of merchantability, fitness for a particular purpose, or non-infringement.

We do not guarantee that the App will be uninterrupted, error-free, secure, or free from viruses.

---

## 10. Limitation of Liability

To the fullest extent permitted by law, LFM, LLC and its officers, directors, employees, and agents shall not be liable for any indirect, incidental, special, consequential, or punitive damages, including loss of profits, data, or goodwill, arising from your use of the App — even if advised of the possibility of such damages.

Our total liability shall not exceed the amount you paid us in the 12 months prior to the claim.

---

## 11. Indemnification

You agree to defend, indemnify, and hold harmless LFM, LLC and its affiliates from any claims, damages, losses, liabilities, costs, and expenses (including reasonable attorney fees) arising from your use of the App, violation of these Terms, or infringement of any third-party rights.

---

## 12. Governing Law and Dispute Resolution

These Terms are governed by the laws of the State of Delaware, USA, without regard to conflict of law principles. Any disputes arising from these Terms or use of the App shall be resolved exclusively in the state or federal courts located in Delaware.

---

## 13. Third-Party Services

The App may contain links to third-party websites or services (e.g., payment processors, social media). We are not responsible for the content, privacy practices, or availability of such external sites.

---

## 14. Force Majeure

We shall not be liable for any failure or delay in performance due to circumstances beyond our reasonable control, including natural disasters, war, terrorism, riots, embargoes, acts of civil or military authorities, fire, floods, accidents, pandemics, or network infrastructure failures.

---

## 15. Contact Information

If you have any questions about these Terms and Conditions, please contact us at:

**LFM, LLC**  
Email: **support@lfmcorp.com**  
App: SmilesTreats

---

Thank you for using SmilesTreats! 
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Terms & Conditions")),
      body: SafeArea(child: Markdown(data: termsMarkdown, selectable: true)),
    );
  }
}
