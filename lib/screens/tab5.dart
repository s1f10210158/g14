import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:g14/screens/edit_description.dart';
import 'package:g14/screens/edit_email.dart';
import 'package:g14/screens/edit_image.dart';
import 'package:g14/screens/edit_name.dart';
import 'package:g14/screens/edit_phone.dart';
import 'package:g14/widget/display_image_widget.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Tab5 extends StatefulWidget {
  @override
  _Tab5State createState() => _Tab5State();
}

class _Tab5State extends State<Tab5> {
  User? _currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> _profileData = {};

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (_currentUser != null) {
      try {
        // Firestoreからプロファイル情報を取得
        var profileSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .collection('profiles')
            .doc('image') // 'image' ドキュメントにアクセス
            .get();

        String imageUrl;
        if (profileSnapshot.exists && profileSnapshot.data() != null) {
          imageUrl = profileSnapshot.data()!['url']; // 画像のURLを取得
        } else {
          // デフォルトの画像URLを使用
          imageUrl = await FirebaseStorage.instance
              .ref('default_images/default_avatar.png')
              .getDownloadURL();
        }

        if (profileSnapshot.exists && profileSnapshot.data() != null) {
          setState(() {
            _profileData = profileSnapshot.data()!;
            _profileData['image'] = imageUrl;
          });
        } else {
          setState(() {
            _profileData = {
              'name': 'Not set',
              'phone': 'Not set',
              'email': 'Not set',
              'about': 'No description added.',
              'image': imageUrl,
            };
          });
        }
      } catch (e) {
        print('Error loading user profile: $e');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 10,
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  '設定',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Color.fromRGBO(64, 105, 225, 1),
                  ),
                ),
              ),
            ),
            InkWell(
              child: DisplayImage(
                imagePath: _profileData['image'] ?? 'assets/images/default_image.jpg', // 画像のURLまたはデフォルトの画像パス
                onPressed: () {
                  navigateSecondPage(EditImagePage());
                },
              ),
            ),
            buildUserInfoDisplay(_profileData['name'], 'Name', EditNameFormPage()),
            buildUserInfoDisplay(_profileData['phone'], 'Phone', EditPhoneFormPage()),
            buildUserInfoDisplay(_profileData['email'], 'Email', EditEmailFormPage()),
            buildAbout(_profileData['about']),
          ],
        ),
      ),
    );
  }

  Widget buildUserInfoDisplay(String? getValue, String title, Widget editPage) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 1),
          Container(
            width: 350,
            height: 40,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      navigateSecondPage(editPage);
                    },
                    child: Text(
                      getValue ?? 'Not set',
                      style: TextStyle(fontSize: 16, height: 1.4),
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.grey,
                  size: 40.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAbout(String? aboutMeDescription) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell Us About Yourself',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 1),
          Container(
            width: 350,
            height: 200,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: TextButton(
                onPressed: () {
                  navigateSecondPage(EditDescriptionFormPage());
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                  child: Text(
                    aboutMeDescription ?? 'No description added.',
                    style: TextStyle(fontSize: 16, height: 1.4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void navigateSecondPage(Widget editForm) {
    Route route = MaterialPageRoute(builder: (context) => editForm);
    Navigator.push(context, route).then(onGoBack);
  }

  void onGoBack(dynamic value) {
    setState(() {});
  }
}
