import 'package:flutter/material.dart';

import '../shared/extensions.dart';
import '../shared/views/article_content.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: ArticleContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Paragraph(
              'At Borscht Cookbook, accessible from https://borscht.app, one of our main priorities is the privacy of our visitors. This Privacy Policy document contains types of information that is collected and recorded by Borscht Cookbook and how we use it.',
            ),
            Paragraph(
              'If you have additional questions or require more information about our Privacy Policy, do not hesitate to contact us via support@borascht.app',
            ),

            Header('General Data Protection Regulation (GDPR)'),
            Paragraph('We are a Data Controller of your information.'),
            Paragraph(
              'Borscht Cookbook legal basis for collecting and using the personal information described in this Privacy Policy depends on the Personal Information we collect and the specific context in which we collect the information:',
            ),

            SizedBox(height: 4),
            Text(' ∙ Borscht Cookbook needs to perform a contract with you'),
            Text(' ∙ You have given Borscht Cookbook permission to do so'),
            Text(' ∙ Processing your personal information is in Borscht Cookbook legitimate interests'),
            Text(' ∙ Borscht Cookbook needs to comply with the law'),
            SizedBox(height: 6),

            Paragraph(
              'Borscht Cookbook will retain your personal information only for as long as is necessary for the purposes set out in this Privacy Policy. We will retain and use your information to the extent necessary to comply with our legal obligations, resolve disputes, and enforce our policies.',
            ),

            Paragraph(
              'If you are a resident of the European Economic Area (EEA), you have certain data protection rights. If you wish to be informed what Personal Information we hold about you and if you want it to be removed from our systems, please contact us.',
            ),
            Paragraph('In certain circumstances, you have the following data protection rights:'),
            SizedBox(height: 4),
            Text(' ∙ The right to access, update or to delete the information we have on you.'),
            Text(' ∙ The right of rectification.'),
            Text(' ∙ The right to object.'),
            Text(' ∙ The right of restriction.'),
            Text(' ∙ The right to data portability'),
            Text(' ∙ The right to withdraw consent'),

            Header('Log Files'),
            Paragraph(
              'Borscht Cookbook follows a standard procedure of using log files. These files log visitors when they visit websites. All hosting companies do this and a part of hosting services\' analytics. The information collected by log files include internet protocol (IP) addresses, browser type, Internet Service Provider (ISP), date and time stamp, referring/exit pages, and possibly the number of clicks. These are not linked to any information that is personally identifiable. The purpose of the information is for analyzing trends, administering the site, tracking users\' movement on the website, and gathering demographic information.',
            ),

            Header('Privacy Policies'),
            Paragraph(
              'You may consult this list to find the Privacy Policy for each of the advertising partners of Borscht Cookbook.',
            ),
            Paragraph(
              'Third-party ad servers or ad networks uses technologies like cookies, JavaScript, or Web Beacons that are used in their respective advertisements and links that appear on Borscht Cookbook, which are sent directly to users\' browser. They automatically receive your IP address when this occurs. These technologies are used to measure the effectiveness of their advertising campaigns and/or to personalize the advertising content that you see on websites that you visit.',
            ),
            Paragraph(
              'Note that Borscht Cookbook has no access to or control over these cookies that are used by third-party advertisers.',
            ),

            Header('Third Party Privacy Policies'),
            Paragraph(
              'Borscht Cookbook\'s Privacy Policy does not apply to other advertisers or websites. Thus, we are advising you to consult the respective Privacy Policies of these third-party ad servers for more detailed information. It may include their practices and instructions about how to opt-out of certain options.',
            ),
            Paragraph(
              'You can choose to disable cookies through your individual browser options. To know more detailed information about cookie management with specific web browsers, it can be found at the browsers\' respective websites.',
            ),

            Header('Children\'s Information'),
            Paragraph(
              'Another part of our priority is adding protection for children while using the internet. We encourage parents and guardians to observe, participate in, and/or monitor and guide their online activity.',
            ),
            Paragraph(
              'Borscht Cookbook does not knowingly collect any Personal Identifiable Information from children under the age of 13. If you think that your child provided this kind of information on our website, we strongly encourage you to contact us immediately and we will do our best efforts to promptly remove such information from our records.',
            ),

            Header('Online Privacy Policy Only'),
            Paragraph(
              'Our Privacy Policy applies only to our online activities and is valid for visitors to our website with regards to the information that they shared and/or collect in Borscht Cookbook. This policy is not applicable to any information collected offline or via channels other than this website.',
            ),

            Header('Consent'),
            Paragraph(
              'By using our website, you hereby consent to our Privacy Policy and agree to its Terms and Conditions.',
            ),
          ],
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
