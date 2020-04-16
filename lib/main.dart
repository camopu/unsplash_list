import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show get;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class Unsplash {
  final String title, author, imageUrl,imageUrlFull;

  Unsplash({
    this.title,
    this.author,
    this.imageUrl,
    this.imageUrlFull,
  });

  factory Unsplash.fromJson(Map<String, dynamic> jsonData) {
    return Unsplash(
      title: jsonData['description'],
      author: jsonData['user']['name'],
      imageUrl: jsonData['urls']['small'],
      imageUrlFull: jsonData['urls']['regular'],
    );
  }
}

class CustomListView extends StatelessWidget {
  final List<Unsplash> unsplashs;

  CustomListView(this.unsplashs);

  Widget build(context) {
    return ListView.builder(
      itemCount: unsplashs.length,
      itemBuilder: (context, int currentIndex) {
        return createViewItem(unsplashs[currentIndex], context);
      },
    );
  }

  Widget createViewItem(Unsplash unsplash, BuildContext context) {
    return new ListTile(
        title: new Card(
          elevation: 5.0,
          child: new Container(
            margin: EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                Padding(
                  child: Image.network(unsplash.imageUrl),
                  padding: EdgeInsets.only(bottom: 8.0),
                ),
                Row(children: <Widget>[
                  Flexible(
                      child: RichText(
                        text: TextSpan( 
                          text: unsplash.title,
                          style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                          children: <TextSpan>[
                            TextSpan(text: ' // '),
                            TextSpan(text: unsplash.author, style: new TextStyle(fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ),
                  ),
                ]),
              ],
            ),
          ),
        ),
        onTap: () {
          var route = new MaterialPageRoute(
            builder: (BuildContext context) =>
                new SecondScreen(value: unsplash),
          );
          Navigator.of(context).push(route);
        });
  }
}

Future<List<Unsplash>> downloadJSON() async {
  final jsonEndpoint =
      "https://api.unsplash.com/photos/?client_id=ab3411e4ac868c2646c0ed488dfd919ef612b04c264f3374c97fff98ed253dc9";

  final response = await get(jsonEndpoint);

  if (response.statusCode == 200) {
    List unsplash = json.decode(response.body);
    return unsplash
        .map((unsplash) => new Unsplash.fromJson(unsplash))
        .toList();
  } else
    throw Exception('JSON data is not loaded');
}

class SecondScreen extends StatefulWidget {
  final Unsplash value;

  SecondScreen({Key key, this.value}) : super(key: key);

  @override
  _SecondScreenState createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  @override
    Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage('${widget.value.imageUrlFull}'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(title: const Text('Unsplash List Images')),
        body: new Center(
          child: new FutureBuilder<List<Unsplash>>(
            future: downloadJSON(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Unsplash> unsplash = snapshot.data;
                return new CustomListView(unsplash);
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return new CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}