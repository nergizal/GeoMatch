import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/router/app_router.dart';
import '../../../settings/presentation/cubit/app_cubit.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    await context.read<AppCubit>().completeOnboarding();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final isTr = context.watch<AppCubit>().state.languageCode == 'tr';
    final theme = Theme.of(context);

    final slides = [
      (
        icon: Icons.public_rounded,
        title: isTr ? 'Dünyayı Keşfet' : 'Explore the World',
        desc: isTr
            ? '195 ülkenin bayraklarını ve başkentlerini eğlenceli bilgi yarışmalarıyla öğren.'
            : 'Master the flags and capitals of 195 countries through fast-paced trivia.',
      ),
      (
        icon: Icons.bolt_rounded,
        title: isTr ? 'Serini Koru, Puanları Topla' : 'Build Streaks & Score Big',
        desc: isTr
            ? 'Üst üste doğru cevaplarla seri bonusları kazan ve uzman modunda zamana karşı yarış.'
            : 'Chain correct answers for streak bonuses and race the clock in Expert mode.',
      ),
      (
        icon: Icons.offline_bolt_rounded,
        title: isTr ? 'Her Yerde Çevrimdışı Oyna' : '100% Offline Ready',
        desc: isTr
            ? 'İnternet bağlantısına ihtiyaç duymadan uçakta, metroda veya istediğin her yerde oyna.'
            : 'Play anywhere without an internet connection — on flights, commutes, or offline.',
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Text(isTr ? 'Atla' : 'Skip'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: slides.length,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    final item = slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 112,
                          height: 112,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.icon,
                            size: 56,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          item.title,
                          style: theme.textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.desc,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(slides.length, (index) {
                  final active = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () {
                  if (_currentPage < slides.length - 1) {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  } else {
                    _finishOnboarding();
                  }
                },
                child: Text(
                  _currentPage == slides.length - 1
                      ? (isTr ? 'Başlayalım' : 'Get Started')
                      : (isTr ? 'Devam Et' : 'Next'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
