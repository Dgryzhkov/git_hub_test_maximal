import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/repository.dart';
import '../models/user.dart';
import 'repository_list.dart';

class UserSearchScreen extends StatefulWidget {
  @override
  _UserSearchScreenState createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _searchResults = [];

  Future<void> _searchUsers(String query) async {
    final response = await http
        .get(Uri.parse('https://api.github.com/search/users?q=$query'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<User> users = (data['items'] as List).map((item) {
        return User(
          login: item['login'],
          avatarUrl: item['avatar_url'],
          reposUrl: item['repos_url'],
        );
      }).toList();
      setState(() {
        _searchResults = users;
      });
    }
  }

  Future<int> getFollowersCount(String login) async {
    final String followersUrl = 'https://api.github.com/users/$login/followers';

    int retryCount = 3; // Количество попыток повторного запроса

    for (int i = 0; i < retryCount; i++) {
      try {
        final response = await http.get(Uri.parse(followersUrl));

        if (response.statusCode == 200) {
          final List<dynamic> followers = json.decode(response.body);
          return followers.length;
        } else {
          throw Exception('Failed to load followers');
        }
      } catch (e) {
        print('Error loading followers: $e');
        if (i < retryCount - 1) {
          print('Retrying...');
        }
      }
    }

    // Если все попытки не увенчались успехом, возвращаем значение 0
    return 0;
  }

  Future<List<Repository>> _getUserRepositories(String reposUrl) async {
    final response = await http.get(Uri.parse(reposUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<Repository> repositories = (data as List).map((item) {
        return Repository(
          name: item['name'],
          description: item['description'] ?? '',
          updatedAt: item['updated_at'],
          defaultBranch: item['default_branch'],
          forksCount: item['forks_count'],
          stargazersCount: item['stargazers_count'],
          language: item['language'] ?? '',
        );
      }).toList();
      return repositories;
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GitHub User Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextField(
                controller: _searchController,
                decoration:
                    InputDecoration(labelText: 'Enter a GitHub username'),
                onSubmitted: (value) => _searchUsers(value),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: _searchResults.length,
                separatorBuilder: (context, index) =>
                    Divider(), // Добавляем разделитель между элементами
                itemBuilder: (context, index) {
                  return FutureBuilder<int>(
                    future: getFollowersCount(_searchResults[index].login),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListTile(
                          leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  _searchResults[index].avatarUrl)),
                          title: Text(_searchResults[index].login),
                          subtitle: Text('Followers: ${snapshot.data}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RepositoryListScreen(
                                    reposUrl: _searchResults[index].reposUrl),
                              ),
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return const Text('Error loading followers');
                      }
                    
                      return const Center(child: CircularProgressIndicator());
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
