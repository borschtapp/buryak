import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../shared/providers/user.dart';
import '../../shared/validator.dart';
import '../../shared/views/scaffold_login_page.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _showPassword = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> registerUsers() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Processing Data'),
        backgroundColor: Colors.green.shade300,
      ));

      final userData = <String, dynamic>{
        "name": nameController.text,
        "email": emailController.text,
        "emailVisibility": false,
        "password": passwordController.text,
        "passwordConfirm": passwordController.text,
      };

      try {
        await UserService.registerUser(userData);
      } catch (e) {
        String msg = e.toString();
        if(e is ClientException) {
          msg = e.response['message'];
          if (e.response['data'] != null) {
            if (e.response['data']['name'] != null) {
              msg = e.response['data']['name']['message'];
            }
            if (e.response['data']['password'] != null) {
              msg = e.response['data']['password']['message'];
            }
            if (e.response['data']['email'] != null) {
              msg = e.response['data']['email']['message'];
            }
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red.shade300,
        ));
      }
    }
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
              'Register an account',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 35),
            TextFormField(
              controller: nameController,
              validator: (value) {
                return Validator.validateName(value ?? "");
              },
              decoration: const InputDecoration(
                labelText: 'Name',
                isDense: true,
                hintText: 'Oleh',
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
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: registerUsers,
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColorDark,
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 10,
                ),
              ),
              child: Text(
                'Register',
                style: textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {},
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
              onPressed: () => context.goNamed('login'),
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
