import 'package:easy_scooter/components/main_navigation.dart';
import 'package:easy_scooter/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'forgot_password_page.dart';
import 'verification_code_page.dart';
import 'sign_up_page.dart';
import '../../components/page_title.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isEmailValid = true;
  String? _emailErrorText;
  String _errorMessage = ''; // 添加错误信息状态变量

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const PageTitle(title: 'Log In'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Welcome To E-Scooter',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    border: const UnderlineInputBorder(),
                    enabledBorder: const UnderlineInputBorder(),
                    focusedBorder: const UnderlineInputBorder(),
                    errorText: _emailErrorText,
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (value.isEmpty) {
                        _emailErrorText = 'Please enter your email';
                        _isEmailValid = false;
                      } else {
                        bool isValidEmail =
                            RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value);
                        if (!isValidEmail) {
                          _emailErrorText = 'Please enter a valid email';
                          _isEmailValid = false;
                        } else {
                          _emailErrorText = null;
                          _isEmailValid = true;
                        }
                      }
                    });
                  },
                  validator: (value) {
                    // 使用已经在onChanged中验证的结果
                    if (!_isEmailValid) {
                      return _emailErrorText;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    border: const UnderlineInputBorder(),
                    enabledBorder: const UnderlineInputBorder(),
                    focusedBorder: const UnderlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                // Forgot password
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(
                        color: Color.fromARGB(255, 51, 59, 57), fontSize: 13),
                  ),
                ),

                const SizedBox(height: 10),
                // Switch to verification code login

                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VerificationCodePage(),
                        ),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Switch to verification ',
                            style: TextStyle(
                              color: Color.fromARGB(255, 28, 49, 44),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(
                            text: 'code',
                            style: TextStyle(
                              color: Color.fromARGB(255, 28, 49, 44),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(
                            text: ' login',
                            style: TextStyle(
                              color: Color.fromARGB(255, 28, 49, 44),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 错误信息显示区域
                if (_errorMessage.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),

                // Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // 清除之前的错误信息
                      setState(() {
                        _errorMessage = '';
                      });

                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Processing Login')),
                        );

                        final userProvider =
                            Provider.of<UserProvider>(context, listen: false);

                        final res = await userProvider.login(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );

                        if (res['success']) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MainNavigation(),
                            ),
                          );
                        } else if (res['message'] != null) {
                          // 显示错误信息

                          setState(() {
                            String errorMsg = res['message'].toString();
                            if (errorMsg.contains('Error:')) {
                              _errorMessage =
                                  errorMsg.split('Error:')[1].trim();
                            } else {
                              _errorMessage = errorMsg;
                            }
                          });
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 28, 49, 44),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text('Log In'),
                  ),
                ),
                // Sign up option
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'No account yet? Sign up',
                      style: TextStyle(
                        color: Color.fromARGB(255, 28, 49, 44),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                // Or divider
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Or'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),

                // Social login options
                Column(
                  children: [
                    // WeChat login
                    OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement WeChat login
                      },
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.green,
                      ),
                      label: const Text(
                        'Log in with WeChat',
                        style: TextStyle(color: Colors.black87),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Google login
                    OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement Google login
                      },
                      icon: const Icon(
                        Icons.g_mobiledata,
                        color: Colors.red,
                        size: 30,
                      ),
                      label: const Text(
                        'Log in with Google',
                        style: TextStyle(color: Colors.black87),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
