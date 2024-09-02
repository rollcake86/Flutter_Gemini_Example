import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gemini Image & Text Analysis',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Gemini Image & Text Analysis'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _kindController = TextEditingController();
  String _resultText = '';

  Future<void> _getImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _checkContent() async {
    if (_image == null || _textController.text.isEmpty || _kindController.text.isEmpty) {
      setState(() {
        _resultText = '이미지, 텍스트, 종류를 모두 입력해주세요.';
      });
      return;
    }

    final result = await contentCheck(_image!, _textController.text, _kindController.text);

    setState(() {
      _resultText = result ? '콘텐츠가 승인되었습니다.' : '콘텐츠가 거부되었습니다.';
    });
  }

  Future<bool> contentCheck(File image, String content, String kind) async {
    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: '' ,generationConfig: GenerationConfig(responseMimeType: 'application/json',));

    // Prepare image data
    final imageBytes = await image.readAsBytes();

    // Craft a detailed prompt for Gemini
    final prompt = """
      당신은 콘텐츠 관련성 평가 전문가입니다.
      
      다음을 분석하십시오:
      
      이미지 (JPEG 형식): [이미지 데이터]
      텍스트 내용: "$content"
      대상 취미/종류: "$kind"
      
      작업:
      
      안전성 검사:
      이미지와 텍스트에서 폭력, 유혈, 혐오 발언, 성적으로 노골적인 내용이 있는지 철저하게 검사합니다.
      이 중 하나라도 발견되면 즉시 "false"를 반환하고 추가 분석을 중지합니다.
      
      관련성 검사 (안전한 경우에만):
      콘텐츠가 안전하다고 판단되면 이미지와 텍스트 콘텐츠가 지정된 취미/종류와 강하게 관련되는지 확인합니다.
      콘텐츠가 안전하고 취미/종류와 강하게 관련되는 경우 "true"를 반환합니다.
      콘텐츠가 강하게 관련되지 않는 경우 (안전하더라도) "false"를 반환합니다.
      해당 내용의 결과값에 대한 키값은 result로 하며, 타입은 Bool 타입입니다. 
      issue라는 키값이 result 가 true 면 null로 false일 경우에는
      왜 false를 받았는지에 대한 이유를 추가로 넣어주도록 합니다.
      """;

    // Generate response
    final response = await model.generateContent([
      Content.multi([
        TextPart(prompt),
        DataPart('image/jpeg', imageBytes),
      ])
    ]);

    final generatedContent = response.text?.trim();
    print(generatedContent);
    if (generatedContent != null) {
      final Map<String, dynamic> jsonData = jsonDecode(generatedContent);

      // 결과 및 이슈 추출
      final String? result = jsonData['result'];
      final String? issue = jsonData['issue'];

      // 결과에 따라 추가 처리 수행 (예시)
      if (result.toString() == "true") {
        // 콘텐츠가 안전하고 관련성이 높은 경우
        print('콘텐츠가 승인되었습니다.');
        return true; // 최종 결과 반환
      } else {
        // 콘텐츠가 안전하지 않거나 관련성이 낮은 경우
        print('콘텐츠가 거부되었습니다. 이유: $issue');
        return false; // 최종 결과 반환
      }
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_image != null) SizedBox(height: 100,child: Image.file(_image!),),
            ElevatedButton(
              onPressed: _getImage,
              child: Text('이미지 선택'),
            ),
            TextField(
              controller: _textController,
              decoration: InputDecoration(labelText: '텍스트 입력'),
            ),
            TextField(
              controller: _kindController,
              decoration: InputDecoration(labelText: '취미/종류 입력'),
            ),
            ElevatedButton(
              onPressed: _checkContent,
              child: Text('분석 시작'),
            ),
            Text(
              _resultText,
            ),
          ],
        ),
      ),
    );
  }
}