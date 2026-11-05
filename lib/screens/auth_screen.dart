import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  final ValueChanged<Locale> onLocaleChanged;
  const AuthScreen({super.key, required this.onLocaleChanged});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController(), _password = TextEditingController(), _phone = TextEditingController();
  final _sms = TextEditingController(), _name = TextEditingController();
  bool _register = false, _busy = false, _smsSent = false;
  String? _verificationId;
  String? _error;
  bool get ar => Localizations.localeOf(context).languageCode == 'ar';
  String t(String a, String e) => ar ? a : e;

  Future<void> _submit() async {
    setState(() { _busy = true; _error = null; });
    try {
      if (_register) {
        if (!_smsSent) {
          final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email.text.trim(), password: _password.text);
          await cred.user!.updateDisplayName(_name.text.trim());
          await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
            'name': _name.text.trim(), 'email': _email.text.trim(), 'phone': _phone.text.trim(),
            'role': 'user', 'phoneVerified': false, 'createdAt': FieldValue.serverTimestamp(),
          });
          await FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber: _phone.text.trim(),
            verificationCompleted: (phoneCredential) async { await cred.user!.linkWithCredential(phoneCredential); await _markPhoneVerified(); },
            verificationFailed: (e) { if (mounted) setState(() => _error = e.message); },
            codeSent: (id, _) { if (mounted) setState(() { _verificationId = id; _smsSent = true; }); },
            codeAutoRetrievalTimeout: (id) => _verificationId = id,
          );
        } else {
          final id = _verificationId;
          if (id == null) throw Exception(t('تعذر إرسال رمز التحقق. أعد المحاولة.', 'Verification session expired. Try again.'));
          final credential = PhoneAuthProvider.credential(verificationId: id, smsCode: _sms.text.trim());
          await FirebaseAuth.instance.currentUser!.linkWithCredential(credential);
          await _markPhoneVerified();
        }
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email.text.trim(), password: _password.text);
      }
    } on FirebaseAuthException catch (e) { _error = e.message ?? e.code; }
      catch (e) { _error = e.toString(); }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _markPhoneVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'phoneVerified': true});
    if (mounted) setState(() { _register = false; _smsSent = false; });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !_register) return HomeScreen(onLocaleChanged: widget.onLocaleChanged);
    return Directionality(textDirection: ar ? TextDirection.rtl : TextDirection.ltr, child: Scaffold(
      appBar: AppBar(title: const Text('EARN249'), actions: [PopupMenuButton<String>(onSelected: (v) => widget.onLocaleChanged(Locale(v)), itemBuilder: (_) => const [PopupMenuItem(value: 'ar', child: Text('العربية')), PopupMenuItem(value: 'en', child: Text('English'))])]),
      body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(22), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Icon(Icons.poll, color: Color(0xFF20C76A), size: 64), const SizedBox(height: 14),
        Text(t('مرحباً بك في EARN249', 'Welcome to EARN249'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 26),
        if (_register && !_smsSent) ...[
          TextField(controller: _name, decoration: InputDecoration(labelText: t('الاسم الكامل', 'Full name'))), const SizedBox(height: 12),
        ],
        if (_smsSent) ...[
          Text(t('أدخل رمز التحقق المرسل إلى هاتفك', 'Enter the SMS verification code')),
          const SizedBox(height: 12), TextField(controller: _sms, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: t('رمز SMS', 'SMS code'))),
        ] else ...[
          TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: t('البريد الإلكتروني', 'Email'))), const SizedBox(height: 12),
          TextField(controller: _password, obscureText: true, decoration: InputDecoration(labelText: t('كلمة المرور (6 أحرف على الأقل)', 'Password (at least 6 characters)'))), const SizedBox(height: 12),
          if (_register) TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: t('رقم الهاتف مع مفتاح الدولة', 'Phone with country code, e.g. +249...'))),
        ],
        if (_error != null) Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(_error!, style: const TextStyle(color: Colors.redAccent))),
        const SizedBox(height: 12), FilledButton(onPressed: _busy ? null : _submit, child: _busy ? const CircularProgressIndicator() : Text(_smsSent ? t('تحقق من الرقم', 'Verify phone') : _register ? t('إنشاء حساب', 'Create account') : t('تسجيل الدخول', 'Sign in'))),
        TextButton(onPressed: _busy ? null : () => setState(() { _register = !_register; _smsSent = false; _error = null; }), child: Text(_register ? t('لديك حساب؟ تسجيل الدخول', 'Already registered? Sign in') : t('ليس لديك حساب؟ أنشئ حساباً', 'New here? Create an account'))),
      ])))),
    ));
  }
}
