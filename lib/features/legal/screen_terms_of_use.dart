import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/constants.dart';
import '../../shared/layouts/article_content.dart';
import '../../shared/route_names.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Use'),
        leading: BackButton(onPressed: () => context.canPop() ? context.pop() : context.goNamed(RouteNames.account)),
      ),
      body: SingleChildScrollView(
        child: ArticleContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Legal Notice — required by §5 DDG (Digitale-Dienste-Gesetz)
              const Header('Legal Notice (Impressum)'),
              const Paragraph('Information pursuant to §5 DDG:'),
              const SizedBox(height: 4),
              const Text(AppConstants.contactName),
              const Text(AppConstants.contactAddress),
              const Text(AppConstants.contactCity),
              const Text(AppConstants.contactEmail),
              const SizedBox(height: 8),

              const Paragraph(
                'By using the Borscht app, you agree to these Terms of Use. Borscht is developed '
                'and maintained by an individual developer, not a company. The app is free and '
                'open-source software released under the GNU General Public License v3.',
              ),

              const Header('1. Scope of Service'),
              const Paragraph(
                'Borscht is a recipe management application that requires a backend server '
                '(Smetana) to function. Users may self-host the backend or use the public demo '
                'instance at borscht.app. The app allows managing recipes, meal plans, and '
                'shopping lists, and includes a recipe import feature for fetching content from '
                'third-party URLs.',
              ),

              const Header('2. No Warranty'),
              const Paragraph(
                'Borscht is provided "as is", without warranty of any kind, express or implied. '
                'The developer makes no representations or guarantees regarding the accuracy, '
                'reliability, availability, or fitness of the app for any particular purpose. '
                'This disclaimer applies to the maximum extent permitted by applicable law.',
              ),

              const Header('3. Limitation of Liability'),
              const Paragraph(
                'To the fullest extent permitted by applicable law, the developer shall not be '
                'liable for any direct, indirect, incidental, consequential, or special damages '
                'arising out of or in connection with your use of the app or inability to use it, '
                'including but not limited to loss of data, loss of profits, or business '
                'interruption.',
              ),
              const Paragraph(
                'Nothing in these terms excludes or limits liability for death or personal injury '
                'caused by negligence, for intentional misconduct (Vorsatz), for gross negligence '
                '(grobe Fahrlässigkeit), for fraud, or for any other liability that cannot be '
                'excluded under applicable German law.',
              ),

              const Header('4. Demo Instance (borscht.app)'),
              const Paragraph(
                'A public demo instance of the Borscht backend is available at borscht.app. It is '
                'provided solely for evaluation and demonstration purposes, free of charge, with '
                'no service level agreement. The developer makes no guarantees regarding uptime, '
                'data retention, or continued availability.',
              ),
              const Paragraph(
                'The demo instance may be modified, restricted, or taken offline at any time '
                'without notice. The developer accepts no responsibility for loss of data stored '
                'on the demo instance. You are strongly encouraged to self-host your own backend '
                'for any serious or long-term use.',
              ),

              const Header('5. Third-Party Content & Copyright'),
              const Paragraph(
                'Borscht includes a recipe import feature that fetches and parses content from '
                'URLs that you provide. The developer does not endorse, curate, or control any '
                'content you choose to import.',
              ),
              const Paragraph(
                'Recipe content fetched from third-party websites may be protected by copyright '
                'or subject to the terms of service of the originating website. You are solely '
                'responsible for ensuring that your use of any imported content complies with '
                'applicable intellectual property laws and the terms of the source website. '
                'The developer accepts no liability for any copyright infringement or terms of '
                'service violations arising from your use of the import feature.',
              ),
              const Paragraph(
                'Copyright holders who believe that content stored on the demo instance '
                '(borscht.app) infringes their rights may submit a takedown request by email to '
                '${AppConstants.contactEmail}.app. Please include: a description of the copyrighted work, '
                'a link to the infringing content, your contact information, and a statement that '
                'you are the rights holder or authorised to act on their behalf. Valid requests '
                'will be acted upon promptly.',
              ),

              const Header('6. Self-Hosted Backend'),
              const Paragraph(
                'If you choose to self-host the Smetana backend, you are solely responsible for '
                'the security, maintenance, availability, and legal compliance of your instance, '
                'including GDPR obligations for any personal data stored on it.',
              ),

              const Header('7. External Links'),
              const Paragraph(
                'The app may display or interact with content from third-party websites. The '
                'developer is not responsible for the content, availability, privacy practices, '
                'or terms of those sites. Use of any external website is at your own risk.',
              ),

              const Header('8. Modifications'),
              const Paragraph(
                'These Terms of Use may be updated from time to time. Material changes will be '
                'announced within the app or via the source repository at ${AppConstants.repositoryUrl} '
                'with reasonable advance notice before they take effect. The current version is always available within the app and in the source '
                'repository. If you do not accept updated terms, you may discontinue use of the app.',
              ),

              const Header('9. Privacy'),
              Builder(
                builder: (context) => InkWell(
                  child: const Paragraph('Please read our Privacy Policy.'),
                  onTap: () => GoRouter.of(context).goNamed(RouteNames.privacy),
                ),
              ),

              const Header('10. Open Source License'),
              const Paragraph(
                'Borscht is licensed under the GNU General Public License v3. The full source '
                'code is available at ${AppConstants.repositoryUrl}. You are free to use, modify, and '
                'distribute it in accordance with the terms of that license.',
              ),

              const Header('11. EU Dispute Resolution'),
              const Paragraph(
                'The European Commission provides an online dispute resolution (ODR) platform: '
                'https://ec.europa.eu/consumers/odr',
              ),
              const Paragraph(
                'The developer is not obligated to participate in dispute resolution proceedings '
                'before a consumer arbitration board and does not voluntarily do so.',
              ),

              const Header('12. Contact'),
              const Paragraph(
                'For questions, bug reports, or legal concerns, contact '
                '${AppConstants.contactEmail} or open an issue at ${AppConstants.repositoryUrl}.',
              ),

              const Header('13. Governing Law & Jurisdiction'),
              const Paragraph(
                'These Terms of Use are governed by and construed in accordance with the laws of '
                'the Federal Republic of Germany. For users who are consumers within the EU, '
                'mandatory consumer protection provisions of the country of residence remain '
                'unaffected. Place of jurisdiction for disputes with non-consumers is the '
                'developer\'s place of residence.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
