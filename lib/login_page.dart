import 'package:flutter/material.dart';
import 'api.dart';

class LoginPage extends StatefulWidget {
  final Function(Map<String, dynamic> user) onLoginSuccess;
  final bool showRegister;

  const LoginPage({super.key, required this.onLoginSuccess, this.showRegister = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoginMode = true;
  bool _isLoading = false;

  // 登入用
  final _loginAccountController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // 註冊用
  final _regAccountController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  DateTime? _selectedBirthday;

  late final ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(useMock: true);  // 用模擬模式
    // _apiService = ApiService(useMock: false); // 後端好了再改這行
  }
  /*@override
  void initState() {
    super.initState();
    isLoginMode = !widget.showRegister;
    _apiService = ApiService();
  }*/

  Future<void> _pickBirthday() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedBirthday = picked;
        _birthdayController.text =
        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 加上 AppBar，讓頁面更有「頁面感」
      appBar: AppBar(
        title: Text(isLoginMode ? '登入' : '註冊'),
        centerTitle: true,
        // 可選：背景色或 elevation 調整
        // elevation: 0,
        // backgroundColor: Colors.deepPurple,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 可選：如果有 AppBar，這行大標題可以移除或改小
              Text(
                isLoginMode ? '登入' : '註冊',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // 登入表單
              if (isLoginMode) ...[
                TextField(
                  controller: _loginAccountController,
                  decoration: const InputDecoration(
                    labelText: '帳號',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _loginPasswordController,
                  decoration: const InputDecoration(
                    labelText: '密碼',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 32),
                /*ElevatedButton(
                  onPressed: () async {
                    final account = _loginAccountController.text.trim();
                    final password = _loginPasswordController.text.trim();

                    if (account.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('請輸入帳號與密碼')),
                      );
                      return;
                    }

                    try {
                      final user = await _apiService.login(account, password);
                      widget.onLoginSuccess(user);
                      // await _saveToken(user['token']);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('登入失敗：${e.toString()}')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('登入'),
                ),*/
                ElevatedButton(
                  onPressed: _isLoading
                      ? null  // 防止重複點擊
                      : () async {
                    print('【登入】按鈕被點擊');  // 先加這行看 console 是否有輸出

                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      final account = _loginAccountController.text.trim();
                      final password = _loginPasswordController.text.trim();

                      if (account.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('請輸入帳號與密碼')),
                        );
                        return;
                      }

                      print('開始呼叫 login()');
                      final user = await _apiService.login(account, password);
                      print('login() 成功，回傳 user: $user');

                      widget.onLoginSuccess(user);  // 這行要能執行才會跳頁
                    } catch (e) {
                      print('登入錯誤：$e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('登入失敗：${e.toString()}')),
                      );
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  )
                      : const Text('登入'),
                ),
              ],

              // 註冊表單
              if (!isLoginMode) ...[
                TextField(
                  controller: _regAccountController,
                  decoration: const InputDecoration(
                    labelText: '帳號',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_add),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _regPasswordController,
                  decoration: const InputDecoration(
                    labelText: '密碼',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '姓名',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _birthdayController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: '生日',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: _pickBirthday,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _heightController,
                  decoration: const InputDecoration(
                    labelText: '身高 (cm)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.straighten),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: '體重 (kg)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.monitor_weight),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),
                /*ElevatedButton(
                  onPressed: () async {
                    final account = _regAccountController.text.trim();
                    final password = _regPasswordController.text.trim();
                    final name = _nameController.text.trim();
                    final birthday = _birthdayController.text;
                    final heightStr = _heightController.text.trim();
                    final weightStr = _weightController.text.trim();

                    if (account.isEmpty ||
                        password.isEmpty ||
                        name.isEmpty ||
                        birthday.isEmpty ||
                        heightStr.isEmpty ||
                        weightStr.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('請填寫完整資料')),
                      );
                      return;
                    }

                    final height = double.tryParse(heightStr) ?? 160.0;
                    final weight = double.tryParse(weightStr) ?? 50.0;

                    try {
                      final user = await _apiService.register(
                        account: account,
                        password: password,
                        name: name,
                        birthday: birthday,
                        height: height,
                        weight: weight,
                      );
                      widget.onLoginSuccess(user);
                      // await _saveToken(user['token']);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('註冊失敗：${e.toString()}')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('註冊', style: TextStyle(color: Colors.white)),
                ),*/
                ElevatedButton(
                  onPressed: _isLoading
                      ? null  // 防止重複點擊
                      : () async {
                    print('使用者點擊註冊按鈕');

                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      final account = _regAccountController.text.trim();
                      final password = _regPasswordController.text.trim();
                      final name = _nameController.text.trim();
                      final birthday = _birthdayController.text;
                      final heightStr = _heightController.text.trim();
                      final weightStr = _weightController.text.trim();

                      print('註冊資料：帳號=$account, 姓名=$name, 生日=$birthday');

                      if ([
                        account,
                        password,
                        name,
                        birthday,
                        heightStr,
                        weightStr,
                      ].any((e) => e.isEmpty)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('請填寫完整資料')),
                        );
                        return;
                      }

                      final height = double.tryParse(heightStr) ?? 160.0;
                      final weight = double.tryParse(weightStr) ?? 50.0;

                      print('開始呼叫註冊 API');
                      final user = await _apiService.register(
                        account: account,
                        password: password,
                        name: name,
                        birthday: birthday,
                        height: height,
                        weight: weight,
                      );

                      print('註冊 API 成功，回傳 user: $user');

                      // 成功後傳給上層（通常會跳頁或更新狀態）
                      widget.onLoginSuccess(user);

                      // 可選：顯示成功提示
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('註冊成功！')),
                      );
                    } catch (e) {
                      print('註冊錯誤：$e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('註冊失敗：${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                      : const Text('註冊'),
                ),
              ],

              const SizedBox(height: 24),
              TextButton(
                onPressed: () => setState(() => isLoginMode = !isLoginMode),
                child: Text(
                  isLoginMode ? '還沒有帳號？註冊' : '已有帳號？登入',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}