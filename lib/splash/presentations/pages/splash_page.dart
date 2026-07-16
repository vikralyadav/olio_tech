import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../cubit/splash_cubit.dart';
import '../cubit/splash_state.dart';

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

    _loadVersion();

    context.read<SplashCubit>().initialize();
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
    return BlocListener<SplashCubit, SplashStatus>(
      listener: (context, state) {
        if (state == SplashStatus.authenticated) {
          Navigator.pushReplacementNamed(context, "/home");
        }

        if (state == SplashStatus.unauthenticated) {
          Navigator.pushReplacementNamed(context, "/login");
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