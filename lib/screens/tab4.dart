import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Tab4 extends StatefulWidget {
  @override
  _Tab4State createState() => _Tab4State();
}

class _Tab4State extends State<Tab4> {
  Map<DateTime, List<String>> _events = {};
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  final DateFormat _formatter = DateFormat('yyyy-MM-dd');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _fetchEventsForMonth(_focusedDay);
  }

  Future<void> _fetchEventsForMonth(DateTime date) async {
    String? userId = _auth.currentUser?.uid;
    if (userId == null) return;

    DateTime startOfMonth = DateTime(date.year, date.month, 1);
    DateTime endOfMonth = DateTime(date.year, date.month + 1, 0);

    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('Calendar_video')
        .where('savedAt', isGreaterThanOrEqualTo: _formatter.format(startOfMonth))
        .where('savedAt', isLessThanOrEqualTo: _formatter.format(endOfMonth))
        .get()
        .then((QuerySnapshot querySnapshot) {
      Map<DateTime, List<String>> newEvents = {};
      for (var doc in querySnapshot.docs) {
        DateTime savedDate = _formatter.parse(doc.id); // ドキュメントIDを日付として使用
        List<dynamic> videoIds = List.from(doc['videoIds'] ?? []);
        newEvents[savedDate] = videoIds.cast<String>();
      }
      setState(() {
        _events = newEvents;
      });
    });
  }

  void _onPageChanged(DateTime focusedDay) {
    _fetchEventsForMonth(focusedDay);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    // 選択された日付に関連するイベントを表示する処理
    if (_events.containsKey(selectedDay)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Events'),
          content: SingleChildScrollView(
            child: Column(
              children: _events[selectedDay]!
                  .map((event) => ListTile(title: Text(event)))
                  .toList(),
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TableCalendar(
        firstDay: DateTime.utc(2022, 1, 1),
        lastDay: DateTime.utc(2025, 12, 31),
        focusedDay: _focusedDay,
        onDaySelected: _onDaySelected,
        eventLoader: (day) {
          return _events[day] ?? [];
        },
        onPageChanged: _onPageChanged,
        calendarStyle: CalendarStyle(
          // カスタムスタイルを追加
        ),
        headerStyle: HeaderStyle(
          // ヘッダースタイルのカスタマイズ
        ),
      ),
    );
  }
}
