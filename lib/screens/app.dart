import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:github_signin_promax/github_signin_promax.dart';
import 'package:http/http.dart' as http;

import '../secret.dart';
import 'user_search.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(
        title: 'Flutter Demo Home Page',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String accessToken = '';
  String avatarUrl = '';

  void _navigateToUserSearchScreen() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => UserSearchScreen()));
  }

  Future<void> getUserData(String accessToken) async {
    final response = await http.get(
      Uri.parse('https://api.github.com/user'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    Map<String, dynamic> userData = jsonDecode(response.body);
    String avatarUrl = userData['avatar_url'];
    setState(() {
      this.avatarUrl = avatarUrl;
    });
  }

  void _incrementCounter() {
    setState(() {});
    var params = GithubSignInParams(
      clientId: Secrets.clientId,
      clientSecret: Secrets.clientSecret,
      redirectUrl: 'http://localhost:3000/auth/github/callback',
      scopes: 'read:user,user:email',
    );

    Navigator.of(context).push(MaterialPageRoute(builder: (builder) {
      return GithubSigninScreen(
        params: params,
      );
    })).then((value) {
      setState(() {
        accessToken = value.accessToken;
        getUserData(accessToken);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('GitHub Test Maximal'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToUserSearchScreen();
              },
              child: Text('search'),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                if (avatarUrl.isNotEmpty)
                  Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(avatarUrl),
                        radius: 150,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Login',
          child: const Icon(Icons.login),
        ),

        // floatingActionButton: Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //   crossAxisAlignment: CrossAxisAlignment.end,
        //   children: <Widget>[
        //     FloatingActionButton(
        //       onPressed: () {
        //         Navigator.pop(context);
        //         _navigateToUserSearchScreen();
        //       },
        //       tooltip: 'toScreenScearch',
        //       child: const Icon(Icons.add),
        //     ),

        //   ],
        // ),
      ),
    );
  }
}
