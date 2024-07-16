import 'dart:html';
import 'package:flutter/material.dart';
import 'package:flutter_web/home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      var response = await http.post(
        Uri.http('localhost:4000', '/user/admin/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'phone': _phoneController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt', responseData['token']);
        document.cookie =
            "Authorization=${responseData['token']};path=/;max-age=3600;SameSite=None";
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomePage()));
      } else if (response.statusCode == 401) {
        setState(() {
          _errorMessage = "Vous n'avez pas le droit d'accéder à cette section.";
        });
      } else {
        throw Exception('Failed to log in with status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Admin login page',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.lightBlue[100],
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.height *
                      0.8, // Making the card relatively narrower
                  child: Card(
                    color: Color.fromARGB(255, 234, 238, 238),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Phone',
                                hintText: 'Enter your phone number',
                              ),
                              validator: (value) => value!.isEmpty
                                  ? 'Please enter your phone'
                                  : null,
                            ),
                            TextFormField(
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                hintText: 'Enter your password',
                              ),
                              obscureText: true,
                              validator: (value) => value!.isEmpty
                                  ? 'Please enter your password'
                                  : null,
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _login,
                              child: Text(
                                'Login',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightBlue[300],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                              ),
                            ),
                            if (_errorMessage.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(_errorMessage,
                                    style: const TextStyle(color: Colors.red)),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
