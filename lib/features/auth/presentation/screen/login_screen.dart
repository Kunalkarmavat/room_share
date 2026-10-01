import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:room_share/core/shared/theme.dart';
import 'package:room_share/core/widgets/google_logo.dart';
import 'package:room_share/features/auth/presentation/provider/auth_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  static const _heroImage =
      'https://img.freepik.com/free-photo/modern-luxury-home-with-pool-contemporary-architecture_23-2152016388.jpg?semt=ais_user_personalization&w=740&q=80';

  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider).login();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          /// TOP IMAGE
          SizedBox(
            height: screenHeight * 0.76,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: _heroImage,
              fit: BoxFit.cover,
              alignment: const Alignment(-0.9, 0),
              memCacheWidth: 1080, // keep decode cheap on the UI thread
              placeholder: (_, __) =>
                  const ColoredBox(color: RoomShareColors.divider),
              errorWidget: (_, __, ___) => const ColoredBox(
                color: RoomShareColors.primary,
                child: Center(
                  child: Icon(
                    Icons.home_rounded,
                    size: 96,
                    color: RoomShareColors.onPrimary,
                  ),
                ),
              ),
            ),
          ),

          /// ANIMATED BOTTOM PANEL
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  // minHeight (not a fixed height) => the panel grows with its
                  // content instead of overflowing on small / large-font screens.
                  constraints: BoxConstraints(minHeight: screenHeight * 0.28),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: RoomShareColors.onPrimary,
                    border: Border(
                      top: BorderSide(color: RoomShareColors.primary, width: 2),
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'It feels like a home',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'The best place to find roommates\nfor sharing apartments and rental homes',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          const SizedBox(height: 24),

                          /// GOOGLE BUTTON
                          SizedBox(
                            height: 60,
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: RoomShareColors.background,
                                foregroundColor: Colors.black,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: const BorderSide(
                                    color: RoomShareColors.onSurface,
                                  ),
                                ),
                              ),
                              onPressed: _isLoading ? null : _onLoginPressed,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const CircleAvatar(
                                          radius: 14,
                                          backgroundColor: Colors.white,
                                          child: GoogleLogo(size: 18),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Login with Google',
                                          style: GoogleFonts.inter(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
