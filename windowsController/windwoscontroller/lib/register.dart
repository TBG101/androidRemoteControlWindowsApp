import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:windwoscontroller/Login.dart';

class Register extends StatefulWidget {
  Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController email = TextEditingController();

  TextEditingController passowrd = TextEditingController();

  TextEditingController username = TextEditingController();

  Future<http.Response> register() async {
    var url = Uri.parse('https://testiingdeploy.onrender.com/login');

    var response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "username": username.text,
          "email": email.text,
          "password": passowrd.text
        }));

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
              alignment: Alignment.topLeft,
              child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: IconButton(
                      alignment: Alignment.center,
                      splashRadius: 25,
                      padding: const EdgeInsets.only(left: 8),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                        );
                      },
                      icon: const Icon(Icons.arrow_back_ios)))),
          SizedBox(
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
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'username',
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
                        if (username.text.isEmpty |
                            email.text.isEmpty |
                            passowrd.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Missing Fields")));
                          return;
                        }
                        register().then((response) {
                          if (response.statusCode == 201) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("User created")));
                          } else if (response.statusCode == 409) {
                            var message = jsonDecode(response.body)["message"];
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("$message")));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Error")));
                          }
                        });
                      },
                      child: const Text("Register"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
