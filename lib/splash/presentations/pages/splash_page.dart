import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../auth/presentation/cubit/ auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/splash_cubit.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  String version = "";

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    Future.delayed(
      const Duration(seconds: 2),
          () {
        context.read<AuthCubit>().checkLoginStatus();
      },
    );
    _loadVersion();
    //
    // context.read<AuthCubit>().initialize();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();

    setState(() {
      version = "v${info.version}";
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return
    BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {

        if (!state.isLoading) {

          if (state.isAuthenticated) {

            Navigator.pushReplacementNamed(
              context,
              "/home",
            );

          } else {

            Navigator.pushReplacementNamed(
              context,
              "/login",
            );
          }
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: const FlutterLogo(
                    size: 180,
                    style: FlutterLogoStyle.markOnly,
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    version,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
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
}