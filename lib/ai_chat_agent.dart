// File: ai_chat_agent.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class AIChatAgent extends StatefulWidget {
  const AIChatAgent({super.key});

  @override
  State<AIChatAgent> createState() => _AIChatAgentState();
}

class _AIChatAgentState extends State<AIChatAgent>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isTyping = false;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  late AnimationController _bubbleController;
  late AnimationController _expandController;
  late Animation<double> _bubbleAnimation;
  late Animation<double> _expandAnimation;

  // AI Knowledge Base
  final Map<String, dynamic> _aiResponses = {
    // Greetings
    'hello': 'Hello! I\'m your AI health assistant. How can I help you today? 👋',
    'hi': 'Hi there! I\'m here to help with your health questions. What would you like to know? 😊',
    'good morning': 'Good morning! Ready to start your day with good health? How can I assist you?',
    'good afternoon': 'Good afternoon! Hope you\'re having a healthy day. What can I help you with?',
    'good evening': 'Good evening! How can I support your health journey today?',

    // Health Questions
    'bmi': 'BMI (Body Mass Index) helps assess if you\'re at a healthy weight. You can calculate it using our BMI Tracker in the app. Would you like me to guide you there?',
    'blood pressure': 'Normal blood pressure is typically around 120/80 mmHg. High BP can be managed through diet, exercise, and medication. Always consult your doctor for personalized advice.',
    'diabetes': 'Diabetes management involves monitoring blood sugar, healthy eating, regular exercise, and medication as prescribed. Our app can help track your health metrics.',
    'heart health': 'Keep your heart healthy with regular exercise, a balanced diet low in saturated fats, not smoking, and managing stress. Regular check-ups are important too!',
    'mental health': 'Mental health is just as important as physical health. Practice stress management, get adequate sleep, exercise regularly, and don\'t hesitate to seek professional help when needed.',

    // App Features
    'features': 'Our app offers: Hair Analysis, Skin Check, Dental Assessment, BMI Tracking, Medicine Reminders, Health Reports, and Emergency SOS. Which would you like to explore?',
    'hair check': 'Our Hair Check feature uses AI to analyze your hair health and provides personalized recommendations. You can access it from the main dashboard.',
    'skin check': 'The Skin Check feature helps monitor skin conditions and provides care tips. It\'s available in the Quick Actions section.',
    'medicine reminder': 'Never miss your medications! Set up personalized reminders in our Medicine section. It helps maintain your treatment schedule.',
    'emergency': 'Our Emergency SOS feature can quickly alert your emergency contacts and provide location information during medical emergencies.',

    // General Health Tips
    'exercise': 'Aim for at least 150 minutes of moderate exercise per week. This includes brisk walking, swimming, or cycling. Start small and gradually increase intensity.',
    'diet': 'A healthy diet includes plenty of fruits, vegetables, whole grains, lean proteins, and healthy fats. Stay hydrated and limit processed foods.',
    'sleep': 'Adults need 7-9 hours of quality sleep nightly. Good sleep hygiene includes a regular schedule, comfortable environment, and avoiding screens before bed.',
    'water': 'Stay hydrated! Aim for 8 glasses of water daily, more if you\'re active or in hot weather. Water helps with digestion, circulation, and temperature regulation.',
    'stress': 'Manage stress through deep breathing, meditation, regular exercise, hobbies, and social connections. Chronic stress can impact both mental and physical health.',

    // Symptoms
    'headache': 'Headaches can be caused by stress, dehydration, eye strain, or other factors. Stay hydrated, rest, and consult a doctor if they\'re severe or persistent.',
    'fever': 'Fever is your body\'s natural response to infection. Stay hydrated, rest, and seek medical attention if fever is high (over 103°F) or persistent.',
    'cough': 'Coughs can be due to various causes. Stay hydrated, use honey for soothing, and see a doctor if it persists or is accompanied by other symptoms.',

    // Default responses for unrecognized queries
    'default': <String>[
      'That\'s an interesting question! For specific medical concerns, I recommend consulting with a healthcare professional.',
      'I\'m here to provide general health information. For personalized medical advice, please consult your doctor.',
      'While I can share general health tips, it\'s always best to discuss specific concerns with a qualified healthcare provider.',
      'I don\'t have specific information about that, but our app has various health tracking features that might help!',
      'For the most accurate and personalized health information, I recommend speaking with a medical professional.',
    ],
  };

  // Quick suggestion buttons
  final List<String> _quickSuggestions = [
    'What is BMI?',
    'Heart health tips',
    'How to manage stress?',
    'App features',
    'Emergency help',
    'Healthy diet tips',
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeChat();
  }

  void _setupAnimations() {
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _bubbleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bubbleController, curve: Curves.elasticOut),
    );

    _expandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeInOut),
    );

    _bubbleController.forward();
  }

  void _initializeChat() {
    // Add welcome message after a short delay
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _addMessage(
          'Hello! I\'m your AI health assistant 🤖\n\nI can help you with:\n• Health questions & tips\n• App navigation\n• General wellness advice\n\nHow can I assist you today?',
          isUser: false,
        );
      }
    });
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    _expandController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleChat() {
    HapticFeedback.lightImpact();
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  void _addMessage(String message, {required bool isUser}) {
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: isUser,
        timestamp: DateTime.now(),
      ));
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Timer(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getAIResponse(String userMessage) {
    final message = userMessage.toLowerCase().trim();

    // Check for exact matches first
    if (_aiResponses.containsKey(message)) {
      final response = _aiResponses[message];
      if (response is String) {
        return response;
      }
    }

    // Check for partial matches
    for (String key in _aiResponses.keys) {
      if (key != 'default' && message.contains(key)) {
        final response = _aiResponses[key];
        if (response is String) {
          return response;
        }
      }
    }

    // Return random default response
    final defaultResponses = _aiResponses['default'] as List<String>;
    return defaultResponses[(DateTime.now().millisecondsSinceEpoch % defaultResponses.length)];
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    HapticFeedback.selectionClick();
    _addMessage(message, isUser: true);
    _messageController.clear();

    // Show typing indicator
    setState(() {
      _isTyping = true;
    });

    // Simulate AI thinking time
    Timer(Duration(milliseconds: 800 + (message.length * 20)), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });

        final response = _getAIResponse(message);
        _addMessage(response, isUser: false);
      }
    });
  }

  void _sendQuickMessage(String message) {
    _sendMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Chat Interface
        if (_isExpanded) _buildChatInterface(),

        // Floating Chat Button - Hide when chat is expanded
        if (!_isExpanded) _buildFloatingButton(),
      ],
    );
  }

  Widget _buildFloatingButton() {
    return Positioned(
      bottom: 100,
      right: 16,
      child: AnimatedBuilder(
        animation: _bubbleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _bubbleAnimation.value,
            child: GestureDetector(
              onTap: _toggleChat,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1565C0).withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatInterface() {
    return Positioned(
      bottom: 100,
      right: 16,
      child: AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _expandAnimation.value,
            alignment: Alignment.bottomRight,
            child: Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height * 0.6,
                  constraints: const BoxConstraints(
                    maxWidth: 400,
                    maxHeight: 500,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildChatHeader(),
                      _buildQuickSuggestions(),
                      Expanded(child: _buildMessagesList()),
                      _buildMessageInput(),
                    ],
                  ),
                ),
                // Close button positioned at top-right of chat interface
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: _toggleChat,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 50, top: 16, bottom: 16), // Added right padding to avoid overlap with close button
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Health Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Always here to help',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.greenAccent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    if (_messages.length > 2) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Questions:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _quickSuggestions.map((suggestion) {
              return GestureDetector(
                onTap: () => _sendQuickMessage(suggestion),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF1565C0).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    suggestion,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isTyping) {
          return _buildTypingIndicator();
        }

        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? const Color(0xFF1565C0)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black87,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(index),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        double dotValue = 0.0;
        if (index == 0) {
          dotValue = value;
        } else if (index == 1) {
          dotValue = value > 0.3 ? (value - 0.3) / 0.7 : 0;
        } else {
          dotValue = value > 0.6 ? (value - 0.6) / 0.4 : 0;
        }

        return Transform.scale(
          scale: 0.5 + (0.5 * (1 + 0.5 * dotValue)),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Ask me anything...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: _sendMessage,
                textInputAction: TextInputAction.send,
                maxLines: null,
              ),
            ),
          ),
          const SizedBox(width: 12), // Increased spacing
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _sendMessage(_messageController.text),
              borderRadius: BorderRadius.circular(22),
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                  ),
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
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}