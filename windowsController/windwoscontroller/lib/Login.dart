import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:windwoscontroller/home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController email = TextEditingController();
  TextEditingController passowrd = TextEditingController();

  Future<bool> login() async {
    var url = Uri.parse('http://192.168.1.13:5000/login');

    var response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
          {
            'email': email.text,
            'password': passowrd.text,
          },
        ));
    // check the status code for the result
    if (response.statusCode == 200) {
      print("status == 200");
      Map<String, dynamic> data = json.decode(response.body);
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data["access_token"]);
      return true;
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
    return false;
  }

  Future<bool> checkToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? _token = prefs.getString('token');

    if (_token != null) {
      var r = await http
          .get(Uri.parse("http://192.168.1.13:5000/protected"), headers: {
        "Authorization": "Bearer $_token",
        'Content-Type': 'application/json',
      });
      if (r.statusCode == 200) {
        // PERMITTED TO ENTER
        return true;
      } else
        print("not permitedd");
    }
    if (_token == null) {
      print("no token");
    }
    return false;
  }

  checkAcces() {
    checkToken().then((value) => {
          if (value)
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Home()),
              )
            }
        });
  }

  @override
  void initState() {
    super.initState();
    checkAcces();
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
                onPressed: () {
                  login().then((value) {
                    if (value) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Home()),
                      );
                    }
                  });
                },
                child: const Text("Log in"),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
