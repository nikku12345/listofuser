

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:listofuser/model.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int totalPage,nextPage;


  ScrollController _scrollController = new ScrollController();

  bool isLoading = false;

  List<Data> names = new List();


  final dio = new Dio();
  void _getMoreData() async {
    String apiUrl = "https://reqres.in/api/users?page=$nextPage";

    if (!isLoading) {
      setState(() {
        isLoading = true;
      });





        final response =
        await http.get(Uri.parse('$apiUrl'));

        if (response.statusCode == 200) {
          ApiCall apiCall=ApiCall.fromJson(jsonDecode(response.body));
          setState(() {
            totalPage=apiCall.totalPages;
          });
          List<Data> tempList = new List();
          if(nextPage<=totalPage){
          setState(() {
            nextPage = nextPage + 1;
          });
        }
        for (int i = 0; i < apiCall.data.length; i++) {
            tempList.add(apiCall.data[i]);
          }

          setState(() {
            isLoading = false;
            names.addAll(tempList);
          });


        } else {

          throw Exception('Failed to load album');
        }
      //}

    }
  }

  @override
  void initState() {
    nextPage=1;
    this._getMoreData();
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      //+1 for progressbar
      itemCount: names.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == names.length) {
          return _buildProgressIndicator();
        } else {
          return Column(
            children: [
              ListTile(
                title: Text('${names[index].firstName} ${names[index].lastName}'),
                subtitle: Text('${names[index].email}'),
                leading: CircleAvatar(
                  child: Image.network("${names[index].avatar}"),
                ),
              ),
              SizedBox(height: 50.0,)
            ],
          );
        }
      },
      controller: _scrollController,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pagination"),
      ),
      body: Container(
        child: _buildList(),
      ),
      resizeToAvoidBottomPadding: false,
    );
  }
}
