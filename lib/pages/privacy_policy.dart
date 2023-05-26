import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kindah/widgets/adaptive_ui.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return EcommAdaptiveUI(
        appbarTitle: "Privacy Policy",
        onBackPressed: () => context.go("/home"),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(paragraphs.length, (index) {
                return ListTile(
                  title: Text(
                    paragraphs[index].title!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(paragraphs[index].paragraph!),
                );
              }),
            ),
          ),
        ));
  }
}

class PrivacyParagraph {
  final String? title;
  final String? paragraph;

  PrivacyParagraph({this.title, this.paragraph});
}

List<PrivacyParagraph> paragraphs = [
  PrivacyParagraph(
    title: "Privacy Policy for Kindah Store",
    paragraph:
        "Effective Date: 2023-04-07 \n\nThis Privacy Policy describes how Kindah Store collects, uses, and discloses information from users of our mobile app and website. By using our app and website, you consent to the terms of this Privacy Policy.",
  ),
  PrivacyParagraph(
    title: "1. User Management",
    paragraph:
        "Users of Kindah Store can sign up for an account and have full access to their personal information, including the ability to view and change it. Users may delete their accounts and personal information by contacting our admin to submit a deletion request. Users can submit and publish their own content and share content available in the app to other social networks. However, users cannot interact with each other on our website or mobile app.",
  ),
  PrivacyParagraph(
    title: "2. Products and Services",
    paragraph:
        "Kindah Store offers products and services provided by third-party companies. We take all necessary measures to keep sensitive payment information secure and do not store any sensitive payment information.",
  ),
  PrivacyParagraph(
      title: "3. Tracking Technologies",
      paragraph:
          "Our website does not use cookies, but our app and website use third-party analytics or tracking tools like Google Analytics. Our website does not follow or respond to 'do not track' signals. Users' personal information is anonymized to prevent analytics tools from linking it to an individual person. Ads are displayed on the mobile app."),
  PrivacyParagraph(
      title: "4. Collection of Information",
      paragraph:
          "We collect information from users, including account details (such as username, unique user ID, password), contact information (such as email address, phone number), and basic personal information (such as name, country of residence). Our mobile app and website do not request access to geolocation, but may request access to features like gallery and calendar. We do not collect any derivative data like IP address or device name."),
  PrivacyParagraph(
      title: "5. Use of Information",
      paragraph:
          "The information collected from users is used to create and manage user accounts, fulfill and manage orders, deliver products and services, send administrative information, respond to inquiries and offer support, request user feedback, improve user experience, enforce terms and conditions and policies, protect from abuse and malicious users, and respond to legal requests. We do not combine any personal information."),
  PrivacyParagraph(
      title: "6. Disclosure of Information",
      paragraph:
          "We do not disclose any personal information to business affiliates. We may disclose personal information to law enforcement agencies upon lawful requests."),
  PrivacyParagraph(
      title: "7. Information Storage",
      paragraph:
          "Personal information collected from users is stored for as long as the user account remains active. In case of a data breach, we will notify users via phone call, email, or post a notification on the website and mobile app."),
  PrivacyParagraph(
      title: "8. Changes and Updates",
      paragraph:
          "We may update this Privacy Policy from time to time. Users will be notified of the updates to this policy by updating the modification date at the bottom of the privacy policy page."),
  PrivacyParagraph(
      title: "Contact Us",
      paragraph:
          "If you have any questions or concerns about this Privacy Policy or our practices, please contact us at support@kindahstore.com.")
];
