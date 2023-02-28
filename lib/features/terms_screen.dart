import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../shared/extensions.dart';
import '../shared/views/article_content.dart';

class TermsOfUseScreen extends StatefulWidget {
  const TermsOfUseScreen({super.key});

  @override
  State<TermsOfUseScreen> createState() => _TermsOfUseScreenState();
}

class _TermsOfUseScreenState extends State<TermsOfUseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: ArticleContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    BackButton(
                      onPressed: () => GoRouter.of(context).go('/recipes'),
                    ),
                    SizedBox(width: 4),
                    Text('Terms of Use', style: context.textTheme.headlineMedium),
                  ],
                ),

                SizedBox(height: 6),
                Header('1. Terms'),
                Paragraph('By accessing this Website, accessible from https://borscht.app, you are agreeing to be bound by these Website Terms and Conditions of Use and agree that you are responsible for the agreement with any applicable local laws. If you disagree with any of these terms, you are prohibited from accessing this site. The materials contained in this Website are protected by copyright and trade mark law.'),

                Header('2. Use License'),
                Paragraph('Permission is granted to temporarily download one copy of the materials on Borscht Cookbook\'s Website for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:'),
                SizedBox(height: 4),
                Text(' ∙ modify or copy the materials;'),
                Text(' ∙ use the materials for any commercial purpose or for any public display;'),
                Text(' ∙ attempt to reverse engineer any software contained on Borscht Cookbook\'s Website;'),
                Text(' ∙ remove any copyright or other proprietary notations from the materials; or'),
                Text(' ∙ transferring the materials to another person or "mirror" the materials on any other server.'),
                SizedBox(height: 2),
                Text('This will let Borscht Cookbook to terminate upon violations of any of these restrictions. Upon termination, your viewing right will also be terminated and you should destroy any downloaded materials in your possession whether it is printed or electronic format.'),

                Header('3. Disclaimer'),
                Paragraph('All the materials on Borscht Cookbook’s Website are provided "as is". Borscht Cookbook makes no warranties, may it be expressed or implied, therefore negates all other warranties. Furthermore, Borscht Cookbook does not make any representations concerning the accuracy or reliability of the use of the materials on its Website or otherwise relating to such materials or any sites linked to this Website.'),

                Header('4. Limitations'),
                Paragraph('Borscht Cookbook or its suppliers will not be hold accountable for any damages that will arise with the use or inability to use the materials on Borscht Cookbook’s Website, even if Borscht Cookbook or an authorize representative of this Website has been notified, orally or written, of the possibility of such damage. Some jurisdiction does not allow limitations on implied warranties or limitations of liability for incidental damages, these limitations may not apply to you.'),

                Header('5. Revisions and Errata'),
                Paragraph('The materials appearing on Borscht Cookbook’s Website may include technical, typographical, or photographic errors. Borscht Cookbook will not promise that any of the materials in this Website are accurate, complete, or current. Borscht Cookbook may change the materials contained on its Website at any time without notice. Borscht Cookbook does not make any commitment to update the materials.'),

                Header('6. Links'),
                Paragraph('Borscht Cookbook has not reviewed all of the sites linked to its Website and is not responsible for the contents of any such linked site. The presence of any link does not imply endorsement by Borscht Cookbook of the site. The use of any linked website is at the user’s own risk.'),

                Header('7. Site Terms of Use Modifications'),
                Paragraph('Borscht Cookbook may revise these Terms of Use for its Website at any time without prior notice. By using this Website, you are agreeing to be bound by the current version of these Terms and Conditions of Use.'),

                Header('8. Your Privacy'),
                InkWell(child: Paragraph('Please read our Privacy Policy.'), onTap: () => GoRouter.of(context).goNamed('privacy')),

                Header('9. Governing Law'),
                Paragraph('Any claim related to Borscht Cookbook\'s Website shall be governed by the laws of de without regards to its conflict of law provisions.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Paragraph extends StatelessWidget {
  final String text;
  const Paragraph(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 1, bottom: 2),
      child: Text(text),
    );
  }
}

class Header extends StatelessWidget {
  final String text;
  const Header(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(text, style: context.textTheme.titleMedium),
    );
  }
}
