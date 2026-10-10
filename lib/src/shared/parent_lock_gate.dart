import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'kids_widgets.dart';

class ParentLockGate extends StatefulWidget {
  const ParentLockGate({
    super.key,
    required this.child,
    this.title = 'التحقق الأبوي',
  });

  final Widget child;
  final String title;

  @override
  State<ParentLockGate> createState() => _ParentLockGateState();
}

class _ParentLockGateState extends State<ParentLockGate> {
  bool _unlocked = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final existingPin = prefs.getString('parent_pin');
    if (existingPin == null) {
      await prefs.setString('parent_pin', '1234');
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _unlock() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(widget.title),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: 'PIN (4 أرقام)',
                hintText: '1234',
              ),
              validator: (value) {
                if (value == null || value.length != 4) {
                  return 'ادخل 4 أرقام';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('تأكيد'),
            ),
          ],
        );
      },
    );

    if (ok != true) return;
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('parent_pin') ?? '1234';
    if (!mounted) return;

    if (controller.text == savedPin) {
      setState(() => _unlocked = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN خاطئ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_unlocked) return widget.child;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: GlassCard(
          borderRadius: 24,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_rounded, size: 54, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'هذه الصفحة محمية للولي',
                style: TextStyle(color: Colors.white.withValues(alpha: .82)),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _unlock,
                icon: const Icon(Icons.pin),
                label: const Text('فتح بواسطة PIN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
