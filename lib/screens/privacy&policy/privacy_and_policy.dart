import 'package:flutter/material.dart';

class PrivacyAndPolicyPage extends StatelessWidget {
  const PrivacyAndPolicyPage({super.key});

  static const id = "/privacy&policy";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Privacy & Policy"),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TitleText("INTRODUCTION"),
              ParagraphText("""
      At STARZ Ventures Pvt Ltd, accessible from http://starzventures.in/, one of our main priorities is the privacy of our visitors.
      
      This Privacy Policy document contains types of information that is collected and recorded by STARZ Ventures and how we use it.
      
      If you have additional questions or require more information about our Privacy Policy, do not hesitate to contact us.
      
      This Privacy Policy applies only to our online activities and is valid for visitors to our website with regards to the information that they shared and/or collect in STARZ Ventures. This policy is not applicable to any information collected offline or via channels other than this website.
      """),
              TitleText("CONSENT"),
              ParagraphText("""
By using our website or app, you hereby consent to our Privacy Policy and agree to its terms.
Information we collect
The personal information that you are asked to provide, and the reasons why you are asked to provide it, will be made clear to you at the point we ask you to provide your personal information.

If you contact us directly, we may receive additional information about you such as your name, email address, phone number, the contents of the message and/or attachments you may send us, and any other information you may choose to provide.

When you register for an Account, we may ask for your contact information, including items such as name, company name, address, email address, and telephone number.
"""),
              TitleText("STARZ App"),
              TitleText("Personal Information"),
              ParagraphText("""
We understand the importance of your privacy and the sensitivity of your personal information. We collect and store only the minimum amount of personal information necessary for your use of our chat app. This includes your username, profile picture, and phone number (if provided). We do not collect any other personal information such as your location, address, or email.
Use of Personal Information We use your personal information solely for the purpose of enabling you to use our chat app. This includes authenticating your identity, displaying your profile information to other users, and facilitating communication between you and other users. We do not use your personal information for any other purposes, and we do not share your personal information with any third parties.
"""),
              TitleText("Security"),
              ParagraphText("""
We take security seriously and implement industry-standard security measures to protect your personal information. We encrypt all communication between your device and our servers using SSL/TLS encryption. We also store your personal information in secure servers that are protected by firewalls and other security measures.
"""),
              TitleText("Third Party"),
              ParagraphText(
                  "Some data like contact info which are the phone numbers of user's contacts are shared with 3rd party service like Meta, etc."),
              TitleText("Data Retention"),
              ParagraphText(
                  "We retain your personal information only for as long as necessary to enable you to use our chat app. We delete your personal information immediately upon your request to delete your account or when we determine that your account has been inactive for a period of time."),
              TitleText("Children's Privacy"),
              ParagraphText("""
Our chat app is not intended for children under the age of 13. We do not knowingly collect personal information from children under 13. If you are a parent or guardian and you believe that your child has provided us with personal information, please contact us immediately at [insert contact information] so that we can delete the information.
"""),
              TitleText("Changes to Privacy Policy"),
              ParagraphText(
                  "We may update this privacy policy from time to time. We will notify you of any changes by posting the new privacy policy on this page. You are advised to review this privacy policy periodically for any changes. Changes to this privacy policy are effective when they are posted on this page."),
              TitleText("Contact Us"),
              ParagraphText(
                  "If you have any questions or concerns about our privacy policy, please contact us at app@starzventures.in"),
              TitleText("How we use your information"),
              ParagraphText("""
We use the information we collect in various ways, including to:
Provide, operate, and maintain our website
Improve, personalize, and expand our website
Understand and analyze how you use our website
Develop new products, services, features, and functionality
Communicate with you, either directly or through one of our partners, including for customer service, to provide you with updates and other information relating to the website, and for marketing and promotional purposes
Send you emails
Find and prevent fraud
"""),
              TitleText("Log Files"),
              ParagraphText(
                  "STARZ Ventures follows a standard procedure of using log files. These files log visitors when they visit websites. All hosting companies do this and a part of hosting services' analytics. The information collected by log files include internet protocol (IP) addresses, browser type, Internet Service Provider (ISP), date and time stamp, referring/exit pages, and possibly the number of clicks. These are not linked to any information that is personally identifiable. The purpose of the information is for analyzing trends, administering the site, tracking users' movement on the website, and gathering demographic information. Our Privacy Policy was created with the help of the Privacy Policy Generator and the Disclaimer Generator."),
              TitleText("Cookies and Web Beacons"),
              ParagraphText(
                  """Like any other website, STARZ Ventures uses 'cookies'. These cookies are used to store information including visitors' preferences, and the pages on the website that the visitor accessed or visited. The information is used to optimize the users' experience by customizing our web page content based on visitors' browser type and/or other information.
For more general information on cookies, please read \"What Are Cookies\."""),
              TitleText("Advertising Partners Privacy Policies"),
              ParagraphText(
                  """You may consult this list to find the Privacy Policy for each of the advertising partners of STARZ Ventures.
Third-party ad servers or ad networks uses technologies like cookies, JavaScript, or Web Beacons that are used in their respective advertisements and links that appear on STARZ Ventures, which are sent directly to users' browser. They automatically receive your IP address when this occurs. These technologies are used to measure the effectiveness of their advertising campaigns and/or to personalize the advertising content that you see on websites that you visit.
Note that STARZ Ventures has no access to or control over these cookies that are used by third-party advertisers.
"""),
              TitleText("Third Party Privacy Policies"),
              ParagraphText("""
STARZ Ventures's Privacy Policy does not apply to other advertisers or websites. Thus, we are advising you to consult the respective Privacy Policies of these third-party ad servers for more detailed information. It may include their practices and instructions about how to opt-out of certain options.
You can choose to disable cookies through your individual browser options. To know more detailed information about cookie management with specific web browsers, it can be found at the browsers' respective websites.
"""),
              TitleText(
                  "CCPA Privacy Rights (Do Not Sell My Personal Information)"),
              ParagraphText("""
Under the CCPA, among other rights, California consumers have the right to:
Request that a business that collects a consumer's personal data disclose the categories and specific pieces of personal data that a business has collected about consumers.
Request that a business delete any personal data about the consumer that a business has collected.
Request that a business that sells a consumer's personal data, not sell the consumer's personal data.
If you make a request, we have one month to respond to you. If you would like to exercise any of these rights, please contact us.
"""),
              TitleText("GDPR Data Protection Rights"),
              ParagraphText("""
We would like to make sure you are fully aware of all of your data protection rights. Every user is entitled to the following:

The right to access – You have the right to request copies of your personal data. We may charge you a small fee for this service.
The right to rectification – You have the right to request that we correct any information you believe is inaccurate. You also have the right to request that we complete the information you believe is incomplete.
The right to erasure – You have the right to request that we erase your personal data, under certain conditions.
The right to restrict processing – You have the right to request that we restrict the processing of your personal data, under certain conditions.
The right to object to processing – You have the right to object to our processing of your personal data, under certain conditions.
The right to data portability – You have the right to request that we transfer the data that we have collected to another organization, or directly to you, under certain conditions.
If you make a request, we have one month to respond to you. If you would like to exercise any of these rights, please contact us.
"""),
              TitleText("Children's Information"),
              ParagraphText("""
  Another part of our priority is adding protection for children while using the internet. We encourage parents and guardians to observe, participate in, and/or monitor and guide their online activity.
STARZ Ventures does not knowingly collect any Personal Identifiable Information from children under the age of 13. If you think that your child provided this kind of information on our website, we strongly encourage you to contact us immediately and we will do our best efforts to promptly remove such information from our records.
""")
            ])),
      ),
    );
  }
}

// ignore: must_be_immutable
class TitleText extends StatelessWidget {
  TitleText(String title, {super.key}) {
    text = title;
  }

  late String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}

// ignore: must_be_immutable
class ParagraphText extends StatelessWidget {
  ParagraphText(String title, {super.key}) {
    text = title;
  }

  late String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 16),
    );
  }
}
