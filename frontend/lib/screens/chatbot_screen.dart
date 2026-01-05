import 'dart:ui';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart'; removed
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ChatUser _user = ChatUser(id: '1', firstName: 'User');

  // Using the robotic advisor asset if available, else fallback to url
  final ChatUser _bot = ChatUser(
    id: '2',
    firstName: 'Dr. AI',
    profileImage: "assets/images/robotic_advisor.png",
  );

  final List<ChatMessage> _messages = <ChatMessage>[];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _messages.add(
          ChatMessage(
            text:
                "Hello! I am Dr. AI, your lung health assistant. \n\nHow can I help you today?",
            user: _bot,
            createdAt: DateTime.now(),
          ),
        );
      });
    });
  }

  void _onSend(ChatMessage message) {
    setState(() {
      _messages.insert(0, message);
      _isTyping = true;
    });

    // Simulate AI processing time
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      ChatMessage botMessage = ChatMessage(
        user: _bot,
        createdAt: DateTime.now(),
        text: _getBotResponse(message.text),
      );

      setState(() {
        _messages.insert(0, botMessage);
        _isTyping = false;
      });
    });
  }

  String _getBotResponse(String input) {
    input = input.toLowerCase();
    if (input.contains('hello') || input.contains('hi')) {
      return "Greetings! Information is power. Ask me about lung cancer symptoms, prevention, or how to use the scanner.";
    } else if (input.contains('symptom')) {
      return "Common symptoms include:\n• Persistent cough\n• Chest pain\n• Shortness of breath\n• Coughing up blood\n\n⚠ If you have these, please consult a doctor.";
    } else if (input.contains('prevent') || input.contains('cause')) {
      return "Risk Factors:\n• Smoking (Leading cause)\n• Second-hand smoke\n• Radon gas\n• Air pollution\n\nPrevention: Avoid smoking and check air quality.";
    } else if (input.contains('scan') || input.contains('how')) {
      return "To use the AI Scanner:\n1. Go to Home\n2. Tap 'AI Scan'\n3. Upload a Chest X-Ray\n4. Get instant analysis.";
    } else if (input.contains('accurate')) {
      return "My analysis model is >95% accurate in testing, but I am a screening tool. Always rely on a professional biopsy for diagnosis.";
    } else {
      return "I usually analyze medical data. Could you please rephrase your question regarding lung health?";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Dr. AI Assistant",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Get.back(),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      Theme.of(
                        context,
                      ).scaffoldBackgroundColor.withValues(alpha: 0.9),
                      Theme.of(
                        context,
                      ).scaffoldBackgroundColor.withValues(alpha: 0.0),
                    ]
                  : [Colors.white, Colors.white.withValues(alpha: 0.0)],
            ),
          ),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    Theme.of(context).scaffoldBackgroundColor,
                    Theme.of(context).cardColor,
                  ]
                : [
                    const Color(0xFFE0F7FA), // Light Cyan
                    Colors.white,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: DashChat(
                  currentUser: _user,
                  onSend: _onSend,
                  messages: _messages,
                  typingUsers: _isTyping ? [_bot] : [],
                  inputOptions: InputOptions(
                    inputTextStyle: GoogleFonts.poppins(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    inputDecoration: InputDecoration(
                      hintText: "Type your health question...",
                      hintStyle: GoogleFonts.poppins(
                        color: Theme.of(context).hintColor,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      prefixIcon: const Icon(
                        Icons.medical_services_outlined,
                        color: Colors.cyan,
                      ),
                    ),
                    sendButtonBuilder: (onSend) => IconButton(
                      onPressed: onSend,
                      icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  messageOptions: MessageOptions(
                    currentUserContainerColor: AppColors.primaryBlue,
                    containerColor: isDark
                        ? Theme.of(context).cardColor
                        : Colors.white,
                    textColor:
                        Theme.of(context).textTheme.bodyMedium?.color ??
                        Colors.black87,
                    currentUserTextColor: Colors.white,
                    showOtherUsersAvatar: true,
                    avatarBuilder: (user, onPress, onLongPress) => Container(
                      padding: const EdgeInsets.all(2), // Border
                      decoration: const BoxDecoration(
                        color: Colors.cyan,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage(
                          "assets/images/robotic_advisor.png",
                        ),
                      ),
                    ),
                    messageDecorationBuilder:
                        (message, previousMessage, nextMessage) =>
                            BoxDecoration(
                              color: message.user.id == '1'
                                  ? AppColors.primaryBlue
                                  : (isDark
                                        ? Theme.of(context).cardColor
                                        : Colors.white),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
