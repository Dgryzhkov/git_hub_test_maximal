import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/repository.dart';

class RepositoryListScreen extends StatefulWidget {
  final String reposUrl;

  RepositoryListScreen({required this.reposUrl});

  @override
  _RepositoryListScreenState createState() => _RepositoryListScreenState();
}

class _RepositoryListScreenState extends State<RepositoryListScreen> {
  Future<List<Repository>> _getUserRepositories(String reposUrl,
      {int page = 1, int perPage = 60}) async {
    final response =
        await http.get(Uri.parse('$reposUrl?page=$page&per_page=$perPage'));
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

  List<Repository> _repositories = [];
  int _page = 1;
  bool _isLoading = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadRepositories();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreRepositories();
      }
    });
  }

  Future<void> _loadRepositories() async {
    List<Repository> repositories =
        await _getUserRepositories(widget.reposUrl, page: 1);
    setState(() {
      _repositories = repositories;
    });
  }

  Future<void> _loadMoreRepositories() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      List<Repository> newRepositories =
          await _getUserRepositories(widget.reposUrl, page: _page + 1);
      setState(() {
        _repositories.addAll(newRepositories);
        _page++;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Repositories'),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _repositories.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _repositories.length) {
            DateTime dateTime = DateTime.parse(_repositories[index].updatedAt);
            String formattedDate =
                DateFormat.yMMMd().add_jms().format(dateTime);

            return ListTile(
              title: Text(_repositories[index].name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Description: ${_repositories[index].description}'),
                  Text('Last Commit Date: $formattedDate'),
                  Text('Default Branch: ${_repositories[index].defaultBranch}'),
                  Text('Forks Count: ${_repositories[index].forksCount}'),
                  Text(
                      'Stargazers Count: ${_repositories[index].stargazersCount}'),
                  Text('Language: ${_repositories[index].language}'),
                ],
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
