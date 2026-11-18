import 'package:equatable/equatable.dart';

class Achievement extends Equatable {
  final String id;
  final String titleTr;
  final String titleEn;
  final String descriptionTr;
  final String descriptionEn;
  final String iconName;

  const Achievement({
    required this.id,
    required this.titleTr,
    required this.titleEn,
    required this.descriptionTr,
    required this.descriptionEn,
    required this.iconName,
  });

  String getTitle(String lang) => lang == 'tr' ? titleTr : titleEn;
  String getDescription(String lang) =>
      lang == 'tr' ? descriptionTr : descriptionEn;

  static const List<Achievement> catalog = [
    Achievement(
      id: 'first_game',
      titleTr: 'İlk Adım',
      titleEn: 'First Step',
      descriptionTr: 'İlk bilgi yarışması oyununu tamamla.',
      descriptionEn: 'Complete your first trivia game.',
      iconName: 'explore',
    ),
    Achievement(
      id: 'streak_5',
      titleTr: 'Seri Katili',
      titleEn: 'On Fire',
      descriptionTr: 'Üst üste 5 soruyu doğru yanıtla.',
      descriptionEn: 'Answer 5 questions correctly in a row.',
      iconName: 'local_fire_department',
    ),
    Achievement(
      id: 'perfect_10',
      titleTr: 'Kusursuz Gezgin',
      titleEn: 'Flawless Explorer',
      descriptionTr: 'Bir oturumdaki 10 sorunun tamamını doğru bil.',
      descriptionEn: 'Answer all 10 questions correctly in a single session.',
      iconName: 'workspace_premium',
    ),
    Achievement(
      id: 'scholar_50',
      titleTr: 'Coğrafya Bilgini',
      titleEn: 'Geography Scholar',
      descriptionTr: 'Toplam 50 doğru cevaba ulaş.',
      descriptionEn: 'Reach a total of 50 correct answers.',
      iconName: 'school',
    ),
    Achievement(
      id: 'master_2500',
      titleTr: 'Dünya Kaşifi',
      titleEn: 'World Master',
      descriptionTr: 'Toplam 2.500 puana ulaş.',
      descriptionEn: 'Reach a cumulative score of 2,500 points.',
      iconName: 'public',
    ),
    Achievement(
      id: 'expert_survivor',
      titleTr: 'Uzman Meydan Okuyucu',
      titleEn: 'Expert Challenger',
      descriptionTr: 'Expert zorluk seviyesinde en az 7 doğru yap.',
      descriptionEn: 'Score at least 7 correct answers on Expert difficulty.',
      iconName: 'bolt',
    ),
  ];

  @override
  List<Object?> get props => [
        id,
        titleTr,
        titleEn,
        descriptionTr,
        descriptionEn,
        iconName,
      ];
}
