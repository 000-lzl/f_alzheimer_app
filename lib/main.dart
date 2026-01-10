import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'home_page_review.dart';
import 'remind_page.dart';
import 'disseminate_page.dart';
import 'evaluate_page.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'db_helper.dart';
import 'healthedu_page.dart';

//import 'assessment_start_page.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Alzheimer's prediction",
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
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
  int _selectedIndex = 0;
  Map<String, dynamic>? currentUser;
  final DBHelper dbHelper = DBHelper();

  final List<String> _titles = [
    '遊戲訓練',
    '每日提醒設定',
    '阿茲海默風險預測',
    '衛教宣導',
    '登入 / 註冊',
  ];

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
        iconSize: 28,
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

  // 首頁四個遊戲按鈕
  Widget _buildHomePage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        children: [
          _buildGameButton(context, '記憶翻牌', 'assets/image/a.jpg', const GameLevelPage()),
          _buildGameButton(context, '益智拼圖', 'assets/image/a.jpg', PuzzleGamePage()),
          _buildGameButton(context, '看字選色', 'assets/image/a.jpg', const Game2Page()),
          //0_buildGameButton(context, '遊戲回顧', 'assets/image/a.jpg', const GameReviewPage()),
        ],
      ),
    );
  }

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
  }
}