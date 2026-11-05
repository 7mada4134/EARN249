import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'poll_screens.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<Locale> onLocaleChanged;
  const HomeScreen({super.key, required this.onLocaleChanged});
  bool get ar => true;
  @override
  Widget build(BuildContext context) => StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
    stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
    builder: (context, snapshot) {
      final data = snapshot.data?.data() ?? {};
      final admin = data['role'] == 'admin';
      final arabic = Localizations.localeOf(context).languageCode == 'ar';
      String t(String a, String e) => arabic ? a : e;
      return Directionality(textDirection: arabic ? TextDirection.rtl : TextDirection.ltr, child: Scaffold(
        appBar: AppBar(title: const Text('EARN249'), actions: [PopupMenuButton<String>(onSelected: (v) => onLocaleChanged(Locale(v)), itemBuilder: (_) => const [PopupMenuItem(value: 'ar', child: Text('العربية')), PopupMenuItem(value: 'en', child: Text('English'))]), IconButton(onPressed: () async => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout))]),
        floatingActionButton: admin ? FloatingActionButton.extended(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePollScreen())), icon: const Icon(Icons.add), label: Text(t('إنشاء استبيان', 'Create poll'))) : null,
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(padding: const EdgeInsets.all(18), child: Text(admin ? t('لوحة المدير', 'Administrator') : t('الاستبيانات المتاحة', 'Available polls'), style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold))),
          Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('polls').where('status', isEqualTo: 'published').orderBy('createdAt', descending: true).snapshots(),
            builder: (context, polls) {
              if (polls.hasError) return Center(child: Text(t('تعذر تحميل الاستبيانات. تحقق من قواعد Firestore والفهرس.', 'Could not load polls. Check Firestore rules and index.')));
              if (!polls.hasData) return const Center(child: CircularProgressIndicator());
              final docs = polls.data!.docs;
              if (docs.isEmpty) return Center(child: Text(t('لا توجد استبيانات حالياً', 'No polls available yet')));
              return ListView.builder(itemCount: docs.length, itemBuilder: (_, i) {
                final d = docs[i]; final p = d.data();
                return Card(color: const Color(0xFF1B241E), margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7), child: ListTile(
                  title: Text((p['question'] ?? '').toString()), subtitle: Text('${(p['options'] as List?)?.length ?? 0} ${t('خيارات', 'options')}'), trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PollDetailScreen(pollId: d.id, poll: p, admin: admin))),
                ));
              });
            },
          )),
        ]),
      ));
    },
  );
}
