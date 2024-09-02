import 'package:flutter/material.dart';

import 'ChatScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '쳇봇 샘플앱'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();

  void startChat() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return ChatScreen(
        hobby: _controller.value.text.trim(),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '쳇봇을 시작해보세요 쳇봇을 원하는 취미를입력해보세요',
            ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(hintText: '목공예'),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: startChat,
        tooltip: 'Chatbot',
        child: const Icon(Icons.chat),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
