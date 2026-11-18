// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  print('Acik kaynak ulke veri seti indiriliyor...');

  final client = HttpClient();
  const url =
      'https://raw.githubusercontent.com/mledoze/countries/master/dist/countries.json';

  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();

    if (response.statusCode != 200) {
      stderr.writeln('Veri indirme hatasi: HTTP ${response.statusCode}');
      exit(1);
    }

    final body = await response.transform(utf8.decoder).join();
    final decoded = json.decode(body);

    if (decoded is! List) {
      stderr.writeln('Beklenmeyen veri formati.');
      exit(1);
    }

    final flagsDir = Directory('assets/flags');
    final dataDir = Directory('assets/data');
    if (!flagsDir.existsSync()) flagsDir.createSync(recursive: true);
    if (!dataDir.existsSync()) dataDir.createSync(recursive: true);

    final processedCountries = [];

    for (final raw in decoded) {
      final map = raw as Map<String, Object?>;
      final code = (map['cca2'] as String? ?? '').toLowerCase();
      final isIndependent = map['independent'] as bool? ?? false;
      final isUnMember = map['unMember'] as bool? ?? false;

      // 193 BM uyesi + Vatikan (va) ve Filistin (ps) = 195 ulke
      if (!isUnMember && !isIndependent && code != 'va' && code != 'ps') {
        continue;
      }
      if (code.isEmpty) continue;

      final nameMap = map['name'] as Map<String, Object?>;
      final nameEn = nameMap['common'] as String;

      final translations =
          map['translations'] as Map<String, Object?>? ?? {};
      final turMap = translations['tur'] as Map<String, Object?>?;
      final nameTr = (turMap?['common'] as String?) ?? nameEn;

      final capitalsRaw = map['capital'] as List? ?? [];
      final capitalsEn = capitalsRaw.map((e) => e.toString()).toList();
      final capitalsTr = capitalsEn.map(_translateCapitalToTr).toList();

      final region = map['region'] as String? ?? 'Unknown';
      final subregion = map['subregion'] as String? ?? 'Unknown';
      final area = (map['area'] as num? ?? 0).toDouble();

      // Yuzolcumu ve bilinirlige gore zorluk seviyesi (1: Easy, 2: Medium, 3: Hard)
      final int difficulty;
      if (area >= 300000 || _famousCodes.contains(code)) {
        difficulty = 1;
      } else if (area >= 40000) {
        difficulty = 2;
      } else {
        difficulty = 3;
      }

      final flagAssetPath = 'assets/flags/$code.svg';
      final flagFile = File(flagAssetPath);

      if (!flagFile.existsSync()) {
        final flagUrl = 'https://flagcdn.com/$code.svg';
        final flagReq = await client.getUrl(Uri.parse(flagUrl));
        final flagRes = await flagReq.close();
        if (flagRes.statusCode == 200) {
          final bytes = <int>[];
          await for (final chunk in flagRes) {
            bytes.addAll(chunk);
          }
          await flagFile.writeAsBytes(bytes);
          stdout.write('.');
        } else {
          stderr.writeln('\nUyari: $code bayragi indirilemedi.');
        }
      }

      processedCountries.add({
        'code': code,
        'name_en': nameEn,
        'name_tr': nameTr,
        'capitals_en': capitalsEn,
        'capitals_tr': capitalsTr,
        'region': region,
        'subregion': subregion,
        'difficulty': difficulty,
        'flag_asset': flagAssetPath,
      });
    }

    processedCountries.sort(
      (a, b) => (a['code'] as String).compareTo(b['code'] as String),
    );

    final outputFile = File('assets/data/countries.json');
    const encoder = JsonEncoder.withIndent('  ');
    await outputFile.writeAsString(encoder.convert(processedCountries));

    print('\nTamamlandi! Toplam ${processedCountries.length} ulke islendi.');
    print('JSON kaydedildi: assets/data/countries.json');
  } finally {
    client.close();
  }
}

const _famousCodes = {
  'tr', 'us', 'gb', 'de', 'fr', 'it', 'es', 'ru', 'cn', 'jp',
  'kr', 'br', 'ar', 'ca', 'au', 'in', 'eg', 'za', 'sa', 'ae',
  'gr', 'nl', 'be', 'ch', 'se', 'no', 'az', 'ua', 'pl', 'pt',
};

String _translateCapitalToTr(String capitalEn) {
  const dict = {
    'Athens': 'Atina',
    'Baghdad': 'Bağdat',
    'Baku': 'Bakü',
    'Beijing': 'Pekin',
    'Beirut': 'Beyrut',
    'Belgrade': 'Belgrad',
    'Brussels': 'Brüksel',
    'Bucharest': 'Bükreş',
    'Budapest': 'Budapeşte',
    'Cairo': 'Kahire',
    'Copenhagen': 'Kopenhag',
    'Damascus': 'Şam',
    'Jerusalem': 'Kudüs',
    'Kyiv': 'Kiev',
    'Lisbon': 'Lizbon',
    'London': 'Londra',
    'Moscow': 'Moskova',
    'Nicosia': 'Lefkoşa',
    'Prague': 'Prag',
    'Riyadh': 'Riyad',
    'Rome': 'Roma',
    'Sarajevo': 'Saraybosna',
    'Seoul': 'Seul',
    'Skopje': 'Üsküp',
    'Sofia': 'Sofya',
    'Stockholm': 'Stokholm',
    'Tehran': 'Tahran',
    'Tirana': 'Tiran',
    'Tokyo': 'Tokyo',
    'Vienna': 'Viyana',
    'Warsaw': 'Varşova',
    'Washington, D.C.': 'Vaşington',
  };
  return dict[capitalEn] ?? capitalEn;
}