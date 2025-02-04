import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'Home.dart';
import '../services/gpt_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/health_report_provider.dart';
import 'dart:developer' as developer;

class HealthStatusScreen extends ConsumerStatefulWidget {
  const HealthStatusScreen({super.key});

  @override
  ConsumerState<HealthStatusScreen> createState() => _HealthStatusScreenState();
}

class _HealthStatusScreenState extends ConsumerState<HealthStatusScreen> {
  String? _fileName;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    // 监听 healthReport 状态
    ref.listen(healthReportProvider, (previous, next) {
      developer.log('healthReport 状态变化');
      next.whenData((activities) {
        if (activities.isNotEmpty) {
          developer.log('解析到活动数据，数量: ${activities.length}');
          developer.log('准备导航到 Home 页面');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
          );
        } else {
          developer.log('没有解析到活动数据');
        }
      });
    });

    return Scaffold(
      backgroundColor: const Color.fromRGBO(21, 17, 20, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackButton(),
                const SizedBox(height: 20),
                _buildStatusText(),
                const SizedBox(height: 8),
                _buildTitle(),
                const SizedBox(height: 8),
                _buildSubtitle(),
                const SizedBox(height: 20),
                _buildUploadSection(),
                const SizedBox(height: 20),
                _buildContextSection(),
                const SizedBox(height: 20),
                _buildNextButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() => Container(
        width: 37,
        height: 37,
        decoration: _buildButtonDecoration(),
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: Color.fromRGBO(106, 106, 108, 1),
          size: 22,
        ),
      );

  BoxDecoration _buildButtonDecoration() => BoxDecoration(
        color: const Color.fromRGBO(35, 35, 37, 1),
        borderRadius: BorderRadius.circular(7),
      );

  Widget _buildStatusText() => Text(
        "Training AI...",
        style: _buildTextStyle(14, 0.6),
      );

  Widget _buildTitle() => Text(
        "Your health status",
        style: _buildTextStyle(33, 1.0, FontWeight.w600),
      );

  Widget _buildSubtitle() => Text(
        "Upload your health report",
        style: _buildTextStyle(16, 0.7, FontWeight.w500),
      );

  Widget _buildUploadSection() => GestureDetector(
        onTap: _isUploading ? null : _pickAndAnalyzeFile,
        child: Container(
          width: double.infinity,
          height: 159,
          decoration: _buildSectionDecoration(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _buildUploadContent(),
          ),
        ),
      );

  List<Widget> _buildUploadContent() => [
        if (_isUploading)
          const CircularProgressIndicator(
            color: Color.fromRGBO(37, 195, 166, 1),
          )
        else
          Icon(
            _fileName != null ? Icons.description : Icons.add,
            color: const Color.fromRGBO(37, 195, 166, 1),
            size: 34,
          ),
        if (_fileName != null) ...[
          const SizedBox(height: 8),
          Text(_fileName!, style: _buildTextStyle(14, 1.0)),
        ],
        const SizedBox(height: 8),
        Text(
          _getUploadStatusText(),
          style: _buildTextStyle(14, 0.7),
        ),
      ];

  String _getUploadStatusText() {
    if (_isUploading) return '正在分析...';
    if (_fileName != null) return '点击更换文件';
    return '点击上传PDF文件';
  }

  Widget _buildContextSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "or give me some context",
            style: _buildTextStyle(16, 0.7, FontWeight.w500),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 185,
            decoration: _buildSectionDecoration(),
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Describe your Blood Pressure, Cholesterol Levels, Blood Sugar Levels...",
              style: _buildTextStyle(16, 0.5, FontWeight.w500),
            ),
          ),
        ],
      );

  Widget _buildNextButton() => GestureDetector(
        onTap: _isUploading ? null : _pickAndAnalyzeFile,
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: _buildSectionDecoration(),
          child: Center(
            child: Text(
              "Next",
              style: _buildTextStyle(14, 1.0, FontWeight.w500),
            ),
          ),
        ),
      );

  BoxDecoration _buildSectionDecoration() => BoxDecoration(
        color: const Color.fromRGBO(35, 35, 37, 1),
        borderRadius: BorderRadius.circular(16),
      );

  TextStyle _buildTextStyle(double size, double opacity,
          [FontWeight? weight]) =>
      TextStyle(
        fontSize: size,
        color: Colors.white.withOpacity(opacity),
        fontFamily: 'Inter',
        fontWeight: weight ?? FontWeight.normal,
      );

  Future<void> _pickAndAnalyzeFile() async {
    try {
      developer.log('开始选择文件');
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        developer.log('文件已选择: ${result.files.first.name}');
        setState(() {
          _fileName = result.files.first.name;
          _isUploading = true;
        });

        final file = File(result.files.first.path!);
        developer.log('开始分析健康报告');

        await ref.read(healthReportProvider.notifier).analyzeReport(file);
        developer.log('健康报告分析完成');
      } else {
        developer.log('用户取消了文件选择');
      }
    } catch (e, st) {
      developer.log('文件处理出错', error: e, stackTrace: st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('处理文件时出错: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }
}
