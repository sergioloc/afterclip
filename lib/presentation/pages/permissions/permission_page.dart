import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../util/app_colors.dart';
import '../../../util/app_radius.dart';
import '../../../util/app_spacing.dart';
import '../../../util/app_text_styles.dart';
import '../../widgets/page_title.dart';
import '../../widgets/pill_button.dart';

enum PermissionRequestResult { granted, denied, blocked, cancelled }

class PermissionInfo {
  const PermissionInfo({
    required this.permission,
    required this.icon,
    required this.title,
    required this.description,
  });

  final Permission permission;
  final IconData icon;
  final String title;
  final String description;
}

class PermissionPage extends StatefulWidget {
  const PermissionPage({
    super.key,
    required this.title,
    required this.reason,
    required this.permissions,
  });

  final String title;
  final String reason;
  final List<PermissionInfo> permissions;

  static const List<PermissionInfo> _recording = [
    PermissionInfo(
      permission: Permission.camera,
      icon: Icons.photo_camera_outlined,
      title: 'Camera',
      description: 'Used to record your clips.',
    ),
    PermissionInfo(
      permission: Permission.microphone,
      icon: Icons.mic_outlined,
      title: 'Microphone',
      description: 'Used to save audio with your videos.',
    ),
  ];

  static Future<PermissionRequestResult> showRecording(
    BuildContext context,
  ) async {
    final result = await Navigator.of(context).push<PermissionRequestResult>(
      MaterialPageRoute(
        builder: (_) => const PermissionPage(
          title: 'Recording permissions',
          reason:
              'AfterClip only uses your camera and microphone while recording '
              'a clip. Without these permissions, it cannot record video.',
          permissions: _recording,
        ),
      ),
    );
    return result ?? PermissionRequestResult.cancelled;
  }

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage>
    with WidgetsBindingObserver {
  bool _loading = true;
  bool _blocked = false;
  bool _requesting = false;
  List<PermissionInfo> _pending = const [];

  List<Permission> get _pendingPermissions =>
      _pending.map((info) => info.permission).toList();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _evaluate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _evaluate();
    }
  }

  Future<void> _evaluate() async {
    final statuses = await Future.wait(
      widget.permissions.map((info) => info.permission.status),
    );
    final pending = <PermissionInfo>[];
    var blocked = false;
    for (var i = 0; i < widget.permissions.length; i++) {
      final status = statuses[i];
      if (status.isGranted) continue;
      pending.add(widget.permissions[i]);
      if (status.isPermanentlyDenied) blocked = true;
    }

    if (!mounted) return;
    if (pending.isEmpty) {
      Navigator.of(context).pop(PermissionRequestResult.granted);
      return;
    }
    setState(() {
      _pending = pending;
      _blocked = blocked;
      _loading = false;
      _requesting = false;
    });
  }

  Future<void> _request() async {
    final pendingPermissions = _pendingPermissions;
    setState(() => _requesting = true);
    final results = await pendingPermissions.request();
    if (!mounted) return;

    if (results.values.every((status) => status.isGranted)) {
      Navigator.of(context).pop(PermissionRequestResult.granted);
      return;
    }

    final blocked =
        results.values.any((status) => status.isPermanentlyDenied);
    Navigator.of(context).pop(
      blocked
          ? PermissionRequestResult.blocked
          : PermissionRequestResult.denied,
    );
  }

  Future<void> _openSettings() async {
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: PageTitle(widget.title),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.onBackground),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xLarge,
                  AppSpacing.large,
                  AppSpacing.xLarge,
                  AppSpacing.large,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _pending.length == 1
                          ? 'AfterClip needs this permission to record your '
                                'clips. It is only used while you are recording.'
                          : widget.reason,
                      style: AppTextStyles.paragraph.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xLarge),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _pending.length + (_blocked ? 1 : 0),
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.medium),
                        itemBuilder: (context, index) {
                          if (_blocked && index == _pending.length) {
                            return _buildBlockedNotice();
                          }
                          return _buildPermissionCard(_pending[index]);
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.large),
                    _buildActions(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPermissionCard(PermissionInfo info) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(info.icon, color: AppColors.primary, size: 22),
          const SizedBox(width: AppSpacing.large),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.title,
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxSmall),
                Text(
                  info.description,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedNotice() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_outline, color: AppColors.error, size: 22),
          const SizedBox(width: AppSpacing.large),
          Expanded(
            child: Text(
              'You denied this permission, and Android will not ask again. '
              'Enable it in your device settings.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final enabled = !_requesting;
    return Column(
      children: [
        PillButton(
          expand: true,
          label: _blocked ? 'Open settings' : 'Continue',
          foregroundColor: enabled ? AppColors.onPrimary : AppColors.outline,
          backgroundColor: enabled ? AppColors.primary : AppColors.surface,
          splashColor: AppColors.onPrimary.withValues(alpha: 0.16),
          onPressed: enabled
              ? (_blocked ? _openSettings : _request)
              : null,
        ),
        const SizedBox(height: AppSpacing.small),
        PillButton(
          expand: true,
          label: 'Not now',
          foregroundColor: AppColors.outline,
          splashColor: AppColors.onBackground.withValues(alpha: 0.12),
          onPressed: enabled
              ? () => Navigator.of(context)
                  .pop(PermissionRequestResult.cancelled)
              : null,
        ),
      ],
    );
  }
}
