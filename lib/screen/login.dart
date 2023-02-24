import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';

import '../service/user.dart';
import '../utils/validator.dart';
import '../widget/scaffold_login_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showPassword = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Processing Data'),
        backgroundColor: Colors.green.shade300,
      ));

      RecordAuth? res = await UserService.login(
        emailController.text,
        passwordController.text,
      );

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (res == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Error: Unable to retrive user record.'),
          backgroundColor: Colors.red.shade300,
        ));
      } else {
        context.goNamed('home');
      }
    }
  }

  Future<void> googleLogin() async {
    await UserService.oAuthLogin('google');

    context.goNamed('home');
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return ScaffoldWithSimpleLayout(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome back',
              style: textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Login to your account',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 35),
            TextFormField(
              controller: emailController,
              validator: (value) {
                return Validator.validateEmail(value ?? "");
              },
              decoration: const InputDecoration(
                labelText: 'Email',
                isDense: true,
                hintText: 'abc@example.com',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              obscureText: !_showPassword,
              controller: passwordController,
              validator: (value) {
                return Validator.validatePassword(value ?? "");
              },
              decoration: InputDecoration(
                labelText: 'Password',
                isDense: true,
                hintText: '********',
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1,
                  ),
                ),
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() => _showPassword = !_showPassword);
                  },
                  child: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Forgot password?'),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: login,
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColorDark,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 10,
                ),
              ),
              child: Text(
                'Login now',
                style: textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: googleLogin,
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 10,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/icons/google.png'),
                  const SizedBox(width: 8),
                  Text(
                    'Continue with Google',
                    style: textTheme.labelLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () => context.goNamed('register'),
              child: const Text('Register')
            ),
          ],
        ),
      ),
    );
  }
}
