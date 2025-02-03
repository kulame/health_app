import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'Home.dart';

class HealthStatusScreen extends StatefulWidget {
  @override
  _HealthStatusScreenState createState() => _HealthStatusScreenState();
}

class _HealthStatusScreenState extends State<HealthStatusScreen> {
  String? _fileName;
  bool _isUploading = false;

  Future<void> _pickAndUploadFile() async {
    try {
      setState(() => _isUploading = true);

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _fileName = result.files.single.name;
        });
        // TODO: 这里添加上传到服务器的逻辑
        // 示例：等待2秒模拟上传
        await Future.delayed(Duration(seconds: 2));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('文件上传失败：$e')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  onTap: _isUploading ? null : _pickAndUploadFile,
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
                              ? '上传中...'
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
                    onTap: _fileName == null
                        ? null
                        : () {
                            // TODO: 在这里添加调用GPT-4分析PDF的逻辑
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Home()),
                            );
                          },
                    child: Center(
                      child: Text(
                        "Next",
                        style: TextStyle(
                          fontSize: 14,
                          color: _fileName == null
                              ? Colors.white.withOpacity(0.5)
                              : Colors.white,
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
