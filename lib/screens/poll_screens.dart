import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreatePollScreen extends StatefulWidget { const CreatePollScreen({super.key}); @override State<CreatePollScreen> createState() => _CreatePollScreenState(); }
class _CreatePollScreenState extends State<CreatePollScreen> {
  final q = TextEditingController(); final opts = [TextEditingController(), TextEditingController()]; bool busy = false;
  Future<void> save() async {
    final options = opts.map((e) => e.text.trim()).where((e) => e.isNotEmpty).toList();
    if (q.text.trim().isEmpty || options.length < 2) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل السؤال وخيارين على الأقل'))); return; }
    setState(() => busy = true);
    try { await FirebaseFirestore.instance.collection('polls').add({'question': q.text.trim(), 'options': options, 'status': 'published', 'createdBy': FirebaseAuth.instance.currentUser!.uid, 'createdAt': FieldValue.serverTimestamp()}); if (mounted) Navigator.pop(context); }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
    if (mounted) setState(() => busy = false);
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('إنشاء استبيان')), body: ListView(padding: const EdgeInsets.all(18), children: [TextField(controller: q, decoration: const InputDecoration(labelText: 'السؤال')), const SizedBox(height: 14), ...opts.asMap().entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(controller: e.value, decoration: InputDecoration(labelText: 'الخيار ${e.key + 1}')))), TextButton.icon(onPressed: () => setState(() => opts.add(TextEditingController())), icon: const Icon(Icons.add), label: const Text('إضافة خيار')), const SizedBox(height: 12), FilledButton(onPressed: busy ? null : save, child: Text(busy ? 'جارٍ النشر...' : 'نشر الاستبيان'))]));
}

class PollDetailScreen extends StatefulWidget { final String pollId; final Map<String, dynamic> poll; final bool admin; const PollDetailScreen({super.key, required this.pollId, required this.poll, required this.admin}); @override State<PollDetailScreen> createState() => _PollDetailScreenState(); }
class _PollDetailScreenState extends State<PollDetailScreen> {
  String? selected; bool busy = false;
  Future<void> vote() async {
    if (selected == null) return;
    setState(() => busy = true);
    final uid = FirebaseAuth.instance.currentUser!.uid; final db = FirebaseFirestore.instance;
    final voteRef = db.collection('polls').doc(widget.pollId).collection('responses').doc(uid);
    try { await db.runTransaction((tx) async { final existing = await tx.get(voteRef); if (existing.exists) throw Exception('لقد أجبت على هذا الاستبيان من قبل'); tx.set(voteRef, {'uid': uid, 'option': selected, 'createdAt': FieldValue.serverTimestamp()}); }); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تسجيل إجابتك'))); }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
    if (mounted) setState(() => busy = false);
  }
  @override Widget build(BuildContext context) { final options = List<String>.from(widget.poll['options'] ?? []); return Scaffold(appBar: AppBar(title: const Text('EARN249')), body: ListView(padding: const EdgeInsets.all(18), children: [Text(widget.poll['question'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 18), ...options.map((o) => RadioListTile<String>(value: o, groupValue: selected, title: Text(o), onChanged: widget.admin ? null : (v) => setState(() => selected = v))), if (!widget.admin) FilledButton(onPressed: busy ? null : vote, child: Text(busy ? 'جارٍ الإرسال...' : 'إرسال الإجابة')), if (widget.admin) StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: FirebaseFirestore.instance.collection('polls').doc(widget.pollId).collection('responses').snapshots(), builder: (_, s) => Text('عدد الإجابات: ${s.data?.docs.length ?? 0}'))])); }
}
