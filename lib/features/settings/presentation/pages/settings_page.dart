import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../cubit/app_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final state = context.watch<AppCubit>().state;
    final isTr = state.languageCode == 'tr';

    return Scaffold(
      appBar: AppBar(
        title: Text(isTr ? 'Ayarlar' : 'Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(isTr ? 'Karanlık Tema' : 'Dark Mode'),
                    subtitle: Text(
                      isTr
                          ? 'Göz yormayan gece görünümü'
                          : 'Low-glare dark appearance',
                    ),
                    secondary: const Icon(Icons.dark_mode_outlined),
                    value: state.isDarkMode,
                    onChanged: cubit.toggleDarkMode,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language_rounded),
                    title: Text(isTr ? 'Uygulama Dili' : 'Language'),
                    trailing: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'tr', label: Text('TR')),
                        ButtonSegment(value: 'en', label: Text('EN')),
                      ],
                      selected: {state.languageCode},
                      onSelectionChanged: (selection) {
                        cubit.changeLanguage(selection.first);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.errorLight,
                ),
                title: Text(
                  isTr ? 'İlerlemeyi Sıfırla' : 'Reset All Progress',
                  style: const TextStyle(color: AppColors.errorLight),
                ),
                subtitle: Text(
                  isTr
                      ? 'Tüm skorlar, seriler ve başarımlar silinir'
                      : 'Clears all scores, streaks, and achievements',
                ),
                onTap: () => _confirmReset(context, cubit, isTr),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset(
    BuildContext context,
    AppCubit cubit,
    bool isTr,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isTr ? 'Emin misiniz?' : 'Are you sure?'),
        content: Text(
          isTr
              ? 'Tüm oyun geçmişiniz ve başarımlarınız kalıcı olarak sıfırlanacak.'
              : 'All your game stats and unlocked badges will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(isTr ? 'İptal' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              isTr ? 'Sıfırla' : 'Reset',
              style: const TextStyle(color: AppColors.errorLight),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await cubit.resetProgress();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isTr ? 'İlerleme sıfırlandı.' : 'Progress reset.'),
        ),
      );
    }
  }
}
