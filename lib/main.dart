import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';//遊戲訓練
import 'home_page_review.dart';//遊戲回顧
import 'remind_page.dart';//每日提醒(日曆)
import 'evaluate_page.dart';//問卷評估
import 'login_page.dart';//登入
import 'healthedu_page.dart';//衛教宣導
import 'profile_page.dart';//註冊
import 'api.dart';

/*
void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "阿茲海默風險預測App",
      theme: ThemeData(
        //primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MainPage(),
    );
  }
}


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;//底部導航欄
  Map<String, dynamic>? currentUser;
  final DBHelper dbHelper = DBHelper();


  final List<String> _titles = [
    '遊戲訓練',
    '每日提醒設定',
    '阿茲海默風險預測',
    '衛教宣導',
    '登入/註冊',
  ];// 用來顯示不同頁面的標題


  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final account = prefs.getString('currentAccount');
    if (account != null) {
      final user = await dbHelper.getUser(account);
      if (user != null) {
        setState(() => currentUser = user);
      }
    }
  }

  void _onItemTap(int index) {
    setState(() => _selectedIndex = index);

  }

  Widget _buildHomePage(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(11.0),
        child: GridView.count(
          shrinkWrap: true, //讓 GridView 根據內容縮小高度
          physics: const NeverScrollableScrollPhysics(),//讓按鈕區域不可滑動
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _buildGameButton(context, '記憶翻牌', 'assets/image/a.jpg', const GameLevelPage()),
            _buildGameButton(context, '益智拼圖', 'assets/image/a.jpg', PuzzleGamePage()),
            _buildGameButton(context, '看字選色', 'assets/image/a.jpg', const Game2Page()),
            //_buildGameButton(context, '遊戲回顧', 'assets/image/a.jpg', const GameReviewPage()),
          ],
        ),
      ),
    );
  }// 首頁四個遊戲按鈕

  Widget _buildGameButton(BuildContext context, String title, String imagePath, Widget page) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey,
        padding: EdgeInsets.zero,
        fixedSize: const Size(150, 170),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 130,
              child: Image.asset(imagePath, fit: BoxFit.cover),
            ),
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }// 首頁四個遊戲按鈕顏色大小


  @override
  Widget build(BuildContext context) {
    Widget body;

    // 第 4 頁：登入/註冊/個人資料
    if (_selectedIndex == 4) {
      body = currentUser != null
          ? ProfilePage(
        userData: currentUser!,
        onLogout: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('currentAccount');
          setState(() {
            currentUser = null;
            _selectedIndex = 4; // 回到登入頁
          });
        },
      )
          : LoginPage(
        showRegister: true,
        onLoginSuccess: (user) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('currentAccount', user['account']);
          setState(() {
            currentUser = user;
            _selectedIndex = 4;
          });
        },
      );
    } else {
      // 其他頁面用 IndexedStack 保留狀態
      body = IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomePage(context),   // 第 0 頁：首頁遊戲
          RemindPage(),              // 第 1 頁：每日提醒
          const AssessmentStartPage(), // 第 2 頁：健康預測
          const AlzheimerEduScreen(),  // 第 3 頁：衛教
          const SizedBox.shrink(),     // 占位，第 4 頁判斷上面
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_titles[_selectedIndex])),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTap,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 18,
        unselectedFontSize: 14,
        iconSize: 30,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '首頁'),
          BottomNavigationBarItem(icon: Icon(Icons.add_alert_outlined), label: '每日提醒'),
          BottomNavigationBarItem(icon: Icon(Icons.accessibility), label: '健康預測'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: '衛教宣導'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle_outlined), label: '登入'),
        ],
      ),
    );
  }


}//所有頁面UI*/
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 ApiService（可選擇在這裡檢查 token 是否存在）
  final api = ApiService();

  // 可選：檢查是否有 token，預先設定（非同步，但不 await）
  // final token = await _loadToken();
  // if (token != null) api.setToken(token);

  runApp(MyApp(apiService: api));
}

class MyApp extends StatelessWidget {
  final ApiService apiService;

  const MyApp({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "阿茲海默風險預測App",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainPage(),
      // 可選：定義命名路由，方便未來跳轉
      routes: {
        '/login': (context) => LoginPage(
          onLoginSuccess: (user) {
            // 這裡可以直接跳回 MainPage，或觸發狀態更新
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // 用來判斷是否已登入（核心變化點）
  bool _isLoggedIn = false;

  // 可選：如果想顯示使用者名稱在 AppBar，可存這裡
  String? _userName;
  Map<String, dynamic>? currentUser;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  /// 檢查是否已登入（透過 token 是否存在）
  Future<void> _checkLoginStatus() async {
    // 這裡可改成讀 flutter_secure_storage 的 token
    // final storage = FlutterSecureStorage();
    // final token = await storage.read(key: 'auth_token');

    // 暫時用 ApiService 內部的 token 判斷（如果有攔截器，會自動帶）
    // 但更準確的方式是嘗試呼叫 /users/me，看是否成功
    try {
      final profile = await ApiService().getProfile();
      setState(() {
        _isLoggedIn = true;
        _userName = profile['name'] as String?;
      });
    } catch (e) {
      setState(() {
        _isLoggedIn = false;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 4) {
      if (_isLoggedIn) {
        // 已登入 → 直接切換到會員中心 tab，顯示 ProfilePage
        setState(() => _selectedIndex = 4);
      } else {
        // 未登入 → 推登入頁
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(
              onLoginSuccess: (user) {
                print('登入成功回調執行！user = $user');

                setState(() {
                  _isLoggedIn = true;
                  _userName = user['name'] as String?;
                  currentUser = user;  // 如果你有這個變數就更新
                });

                // 登入成功後：留在會員中心（顯示 ProfilePage）
                // 如果你想登入後跳回首頁，就改成 _selectedIndex = 0;
                setState(() => _selectedIndex = 4);

                // 關閉登入頁，讓使用者回到主畫面
                Navigator.pop(context);
              },
            ),
          ),
        );
        return;
      }
    }

    setState(() => _selectedIndex = index);
  }

  Widget _buildBody() {
    if (_selectedIndex == 4) {
      // 個人資料頁（已登入狀態）
      return ProfilePage(
        onLogout: () {
          setState(() {
            _isLoggedIn = false;
            _userName = null;
            _selectedIndex = 0; // 登出後跳回首頁
          });
          // ProfilePage 內部已處理 token 清除，這裡只更新 UI 狀態
        },
      );
    }

    // 其他頁面用 IndexedStack 保持狀態
    return IndexedStack(
      index: _selectedIndex,
      children: [
        _buildHomePage(),               // 0: 首頁遊戲
        const RemindPage(),             // 1: 每日提醒
        const AssessmentStartPage(),    // 2: 健康預測
        const AlzheimerEduScreen(),     // 3: 衛教
        const SizedBox.shrink(),        // 4: 占位（個人頁獨立處理）
      ],
    );
  }

  Widget _buildHomePage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(11.0),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _buildGameButton('記憶翻牌', 'assets/image/a.jpg', const GameLevelPage()),
            _buildGameButton('益智拼圖', 'assets/image/a.jpg', const PuzzleGamePage()),
            _buildGameButton('看字選色', 'assets/image/a.jpg', const Game2Page()),
            // _buildGameButton('遊戲回顧', 'assets/image/a.jpg', const GameReviewPage()),
          ],
        ),
      ),
    );
  }

  Widget _buildGameButton(String title, String imagePath, Widget page) {
    return ElevatedButton(
      onPressed: () {
        if (!_isLoggedIn) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('請先登入才能遊玩遊戲')),
          );
          return;
        }
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey,
        padding: EdgeInsets.zero,
        fixedSize: const Size(150, 170),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 130,
              child: Image.asset(imagePath, fit: BoxFit.cover),
            ),
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: _isLoggedIn && _userName != null
            ? [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text('歡迎，$_userName', style: const TextStyle(fontSize: 16)),
          ),
        ]
            : null,
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 18,
        unselectedFontSize: 14,
        iconSize: 30,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '首頁'),
          BottomNavigationBarItem(icon: Icon(Icons.add_alert_outlined), label: '每日提醒'),
          BottomNavigationBarItem(icon: Icon(Icons.accessibility), label: '健康預測'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: '衛教宣導'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle_outlined), label: '會員'),
        ],
      ),
    );
  }
}

// 標題列表（建議改成「會員」而非「登入」）
const List<String> _titles = [
  '遊戲訓練',
  '每日提醒設定',
  '阿茲海默風險預測',
  '衛教宣導',
  '會員中心',
];