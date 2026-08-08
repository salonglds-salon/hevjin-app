import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/theme.dart';
import '../chat/chat_screen.dart';

class MatchScreen extends StatefulWidget {
  final String matchId;
  final String otherUserId;
  final String otherName;
  final String? otherAvatar;
  final String? myAvatar;
  final bool preview;

  const MatchScreen({
    super.key,
    required this.matchId,
    required this.otherUserId,
    required this.otherName,
    this.otherAvatar,
    this.myAvatar,
    this.preview = false,
  });

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entry;
  late final AnimationController _pulse;
  late final AnimationController _float;
  final TextEditingController _msg = TextEditingController();
  bool _sending = false;
  bool _sent = false;

  static const List<String> _quick = [
    '\u{1F44B}', '\u{1F60A}', '\u2764\uFE0F', '\u{1F60D}', '\u{1F339}',
  ];

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _float = AnimationController(
        vsync: this, duration: const Duration(seconds: 12))..repeat();
  }

  @override
  void dispose() {
    _entry.dispose();
    _pulse.dispose();
    _float.dispose();
    _msg.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _msg.text.trim();
    if (text.isEmpty || _sending) return;
    if (widget.preview) {
      setState(() => _sent = true);
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) Navigator.of(context).pop();
      return;
    }
    setState(() => _sending = true);
    try {
      final uid = Supabase.instance.client.auth.currentUser!.id;
      await Supabase.instance.client.from('messages').insert({
        'match_id': widget.matchId,
        'sender_id': uid,
        'content': text,
      });
      if (!mounted) return;
      setState(() { _sending = false; _sent = true; });
      _msg.clear();
      await Future.delayed(const Duration(milliseconds: 550));
      if (!mounted) return;
      _openChat();
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nachricht konnte nicht gesendet werden'),
          backgroundColor: HevjinTheme.error,
        ),
      );
    }
  }

  void _openChat() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => ChatScreen(
        matchId: widget.matchId,
        otherName: widget.otherName,
        otherAvatar: widget.otherAvatar,
        otherUserId: widget.otherUserId,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final slide = CurvedAnimation(parent: _entry, curve: Curves.easeOutBack);
    final fade = CurvedAnimation(parent: _entry, curve: Curves.easeIn);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2D2016), Color(0xFF5C3A28)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _float,
                  builder: (_, __) => CustomPaint(
                    painter: _FloatingHeartsPainter(_float.value),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _avatars(slide),
                        const SizedBox(height: 34),
                        FadeTransition(
                          opacity: fade,
                          child: Column(
                            children: [
                              const Text(
                                'Es ist ein Match!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                  shadows: [
                                    Shadow(color: Color(0x99E02020), blurRadius: 18),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Du und ${widget.otherName} m\u00f6gen euch.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        FadeTransition(opacity: fade, child: _quickRow()),
                        const SizedBox(height: 14),
                        FadeTransition(opacity: fade, child: _inputRow()),
                        const SizedBox(height: 18),
                        FadeTransition(
                          opacity: fade,
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              'Weiter st\u00f6bern',
                              style: TextStyle(
                                color: HevjinTheme.secondaryLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatars(Animation<double> slide) {
    return SizedBox(
      height: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) {
              final t = Curves.easeInOut.transform(_pulse.value);
              return Transform.scale(
                scale: 0.94 + t * 0.12,
                child: Icon(
                  Icons.favorite,
                  size: 200,
                  color: HevjinTheme.secondary.withOpacity(0.16 + t * 0.10),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: slide,
            builder: (_, __) {
              final dx = (1 - slide.value) * 90;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.translate(
                    offset: Offset(-dx, 0),
                    child: _avatar(widget.myAvatar, Icons.person),
                  ),
                  Transform.translate(
                    offset: Offset(dx, 0),
                    child: _avatar(widget.otherAvatar, Icons.person_outline),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _avatar(String? url, IconData fallback) {
    final has = url != null && url.isNotEmpty;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: -8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3.5),
        boxShadow: [
          BoxShadow(
            color: HevjinTheme.secondary.withOpacity(0.45),
            blurRadius: 22,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipOval(
        child: SizedBox(
          width: 116,
          height: 116,
          child: has
              ? Image.network(url, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _ph(fallback))
              : _ph(fallback),
        ),      ),
    );
  }

  Widget _ph(IconData icon) => Container(
        color: const Color(0xFF8B3A0F),
        alignment: Alignment.center,
        child: Icon(icon, size: 48, color: Colors.white70),
      );

  Widget _quickRow() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      children: _quick.map((e) {
        return GestureDetector(
          onTap: () {
            _msg.text = _msg.text + e;
            _msg.selection = TextSelection.collapsed(offset: _msg.text.length);
            setState(() {});
          },
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.12),
              border: Border.all(color: Colors.white24),
            ),
            child: Text(e, style: const TextStyle(fontSize: 22)),
          ),
        );
      }).toList(),
    );
  }

  Widget _inputRow() {
    return Container(
      padding: const EdgeInsets.only(left: 18, right: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msg,
              enabled: !_sending && !_sent,
              style: const TextStyle(color: Colors.white),
              cursorColor: HevjinTheme.secondaryLight,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: const InputDecoration(
                hintText: 'Sag etwas Nettes ...',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
            ),
          ),
          if (_sending)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            )
          else
            IconButton(
              onPressed: _sent ? null : _send,
              icon: Icon(
                _sent ? Icons.check : Icons.send_rounded,
                color: _sent ? HevjinTheme.success : HevjinTheme.secondaryLight,
              ),
            ),
        ],
      ),
    );
  }
}

class _FloatingHeartsPainter extends CustomPainter {
  final double t;
  _FloatingHeartsPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(7);
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 14; i++) {
      final baseX = rnd.nextDouble() * size.width;
      final speed = 0.5 + rnd.nextDouble() * 0.9;
      final phase = rnd.nextDouble();
      final prog = (t * speed + phase) % 1.0;
      final y = size.height * (1.05 - prog * 1.15);
      final sway = math.sin((prog * 2 * math.pi) + i) * 22;
      final s = 6.0 + rnd.nextDouble() * 9.0;
      final op = (math.sin(prog * math.pi) * 0.30).clamp(0.0, 0.30);
      paint.color = HevjinTheme.secondary.withOpacity(op);
      _heart(canvas, Offset(baseX + sway, y), s, paint);
    }
  }

  void _heart(Canvas canvas, Offset c, double s, Paint p) {
    final path = Path();
    path.moveTo(c.dx, c.dy + s * 0.75);
    path.cubicTo(c.dx - s * 1.4, c.dy - s * 0.35, c.dx - s * 0.5,
        c.dy - s * 1.15, c.dx, c.dy - s * 0.35);
    path.cubicTo(c.dx + s * 0.5, c.dy - s * 1.15, c.dx + s * 1.4,
        c.dy - s * 0.35, c.dx, c.dy + s * 0.75);
    path.close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _FloatingHeartsPainter old) => old.t != t;
}
