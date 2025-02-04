import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/gpt_service_provider.dart';

class ChatDialog extends ConsumerStatefulWidget {
  const ChatDialog({super.key});

  @override
  ConsumerState<ChatDialog> createState() => _ChatDialogState();
}

class _ChatDialogState extends ConsumerState<ChatDialog> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color.fromRGBO(21, 17, 20, 1),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: _messages.map((msg) => msg).toList(),
                    ),
                  ),
                ),
              ),
              _buildInputArea(),
            ],
          ),
        ),
      );

  Widget _buildHeader() => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color.fromRGBO(35, 35, 37, 1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            const Text(
              'Ask AI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );

  Widget _buildInputArea() => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color.fromRGBO(35, 35, 37, 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Type response',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color.fromRGBO(37, 195, 166, 1),
                      ),
                    )
                  : const Icon(
                      Icons.send,
                      color: Color.fromRGBO(37, 195, 166, 1),
                    ),
              onPressed: _isLoading ? null : _handleSend,
            ),
          ],
        ),
      );

  Future<void> _handleSend() async {
    if (_controller.text.isEmpty) return;

    final userMessage = ChatMessage(
      message: _controller.text,
      isUser: true,
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    try {
      final response =
          await ref.read(gptServiceProvider).chat(_controller.text); // 需要实现这个方法

      setState(() {
        _messages.add(ChatMessage(
          message: response,
          isUser: false,
        ));
      });

      _controller.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发送失败：$e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class ChatMessage extends StatelessWidget {
  final String message;
  final bool isUser;

  const ChatMessage({
    super.key,
    required this.message,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color.fromRGBO(37, 195, 166, 1)
                    : const Color.fromRGBO(35, 35, 37, 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
}
