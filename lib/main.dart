import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'models/models.dart';
import 'screens/admin_verification_screen.dart';
import 'screens/landlord_home_screen.dart';
import 'screens/provider_home_screen.dart';
import 'screens/tenant_home_screen.dart';
import 'services/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }
  runApp(const NyumbaHubApp());
}

class NyumbaHubApp extends StatelessWidget {
  const NyumbaHubApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'NyumbaHub Tanzania',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF0B6B4F),
      appBarTheme: const AppBarTheme(centerTitle: true),
    ),
    home: const AuthWrapper(),
  );
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, authSnapshot) {
      if (authSnapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (!authSnapshot.hasData) return const LoginPage();
      return FutureBuilder<AppUser?>(
        future: AuthService().getCurrentUser(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return userSnapshot.data == null ? const LoginPage() : HomePage(user: userSnapshot.data!);
        },
      );
    },
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  final phone = TextEditingController();
  bool registering = false;
  bool loading = false;
  UserRole role = UserRole.tenant;

  Future<void> submit() async {
    if (email.text.trim().isEmpty || password.text.length < 6 || (registering && name.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jaza taarifa sahihi. Password iwe na herufi 6+')));
      return;
    }
    setState(() => loading = true);
    try {
      if (registering) {
        await AuthService().register(email: email.text, password: password.text, name: name.text, phone: phone.text, role: role);
      } else {
        await AuthService().login(email: email.text, password: password.text);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.home_work, size: 64, color: Color(0xFF0B6B4F)),
              const Text('NyumbaHub Tanzania', textAlign: TextAlign.center, style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              if (registering) TextField(controller: name, decoration: const InputDecoration(labelText: 'Jina kamili', border: OutlineInputBorder())),
              if (registering) const SizedBox(height: 12),
              TextField(controller: email, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
              if (registering) ...[const SizedBox(height: 12), TextField(controller: phone, decoration: const InputDecoration(labelText: 'Simu', border: OutlineInputBorder())), const SizedBox(height: 12),
              DropdownButtonFormField<UserRole>(value: role, decoration: const InputDecoration(labelText: 'Aina ya akaunti', border: OutlineInputBorder()), items: UserRole.values.where((r) => r != UserRole.admin).map((r) => DropdownMenuItem(value: r, child: Text(r.name))).toList(), onChanged: (v) => setState(() => role = v!))],
              const SizedBox(height: 20),
              FilledButton(onPressed: loading ? null : submit, child: loading ? const CircularProgressIndicator() : Text(registering ? 'Jisajili' : 'Ingia')),
              TextButton(onPressed: loading ? null : () => setState(() => registering = !registering), child: Text(registering ? 'Nina akaunti tayari' : 'Fungua akaunti')),
            ],
          ),
        ),
      ),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.user});
  final AppUser user;
  @override
  Widget build(BuildContext context) {
    final screen = switch (user.role) {
      UserRole.tenant => TenantHomeScreen(user: user),
      UserRole.landlord => LandlordHomeScreen(user: user),
      UserRole.provider => ProviderHomeScreen(user: user),
      UserRole.admin => AdminVerificationScreen(user: user),
    };
    return Scaffold(
      appBar: AppBar(title: Text('Habari, ${user.name}'), actions: [IconButton(onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout))]),
      body: screen,
    );
  }
}
