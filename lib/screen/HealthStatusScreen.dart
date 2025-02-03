import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'Home.dart';
import '../services/gpt_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/health_report_provider.dart';

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
    ref.listen(healthReportProvider, (previous, next) {
      if (next is AsyncData && next.value != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      }
    });

    return Scaffold(
      backgroundColor: Color.fromRGBO(21, 17, 20, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 37,
                  height: 37,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(35, 35, 37, 1),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Transform.rotate(
                    angle: -90 * 3.1415926535897932 / 180,
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: Color.fromRGBO(106, 106, 108, 1),
                      size: 22,
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Training AI...",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.6),
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Your health status",
                  style: TextStyle(
                    fontSize: 33,
                    color: Colors.white,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Upload your health report",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: _isUploading
                      ? null
                      : () async {
                          try {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf'],
                            );

                            if (result != null &&
                                result.files.single.path != null) {
                              setState(() {
                                _fileName = result.files.single.name;
                                _isUploading = true;
                              });

                              final file = File(result.files.single.path!);
                              await ref
                                  .read(healthReportProvider.notifier)
                                  .analyzeReport(file);
                            }
                          } catch (e) {
                            setState(() => _isUploading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('文件处理失败：$e')),
                            );
                          }
                        },
                  child: Container(
                    width: double.infinity,
                    height: 159,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(35, 35, 37, 1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isUploading)
                          CircularProgressIndicator(
                            color: Color.fromRGBO(37, 195, 166, 1),
                          )
                        else
                          Icon(
                            _fileName != null ? Icons.description : Icons.add,
                            color: Color.fromRGBO(37, 195, 166, 1),
                            size: 34,
                          ),
                        if (_fileName != null) ...[
                          SizedBox(height: 8),
                          Text(
                            _fileName!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                        SizedBox(height: 8),
                        Text(
                          _isUploading
                              ? '正在分析...'
                              : _fileName != null
                                  ? '点击更换文件'
                                  : '点击上传PDF文件',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "or give me some context",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 185,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(35, 35, 37, 1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "Describe your Blood Pressure, Cholesterol Levels, Blood Sugar Levels...",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.5),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(35, 35, 37, 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: GestureDetector(
                    onTap: () async {
                      try {
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf'],
                        );

                        if (result != null &&
                            result.files.single.path != null) {
                          final file = File(result.files.single.path!);
                          await ref
                              .read(healthReportProvider.notifier)
                              .analyzeReport(file);
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('文件处理失败：$e')),
                        );
                      }
                    },
                    child: Center(
                      child: Text(
                        "Next",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
