import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:room_share/core/shared/theme.dart';
import 'package:room_share/features/auth/presentation/provider/auth_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5), // start lower
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward(); // start animation when page loads
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(authControllerProvider);

    return Scaffold(
      body: Stack(
        children: [
          /// 🔹 TOP IMAGE
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.76,
            width: double.infinity,
            child: Image.network(
              'https://img.freepik.com/free-photo/modern-luxury-home-with-pool-contemporary-architecture_23-2152016388.jpg?semt=ais_user_personalization&w=740&q=80',
              fit: BoxFit.cover,
              alignment: const AlignmentDirectional(-0.9, 0),
            ),
          ),

          /// 🔹 ANIMATED BOTTOM CONTAINER
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.28,
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: RoomShareColors.onPrimary,
                    border: Border(
                      top: BorderSide(
                                color: RoomShareColors.primary,

                        width: 2,
                      ),
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),

                      const Text(
                        "It feels like a home",
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "The best place to find roommates\nfor sharing apartments and rental homes",
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                        ),
                      ),

                      const Spacer(),

                      /// 🔹 GOOGLE BUTTON
                      SizedBox(
                        height: 66,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: RoomShareColors.background,
                            foregroundColor: Colors.black,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(
                                color: RoomShareColors.onSurface
                              ),
                            ),
                          ),
                          onPressed: () {
                            controller.login();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                            
                     

                                CircleAvatar(
                                maxRadius: 14,
                                backgroundColor: Colors.white,
                                child: Image.network(
                                  
                                  "https://firebasestorage.googleapis.com/v0/b/flutterbricks-public.appspot.com/o/crypto%2Fsearch%20(2).png?alt=media&token=24a918f7-3564-4290-b7e4-08ff54b3c94c",
                                  width: 20,
                                ),
                              ),


                                       const SizedBox(width: 12),
                               Text(
                                "Login with Google ",
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,

                                  
                                )
                              ),

                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
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