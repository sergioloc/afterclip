import 'package:flutter/material.dart';
import '../../../util/app_colors.dart';
import '../../../util/app_spacing.dart';
import '../../../util/app_text_styles.dart';
import '../../widgets/page_indicator.dart';
import '../../widgets/page_title.dart';
import '../../widgets/pill_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.onCompleted});

  final VoidCallback onCompleted;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingStep {
  const _OnboardingStep({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const List<_OnboardingStep> _steps = [
    _OnboardingStep(
      icon: Icons.movie_filter,
      title: 'AfterClip',
      body: 'Capture videos without seeing them until 24 hours later.',
    ),
    _OnboardingStep(
      icon: Icons.videocam,
      title: 'Grabar',
      body:
          'Switch between the front and rear camera, then capture the moment.',
    ),
    _OnboardingStep(
      icon: Icons.video_library,
      title: 'Organizar',
      body: 'Organize your videos into albums and keep every memory together.',
    ),
  ];

  final PageController _pageController = PageController();
  int _index = 0;

  bool get _isLast => _index == _steps.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _next() {
    if (_isLast) {
      widget.onCompleted();
      return;
    }
    _goTo(_index + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _steps.length,
                onPageChanged: (index) => setState(() => _index = index),
                itemBuilder: (context, index) => _StepView(step: _steps[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xLarge,
                AppSpacing.small,
                AppSpacing.xLarge,
                AppSpacing.xLarge,
              ),
              child: Column(
                children: [
                  PageIndicator(
                    count: _steps.length,
                    currentIndex: _index,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.onSurface,
                  ),
                  const SizedBox(height: AppSpacing.xLarge),
                  PillButton(
                    label: _isLast ? 'Empezar' : 'Siguiente',
                    foregroundColor: AppColors.onPrimary,
                    splashColor: AppColors.onPrimary.withValues(alpha: 0.16),
                    backgroundColor: AppColors.primary,
                    expand: true,
                    onPressed: _next,
                  ),
                  if (!_isLast)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.small),
                      child: PillButton(
                        label: 'Saltar',
                        foregroundColor: AppColors.onSurface,
                        splashColor: AppColors.surface,
                        onPressed: widget.onCompleted,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepView extends StatelessWidget {
  const _StepView({required this.step});

  final _OnboardingStep step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(step.icon, size: 44, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.xxLarge),
          PageTitle(step.title),
          const SizedBox(height: AppSpacing.xxLarge),
          Text(
            step.body,
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle.copyWith(color: AppColors.onSurface),
          ),
        ],
      ),
    );
  }
}
