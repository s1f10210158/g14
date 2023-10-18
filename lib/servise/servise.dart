import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 通信の流れをまとめておくサービスクラス
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;


  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
  /// サインイン
  Future<void> signIn() async {
    /* Google OAuth と通信 */

    // あらかじめ登録しておいたクライアントID
    const clientId = '359218122786-vtf5m08s3cjr0309alcvj2err1008oor.apps.googleusercontent.com';

    // アプリが知りたい情報
    const scopes = [
      'openid', // 他サービス連携用のID
      'profile', // 住所や電話番号
      'email', // メールアドレス
    ];

    // Googleでサインイン の画面へ飛ばす
    final request = GoogleSignIn(clientId: clientId, scopes: scopes);
    final response = await request.signIn();

    // 受け取ったデータの中からアクセストークンを取り出す
    final authn = await response?.authentication;
    final accessToken = authn?.accessToken;

    // アクセストークンが null だったら中止
    if (accessToken == null) {
      return;
    }

    /* Firebase と通信 */

    // Firebaseへアクセストークンを送る
    final oAuthCredential = GoogleAuthProvider.credential(
      accessToken: accessToken,
    );
    await FirebaseAuth.instance.signInWithCredential(
      oAuthCredential,
    );

    /* Googleサインインを使わないときは これだけで十分 */

    // await FirebaseAuth.instance.signInWithEmailAndPassword(
    //   email: 'ここにメールアドレス',
    //   password: 'ここにパスワード',
    // );
  }

  /// サインアウト
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}