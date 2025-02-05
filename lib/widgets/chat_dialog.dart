import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/gpt_service_provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../providers/selected_date_provider.dart';
import '../providers/day_health_report_provider.dart';
import '../providers/database_provider.dart';
import 'dart:developer' as developer;

class ChatDialog extends ConsumerStatefulWidget {
  const ChatDialog({super.key});

  @override
  ConsumerState<ChatDialog> createState() => _ChatDialogState();
}

class _ChatDialogState extends ConsumerState<ChatDialog> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addSystemMessage();
  }

  void _addSystemMessage() {
    _messages.add(const ChatMessage(
      message: "我是您的AI健康助手。我可以帮您调整今天的健康计划，请告诉我您想要如何调整。",
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            color: Color.fromRGBO(21, 17, 20, 1),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildMessageList()),
                _buildInputArea(),
              ],
            ),
          ),
        ),
      );

  Widget _buildHeader() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Color.fromRGBO(35, 35, 37, 1),
          border: Border(
            bottom: BorderSide(
              color: Color.fromRGBO(45, 45, 47, 1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            const Text(
              'Ask AI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {}, // 添加更多功能
            ),
          ],
        ),
      );

  Widget _buildMessageList() => ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _messages.length,
        itemBuilder: (context, index) => _messages[index],
      );

  Widget _buildInputArea() => Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        decoration: const BoxDecoration(
          color: Color.fromRGBO(35, 35, 37, 1),
          border: Border(
            top: BorderSide(
              color: Color.fromRGBO(45, 45, 47, 1),
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Focus(
                onKeyEvent: (node, event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.enter &&
                      !HardwareKeyboard.instance.isShiftPressed) {
                    if (!_isLoading) {
                      _handleSend();
                    }
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  onSubmitted: (_) => _handleSend(),
                  textInputAction: TextInputAction.send,
                  onEditingComplete: () {
                    if (!_isLoading) {
                      _handleSend();
                    }
                  },
                  keyboardType: TextInputType.multiline,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildSendButton(),
          ],
        ),
      );

  Widget _buildSendButton() => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(55, 236, 203, 1),
              Color.fromRGBO(27, 137, 117, 1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: IconButton(
          icon: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.send, color: Colors.white, size: 20),
          onPressed: _isLoading ? null : _handleSend,
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

    _scrollToBottom();

    try {
      // 1. 获取当前日期
      final selectedDate = ref.read(selectedDateProvider);
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);

      // 2. 从数据库获取当天计划
      final db = ref.read(databaseProvider);
      final plan = await db.getHealthPlanByDate(selectedDate);

      if (plan == null) {
        _addErrorMessage("未找到今天的健康计划");
        return;
      }

      // 3. 构建带上下文的提示
      final prompt = '''
当前健康计划：
${plan.morningRoutine}
${plan.exercises}
${plan.meals}

用户请求：
${_controller.text}

请严格按照以下JSON格式返回修改后的完整计划，不要添加任何其他内容或说明：
{
  "dailyPlan": {
    "morningRoutine": [{"time": "HH:MM AM/PM", "activity": "活动名称", "calories": "± XXX Kcal"}],
    "exercises": [{"time": "HH:MM AM/PM", "type": "运动名称", "calories": "- XXX Kcal"}],
    "meals": [{"time": "HH:MM AM/PM", "type": "餐食类型", "calories": "+ XXX Kcal", "menu": ["食物1", "食物2"]}]
  }
}''';

      // 4. 发送到 GPT 获取调整建议
      final gptService = ref.read(gptServiceProvider);
      final response = await gptService.chat(prompt);

      // 清理响应文本
      final cleanedResponse = _cleanJsonResponse(response);

      // 5. 保存调整后的计划
      await gptService.saveHealthPlan(cleanedResponse, selectedDate);

      // 6. 刷新 DayHealthReport
      await ref
          .read(dayHealthReportProvider.notifier)
          .loadDayHealthPlan(selectedDate);

      // 7. 提取回复消息
      final jsonResponse = jsonDecode(cleanedResponse);
      final summary = _generateSummary(jsonResponse);

      setState(() {
        _messages.add(ChatMessage(
          message: "我已经帮您调整了健康计划：\n\n$summary",
          isUser: false,
        ));
      });

      _controller.clear();
      _scrollToBottom();
    } catch (e) {
      developer.log('调整计划出错', error: e);
      _addErrorMessage("调整计划时出错：$e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _cleanJsonResponse(String response) {
    // 移除可能的 markdown 代码块标记
    var cleaned = response.replaceAll(RegExp(r'```json|```'), '');

    // 移除开头和结尾的空白字符
    cleaned = cleaned.trim();

    // 移除可能的多余换行
    cleaned = cleaned.replaceAll(RegExp(r'\n\s*'), ' ');

    // 如果响应不是以 { 开始，尝试找到第一个 { 的位置
    if (!cleaned.startsWith('{')) {
      final startIndex = cleaned.indexOf('{');
      if (startIndex != -1) {
        cleaned = cleaned.substring(startIndex);
      }
    }

    // 如果响应不是以 } 结束，尝试找到最后一个 } 的位置
    if (!cleaned.endsWith('}')) {
      final endIndex = cleaned.lastIndexOf('}');
      if (endIndex != -1) {
        cleaned = cleaned.substring(0, endIndex + 1);
      }
    }

    developer.log('清理后的 JSON: $cleaned');

    // 验证是否为有效的 JSON
    try {
      jsonDecode(cleaned);
    } catch (e) {
      throw FormatException('GPT 返回的不是有效的 JSON 格式: $cleaned');
    }

    return cleaned;
  }

  void _addErrorMessage(String error) {
    setState(() {
      _messages.add(ChatMessage(
        message: error,
        isUser: false,
      ));
      _isLoading = false;
    });
  }

  String _generateSummary(Map<String, dynamic> response) {
    final plan = response['dailyPlan'];
    final StringBuffer summary = StringBuffer();

    // 添加晨间活动总结
    summary.writeln('晨间活动：');
    for (var routine in plan['morningRoutine']) {
      summary.writeln(
          '- ${routine['time']}: ${routine['activity']} (${routine['calories']})');
    }

    // 添加运动总结
    summary.writeln('\n运动计划：');
    for (var exercise in plan['exercises']) {
      summary.writeln(
          '- ${exercise['time']}: ${exercise['type']} (${exercise['calories']})');
    }

    // 添加餐食总结
    summary.writeln('\n餐食安排：');
    for (var meal in plan['meals']) {
      summary
          .writeln('- ${meal['time']}: ${meal['type']} (${meal['calories']})');
      summary.writeln('  食材: ${meal['menu'].join(', ')}');
    }

    return summary.toString();
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
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color.fromRGBO(37, 195, 166, 1)
                    : const Color.fromRGBO(35, 35, 37, 1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      );
}
