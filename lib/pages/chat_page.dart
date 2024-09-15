import 'package:chatbot/consts.dart';
import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _openAI = OpenAI.instance.build(
      token: OPENAI_API_KEY,
      baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 5)),
      enableLog: true);

  final ChatUser _currentUser =
      ChatUser(id: '1', firstName: "Phranav", lastName: "K S");
  final ChatUser _gptChatUser =
      ChatUser(id: '2', firstName: "chat", lastName: "gpt");

  List<ChatMessage> _messages = <ChatMessage>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GPT Chat'),
        backgroundColor: Colors.blue, // AppBar color set to blue
      ),
      body: DashChat(
        currentUser: _currentUser,
        messageOptions: const MessageOptions(
          currentUserContainerColor: Colors.black,
          containerColor: Color.fromRGBO(0, 166, 126, 1),
          textColor: Colors.white,
        ),
        onSend: (ChatMessage message) {
          getChatResponse(message);
        },
        messages: _messages,
      ),
    );
  }

  Future<void> getChatResponse(ChatMessage message) async {
    // Insert user message into chat history
    setState(() {
      _messages.insert(0, message);
    });

    // Create a list of previous messages as per GPT's format
    List<Map<String, dynamic>> _messagesHistory = _messages.reversed.map((m) {
      if (m.user == _currentUser) {
        return {
          'role': 'user',
          'content': m.text,
        };
      } else {
        return {
          'role': 'assistant',
          'content': m.text,
        };
      }
    }).toList();

    // Create the ChatCompleteText request
    final request = ChatCompleteText(
      model: GptTurboChatModel(), // Specify the model explicitly as a string
      messages: _messagesHistory,
      maxToken: 200,
    );



    final response = await _openAI.onChatCompletion(request: request);

    for (var element in response!.choices) {
      if (element.message != null) {
        setState(() {
          _messages.insert(
            0,
            ChatMessage(
                user: _gptChatUser,
                createdAt: DateTime.now(),
                text: element.message!.content),
          );
        });
      }
    }
  }
}
