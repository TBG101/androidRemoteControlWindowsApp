import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:windwoscontroller/home.dart';
import 'package:windwoscontroller/register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController email = TextEditingController();
  TextEditingController passowrd = TextEditingController();

  Future<int> getLoginStatus() async {
    var url = Uri.parse('https://testiingdeploy.onrender.com/login');

    var response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
          {
            'email': email.text,
            'password': passowrd.text,
          },
        ));

    // check the status code if 200 then store the token
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data["access_token"]);
    }
    return response.statusCode;
  }

  void login() {
    getLoginStatus().then(
      (value) {
        if (value == 200) {
          debugPrint("permitted to enter");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
          );
        } else if (value == 401) {
          debugPrint('Request failed with status: $value.');
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Email or password are not correct"),
          ));
        } else {
          debugPrint('Error with status $value.');
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Email or password are not correct"),
          ));
        }
      },
    );
  }

  Future<bool> checkToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? _token = prefs.getString('token');
    if (_token == null || _token.isEmpty) return false;

    var r = await http.get(
        Uri.parse("https://testiingdeploy.onrender.com/protected"),
        headers: {
          "Authorization": "Bearer $_token",
          'Content-Type': 'application/json',
        });
    if (r.statusCode != 200) {
      // NOT PERMITTED
      debugPrint("not permitedd");

      return false;
    }

    // PERMITTED TO ENTER
    return true;
  }

  void checkAcces() {
    checkToken().then((value) => {
          if (value)
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const Home()))
        });
  }

  register() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Register()),
    );
  }

  @override
  void initState() {
    super.initState();
    try {
      checkAcces();
    } catch (e) {
      throw ("problem with checking Token: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 500,
                child: TextField(
                  controller: email,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Email',
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: 500,
                child: TextField(
                  controller: passowrd,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Password',
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 45,
                width: 100,
                child: ElevatedButton(
                  onPressed: login,
                  child: const Text("Log in"),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: GestureDetector(
                onTap: register,
                child: const Text("Register Here",
                    style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
