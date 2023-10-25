import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // 現在のタブインデックス
  User? _currentUser;

  final List<Widget> _pages = [
    Center(child: Text('Tab 1')),  // 1つ目のタブの中身
    Center(child: Text('Tab 2')),  // 2つ目のタブの中身
    Center(child: Text('Tab 3')),  // 3つ目のタブの中身
    Center(child: Text('Tab 4')),  // 3つ目のタブの中身

  ];



  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;  // <-- 現在のユーザーを取得
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      actions: [
        if (_currentUser != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(child: Text(_currentUser!.email ?? '')),
          ),],),

      body: _pages[_currentIndex],  // 現在のタブインデックスに応じたページを表示
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
          backgroundColor:Colors.blue,
        onTap: (index) {
          setState(() {
            _currentIndex = index;  // タップされたタブのインデックスを更新
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Tab 1',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Tab 2',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tab 3',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Tab 4',
          ),
        ],
      ),
    );
  }
}
