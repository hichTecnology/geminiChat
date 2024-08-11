
import 'dart:io';
import 'dart:typed_data';
import 'package:mime/mime.dart';

import 'package:image_downloader/image_downloader.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
  }

class _HomeState extends State<Home> {
  final TextEditingController _userMessage = TextEditingController();
  static const apiKey = "AIzaSyAor61DhchaQrTkdqKco0txBptNIAqJv8Y";
  final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  final List<Message> _messages = [] ;

  Future<void> sendMessage () async{
    final message = _userMessage.text;
    _userMessage.clear();
    setState(() {
      _messages.add(Message(isUser : false, message : message, date : DateTime.now()));
    });
    final content = [Content.text(message)];
    final response = await model.generateContent(content);
    print(response);
    setState(() {
      _messages.add(Message(isUser : true , message : response.text ?? "",date :DateTime.now()));
    });

  }
  Future<void> sendImage () async{

    // The Gemini 1.5 models are versatile and work with both text-only and multimodal prompts
    var imageId = await ImageDownloader.downloadImage('https://firebasestorage.googleapis.com/v0/b/chatgpttxt-e042f.appspot.com/o/image?alt=media&token=b08fcde9-f1c9-4519-ba5c-d8c5d67f2aaf');
    if (imageId == null) {
      return;
    }
    // Below is a method of obtaining saved image information.



    var fileName = await ImageDownloader.findName(imageId);
    var path = await ImageDownloader.findPath(imageId);
    var file1 = File(path!);
    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

    final prompt = "un immagine con aereo ";
    var imgBytes = await file1.readAsBytes();

// Lookup function from the mime plugin
    var imageMimeType = lookupMimeType(file1.path);

    final response = await model.generateContent([
    Content.multi([
      TextPart(prompt),
      ])
    ]);
    print(response.text);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(title: const Text('Gemini')),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(child: ListView.builder(
              itemCount: _messages.length,
                itemBuilder: (context ,index){
                final message = _messages[index];
                return Messages(
                    isUser: message.isUser, 
                    message: message.message, 
                    date: DateFormat('HH:MM').format(message.date)
                );
              }
                )
            ),
            Padding(
                padding:const EdgeInsets.symmetric(horizontal: 8.0 , vertical:  15),
              child: Row(
                children: [
                  Expanded(child: TextFormField(
                    controller: _userMessage,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.deepOrange),
                        borderRadius: BorderRadius.circular(50)),
                      label: const Text('Ask Gemini..')
                      
                    ),
                  )),
                  IconButton(
                      padding: const EdgeInsets.all(15),
                      iconSize: 30,
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.blueGrey),
                          foregroundColor: MaterialStateProperty.all(Colors.white),
                          shape: MaterialStateProperty.all(const CircleBorder())
                      ),
                      onPressed: (){
                        sendImage();

                      },
                      icon: const Icon(Icons.image)),
                  
                  IconButton(
                    padding: const EdgeInsets.all(15),
                      iconSize: 30,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                        shape: MaterialStateProperty.all(const CircleBorder())
                      ),
                      onPressed: (){
                    sendMessage();
                  },
                      icon: const Icon(Icons.send))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Messages extends StatelessWidget{
  final bool isUser;
  final String message;
  final String date;

  const Messages({super.key, required this.isUser, required this.message, required this.date});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: double.infinity,
      padding:const  EdgeInsets.all(15),
      margin:const EdgeInsets.symmetric(vertical: 15).copyWith(
        left: isUser ? 100 :10,
        right: isUser ? 10:100,
      ),
      decoration: BoxDecoration(
        color: isUser ? Colors.deepPurple : Colors.grey.shade200,
        borderRadius:  BorderRadius.only(
          topLeft:const Radius.circular(30),
          bottomLeft: isUser ? const Radius.circular(30): Radius.zero,
          topRight: const Radius.circular(30),
          bottomRight: isUser ? Radius.zero : const Radius.circular(30)

        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message ,style: TextStyle(color: isUser ? Colors.white : Colors.black),),
          Text(date ,style: TextStyle(color: isUser ? Colors.white : Colors.black),),
        ],
      ),
    );
  }

}

class Message {
  final bool isUser;
  final String message;
  final DateTime date;

  Message({
    required this.isUser,
    required this.message,
    required this.date
  });
}
