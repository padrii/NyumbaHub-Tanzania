import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const NyumbaHubApp());
}

class NyumbaHubApp extends StatelessWidget {
  const NyumbaHubApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'NyumbaHub Tanzania',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF0B6B4F)),
    home: const LoginPage(),
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool register = false;
  bool loading = false;
  Future<void> submit() async {
    setState(() => loading = true);
    try {
      if (register) {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email.text.trim(), password: password.text);
        await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({'email': email.text.trim(), 'role': 'tenant', 'is_verified': false, 'created_at': FieldValue.serverTimestamp()});
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text.trim(), password: password.text);
      }
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPage()));
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))); }
    finally { if (mounted) setState(() => loading = false); }
  }
  @override Widget build(BuildContext context) => Scaffold(body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440), child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.home_work, size: 64, color: Color(0xFF0B6B4F)), const Text('NyumbaHub Tanzania', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)), const SizedBox(height: 24), TextField(controller: email, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())), const SizedBox(height: 12), TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())), const SizedBox(height: 16), SizedBox(width: double.infinity, child: FilledButton(onPressed: loading ? null : submit, child: Text(register ? 'Jisajili' : 'Ingia'))), TextButton(onPressed: () => setState(() => register = !register), child: Text(register ? 'Nina akaunti tayari' : 'Fungua akaunti'))]))));
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('NyumbaHub Tanzania'), actions: [IconButton(onPressed: () => FirebaseAuth.instance.signOut().then((_) => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()))), icon: const Icon(Icons.logout))]), body: ListView(padding: const EdgeInsets.all(16), children: [Text('Karibu NyumbaHub', style: Theme.of(context).textTheme.headlineMedium), const SizedBox(height: 16), ...['Tafuta nyumba za kupanga', 'Nyumba nilizohifadhi', 'Book house viewing', 'Omba huduma ya fundi', 'Ongea na landlord'].map((title) => Card(child: ListTile(leading: const Icon(Icons.arrow_forward_ios), title: Text(title), onTap: () {}))) ]);
}
