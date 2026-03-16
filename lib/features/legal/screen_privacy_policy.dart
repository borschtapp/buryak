import 'package:flutter/material.dart';

import '../../shared/constants.dart';
import '../../shared/views/article_content.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
        child: ArticleContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Paragraph(
                'This Privacy Policy explains how personal data is processed in connection with '
                'the Borscht app. Borscht is an open-source project maintained by an individual '
                'developer, not a company.',
              ),

              Header('1. Data Controller (Verantwortlicher)'),
              Paragraph('The data controller within the meaning of the GDPR is:'),
              SizedBox(height: 4),
              Text(AppConstants.contactName),
              Text(AppConstants.contactAddress),
              Text(AppConstants.contactCity),
              Text(AppConstants.contactEmail),
              SizedBox(height: 4),
              Paragraph(
                'This data controller is only relevant if you use the public demo instance at '
                'borscht.app. If you self-host the Smetana backend, the operator of that instance '
                'is the data controller for all data stored there — not this developer.',
              ),

              Header('2. How the App Works'),
              Paragraph(
                'Borscht requires a backend server (the Smetana project). You may either self-host '
                'your own instance or use the public demo instance at borscht.app. All data — '
                'recipes, meal plans, shopping lists, and your account — is stored on the backend '
                'you choose to connect to.',
              ),

              Header('3. Self-Hosted Backend'),
              Paragraph(
                'If you run your own Smetana instance, your data is stored exclusively on your '
                'server. The developer of the app has no access to it and receives no information '
                'about your usage. No data protection obligations under this policy apply in that '
                'case.',
              ),

              Header('4. Demo Instance (borscht.app)'),
              Paragraph(
                'The demo instance is provided for evaluation purposes only. The following data '
                'is processed when you use it:',
              ),
              SizedBox(height: 4),
              Text(' ∙ Account data: email address, username, hashed password'),
              Text(' ∙ User content: recipes, meal plans, shopping lists you create'),
              Text(' ∙ Server logs: IP address, timestamps, HTTP request metadata'),
              SizedBox(height: 6),
              Paragraph(
                'Legal basis: Account data and user content are processed on the basis of '
                'Art. 6(1)(b) GDPR (performance of a contract). Server logs are processed on '
                'the basis of Art. 6(1)(f) GDPR (legitimate interests in operating and securing '
                'the service).',
              ),
              Paragraph(
                'Retention: Account data and user content are retained until you delete your '
                'account. Server logs are retained for a maximum of 30 days.',
              ),
              Paragraph(
                'No data is sold, shared with third parties, or used for advertising. No '
                'telemetry or analytics are collected.',
              ),
              Paragraph(
                'The demo instance is hosted by HostUp AB (Sweden, EU/EEA), which acts as a '
                'data processor under a data processing agreement, acting on instructions from '
                'the developer. No data is transferred outside the EU/EEA.',
              ),

              Header('5. Recipe Import'),
              Paragraph(
                'The app allows you to import recipes by providing a URL. These requests are '
                'processed server-side by the Smetana backend, which fetches and parses the '
                'remote page on your behalf. The developer does not store or analyse the content '
                'of third-party websites beyond what is necessary to extract the recipe data. '
                'The privacy policies of those third-party sites apply to the content they serve.',
              ),

              Header('6. No Analytics or Tracking'),
              Paragraph(
                'Borscht contains no analytics SDKs, crash reporters, ad networks, or tracking '
                'libraries. The developer collects no usage data under any circumstances.',
              ),

              Header('7. Local Storage and Offline Cache'),
              Paragraph(
                'The app stores the following data locally on your device:',
              ),
              SizedBox(height: 4),
              Text(' ∙ Authentication tokens (access token and refresh token) — encrypted secure storage'),
              Text(' ∙ The backend server URL you have configured — encrypted secure storage'),
              Text(' ∙ Your recipes, collections, meal plans, and shopping lists — local cache'),
              SizedBox(height: 6),
              Paragraph(
                'Authentication credentials are stored in encrypted secure storage '
                '(flutter_secure_storage) to maintain your session without requiring you to log '
                'in on every use.',
              ),
              Paragraph(
                'Your content (recipes, collections, meal plans, shopping lists) is cached '
                'locally to allow the app to function while offline and to improve performance. '
                'This cache reflects data already stored on the backend you are connected to and '
                'is kept in sync when a connection is available. It is not shared with any third '
                'party and is cleared when you log out or delete the app.',
              ),
              Paragraph(
                'All local storage described above is strictly necessary for the service you '
                'have explicitly requested and is processed on the basis of §25(2) No. 2 TTDSG '
                'and Art. 6(1)(b) GDPR (performance of a contract).',
              ),

              Header('8. Data Transfers'),
              Paragraph(
                'The demo instance is operated within the European Union. No personal data is '
                'transferred to third countries outside the EU/EEA.',
              ),

              Header('9. Your Rights Under the GDPR'),
              Paragraph(
                'If you use the demo instance at borscht.app, you have the following rights '
                'regarding your personal data:',
              ),
              SizedBox(height: 4),
              Text(' ∙ Art. 15 — Right of access: obtain confirmation of what data is held'),
              Text(' ∙ Art. 16 — Right to rectification: have inaccurate data corrected'),
              Text(' ∙ Art. 17 — Right to erasure: request deletion of your data'),
              Text(' ∙ Art. 18 — Right to restriction: limit how your data is processed'),
              Text(' ∙ Art. 20 — Right to data portability: receive your data in a portable format'),
              Text(' ∙ Art. 21 — Right to object: object to processing based on legitimate interests'),
              SizedBox(height: 6),
              Paragraph(
                'To exercise any of these rights, contact ${AppConstants.contactEmail}. Requests will be '
                'handled within one month as required by Art. 12 GDPR.',
              ),

              Header('10. Right to Lodge a Complaint'),
              Paragraph(
                'You have the right to lodge a complaint with a supervisory authority at any '
                'time (Art. 77 GDPR). The competent supervisory authority for the data controller '
                'in Lower Saxony is:',
              ),
              SizedBox(height: 4),
              Text('Die Landesbeauftragte für den Datenschutz Niedersachsen (LfD Niedersachsen)'),
              Text('Prinzenstraße 5, 30159 Hannover'),
              Text('www.lfd.niedersachsen.de'),
              SizedBox(height: 4),
              Paragraph(
                'You may also contact the supervisory authority of the EU member state where you '
                'reside or work, or where the alleged infringement took place.',
              ),

              Header('11. No Automated Decision-Making'),
              Paragraph(
                'No automated decision-making or profiling within the meaning of Art. 22 GDPR '
                'takes place.',
              ),

              Header('12. Open Source'),
              Paragraph(
                'Borscht is free and open-source software licensed under the GNU General Public '
                'License v3. The full source code is available at ${AppConstants.repositoryUrl}, and you '
                'are welcome to inspect it to verify the claims in this policy.',
              ),

              Header('13. Changes to This Policy'),
              Paragraph(
                'This policy may be updated over time. The current version is always available '
                'within the app and in the source repository.',
              ),

              Header('14. Contact'),
              Paragraph(
                'For questions about this Privacy Policy or to exercise your rights, contact '
                '${AppConstants.contactEmail} or open an issue at ${AppConstants.repositoryUrl}.',
              ),

              Header('15. Governing Law'),
              Paragraph(
                'This Privacy Policy is governed by the laws of the Federal Republic of Germany '
                'and the applicable regulations of the European Union, in particular the General '
                'Data Protection Regulation (GDPR / DSGVO).',
              ),
            ],
          ),
        ),
    );
  }
}
