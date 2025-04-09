//
//  NewTagView.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import SwiftUI

struct TermsView: View {
    // Sample Terms and Conditions text (replace with your actual T&C)
    let termsText = """
    Below is a standard industry Terms and Conditions document that outlines the rules and guidelines for using a service. This template is designed to be broadly applicable but should be customized to fit your specific service and legal jurisdiction. It’s highly recommended to consult a legal professional to ensure compliance with applicable laws.

    ---

     Terms and Conditions

    These Terms and Conditions ("Terms") govern your use of [Service Name] ("Service") provided by [Company Name] ("Company", "we", "us", or "our"). By accessing or using the Service, you agree to be bound by these Terms. If you do not agree to these Terms, you may not use the Service.

     1. Acceptance of Terms

    By clicking "I Agree" or using the Service, you confirm that you have read, understood, and agree to be bound by these Terms. If you are using the Service on behalf of an organization, you represent that you have the authority to bind that organization to these Terms.

     2. Changes to Terms

    We reserve the right to modify these Terms at any time. Any changes will be effective immediately upon posting on the Service. We will notify you of significant changes via email or through a notice on the Service. Your continued use of the Service after such changes constitutes your acceptance of the updated Terms.

     3. User Accounts

    To access certain features of the Service, you may need to create an account. You agree to:

    - Be at least 18 years old or have the consent of a parent or guardian.
    - Provide accurate, current, and complete information during registration.
    - Maintain the security of your account credentials.
    - Be responsible for all activities that occur under your account.

    We reserve the right to suspend or terminate your account if you provide false information or violate these Terms.

     4. User Conduct

    You agree not to:

    - Use the Service for any illegal or unauthorized purpose.
    - Post or transmit content that is harmful, offensive, or inappropriate.
    - Interfere with the operation or security of the Service.
    - Attempt to gain unauthorized access to any part of the Service.

    We may remove content or suspend accounts that violate these rules at our discretion.

     5. Intellectual Property

    The Service and its content, including text, graphics, and software, are owned by the Company or its licensors and are protected by intellectual property laws. You retain ownership of any content you submit to the Service but grant us a non-exclusive, royalty-free, worldwide license to use, display, and distribute it as necessary to provide the Service.

     6. Privacy Policy

    Your use of the Service is also governed by our **Privacy Policy**, which explains how we collect, use, and protect your personal data. By using the Service, you consent to our data practices as described in the Privacy Policy.

     7. Payment Terms

    If the Service requires payment:

    - You agree to pay all fees as described on the Service.
    - Payments are processed through third-party payment providers.
    - We may update pricing at any time with prior notice to you.

    Failure to pay may result in the suspension or termination of your access to the Service.

     8. Termination

    You may terminate your account at any time by following the instructions on the Service. We may suspend or terminate your account for violating these Terms or for any other reason, with or without notice, at our sole discretion.

     9. Disclaimers and Limitations of Liability

    The Service is provided "as is" without warranties of any kind, express or implied. To the fullest extent permitted by law, we disclaim all warranties and liability for any damages arising from your use of the Service, including but not limited to indirect, incidental, or consequential damages.

     10. Indemnification

    You agree to indemnify and hold harmless the Company, its affiliates, and their respective officers, directors, employees, and agents from any claims, damages, or expenses (including legal fees) arising from your use of the Service or violation of these Terms.

     11. Governing Law and Dispute Resolution

    These Terms are governed by the laws of [Your Jurisdiction]. Any disputes arising from these Terms will be resolved through binding arbitration in [Your Location], except for matters that may be taken to small claims court. You agree to waive any right to a jury trial or to participate in a class action.

     12. Miscellaneous

    - Severability: If any provision of these Terms is found to be invalid or unenforceable, the remaining provisions will remain in full force and effect.
    - Entire Agreement: These Terms constitute the entire agreement between you and the Company regarding the use of the Service.
    - Waiver: Our failure to enforce any right or provision of these Terms does not constitute a waiver of that right or provision.

     13. Contact Information

    If you have any questions about these Terms, please contact us at [support@example.com].

    ---

    Note: This is a general template intended as a starting point. To ensure it meets your specific needs and complies with local laws, please consult a legal professional to tailor it to your service and jurisdiction.
    """

    var body: some View {
        ScrollView {
            Text(termsText)
                .font(.body)
                .padding()
                .multilineTextAlignment(.leading)
        }
        .navigationTitle("Terms and Conditions")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityLabel("Terms and Conditions")
        .accessibilityHint("Scroll to read the full terms and conditions.")
    }
}
