import 'package:flutter/material.dart';
import 'api.dart';
import 'main.dart';
import 'home_page.dart';

/*class LoginPage extends StatefulWidget {
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
}*/

class LoginPage extends StatefulWidget {
  final Function(Map<String, dynamic> user) onLoginSuccess;
  final bool showRegister;

  const LoginPage({
    super.key,
    required this.onLoginSuccess,
    this.showRegister = false,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoginMode = true;
  bool _isLoading = false;

  bool _isLoggedIn = false;   // ⭐ 新增
  String account = '';       // ⭐ 新增
  // 登入
  final _loginAccountController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // 註冊
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

    isLoginMode = !widget.showRegister;

    // 模擬模式
    //_apiService = ApiService(useMock: true);

    // 後端完成後改成
     _apiService = ApiService(useMock: false);
  }

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

  // ======================
  // 登入
  // ======================

  Future<void> _login() async {
    //final account = _loginAccountController.text.trim();
    final loginAccount = _loginAccountController.text.trim(); // 改名避免遮蔽
    final password = _loginPasswordController.text.trim();

    /*if (account.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請輸入帳號與密碼')),
      );
      return;
    }*/
    if (loginAccount.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請輸入帳號與密碼')),
      );
      return;
    }

    /*setState(() {
      _isLoading = true;
    });*/
    setState(() => _isLoading = true);

    try {
      final user = await _apiService.login(loginAccount, password);
      //widget.onLoginSuccess(user);
      //print("登入成功 user = $user");
      // 成功後直接跳轉到 MainPage，並傳入 user 資訊
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainPage(initialUser: user), // 需要在 MainPage 支援 initialUser
            /*builder: (context) => HomePage(
              account: user['account'], // 這裡帶過去
            ),*/
          ),
        );
      }
      // 成功後直接跳轉到 MainPage，並傳入 user 資訊
      //if (!mounted) return;

      /*setState(() {
        account = user['account']?? account;
        _isLoggedIn = true;
      });*/
      /*widget.onLoginSuccess(user);
      setState(() {
        account = user['account']?.toString() ?? loginAccount;
        _isLoggedIn = true;
      });*/
    } /*catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('登入失敗：$e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }*/
    catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('登入失敗：$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ======================
  // 註冊
  // ======================

  Future<void> _register() async {
    final regaccount = _regAccountController.text.trim();
    final password = _regPasswordController.text.trim();
    final name = _nameController.text.trim();
    final birthday = _birthdayController.text;
    final heightStr = _heightController.text.trim();
    final weightStr = _weightController.text.trim();

    if ([regaccount, password, name, birthday, heightStr, weightStr]
        .any((e) => e.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請填寫完整資料')),
      );
      return;
    }

    final height = double.tryParse(heightStr) ?? 160;
    final weight = double.tryParse(weightStr) ?? 50;

    setState(() {_isLoading = true; });

    try {
      final user = await _apiService.register(
        account: regaccount,
        password: password,
        name: name,
        birthday: birthday,
        height: height,
        weight: weight,
      );

      //if (!mounted) return;
      //widget.onLoginSuccess(user);
      /*setState(() {
        _isLoggedIn = true;
        account = user['account'];
      });*/

      /*final account = user['account'].toString() ?? regaccount;

      setState(() {
        //account = user['account']?.toString() ?? regaccount;
        this.account = account;
        _isLoggedIn = true;
        _isLoading = false;
      });*/
      //print("註冊回傳 user: $user");
      //widget.onLoginSuccess(user);
      if (mounted) {
      Future.microtask(() {
        widget.onLoginSuccess(user);
      }); }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('註冊成功')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('註冊失敗：$e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    /*if (_isLoggedIn) {
      return _buildHomePage();
    }*/

    return Scaffold(
      appBar: AppBar(
        title: Text(isLoginMode ? '登入' : '註冊'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

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
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('登入'),
                ),
              ]

                else ...[
                TextField(
                  controller: _regAccountController,
                  decoration: const InputDecoration(
                    labelText: '帳號',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _regPasswordController,
                  decoration: const InputDecoration(
                    labelText: '密碼',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '姓名',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _birthdayController,
                  readOnly: true,
                  onTap: _pickBirthday,
                  decoration: const InputDecoration(
                    labelText: '生日',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '身高(cm)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '體重(kg)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('註冊'),
                ),
              ],

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  setState(() {
                    isLoginMode = !isLoginMode;
                  });
                },
                child: Text(
                  isLoginMode ? '還沒有帳號？註冊' : '已有帳號？登入',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildHomePage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("主選單"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text("歡迎 $account"),

            const SizedBox(height: 30),

            /*ElevatedButton(
              child: const Text("記憶翻牌"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GameLevelPage()
                  ),
                );
              },
            ),

            ElevatedButton(
              child: const Text("看字選色"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Game2Page()
                  ),
                );
              },
            ),

            ElevatedButton(
              child: const Text("拼圖遊戲"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PuzzleGamePage()
                  ),
                );
              },
            ),*/
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) =>  GameLevelPage(account: account)),
              ),
              child: const Text("記憶翻牌"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) =>  Game2Page(account: account)),
              ),
              child: const Text("看字選色"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) =>  PuzzleGamePage(account: account)),
              ),
              child: const Text("拼圖遊戲"),
            ),
          ],
        ),
      ),
    );
  }

}