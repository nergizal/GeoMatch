
```markdown
# Data Dictionary - GeoMatch

## 1. Country JSON Schema (`assets/data/countries.json`)

| Alan Adı | Veri Tipi | Zorunlu | Açıklama | Örnek Değer |
| :--- | :--- | :---: | :--- | :--- |
| `code` | `String` | Evet | ISO 3166-1 alpha-2 ülke kodu (küçük harf, bayrak dosya adıyla eşleşir) | `"tr"` |
| `name_en` | `String` | Evet | Ülkenin İngilizce yaygın adı | `"Turkey"` |
| `name_tr` | `String` | Evet | Ülkenin Türkçe yaygın adı | `"Türkiye"` |
| `capitals_en` | `List<String>` | Hayır | İngilizce başkent(ler) listesi (Başkenti yoksa boş liste `[]`) | `["Ankara"]` |
| `capitals_tr` | `List<String>` | Hayır | Türkçe başkent(ler) listesi | `["Ankara"]` |
| `region` | `String` | Evet | Ana kıta / bölge adı | `"Asia"` |
| `subregion` | `String` | Evet | Alt bölge adı | `"Western Asia"` |
| `difficulty` | `int` | Evet | Zorluk seviyesi (1: Easy, 2: Medium, 3: Hard) | `1` |
| `flag_asset` | `String` | Evet | Yerel SVG bayrak varlığının tam yolu | `"assets/flags/tr.svg"` |

## 2. Local Persistence Keys (`SharedPreferences`)

| Key | Tip | Varsayılan | Açıklama |
| :--- | :--- | :---: | :--- |
| `stats_total_score` | `int` | `0` | Kullanıcının tüm oyunlardan topladığı kümülatif puan |
| `stats_games_played` | `int` | `0` | Tamamlanan toplam oyun oturumu sayısı |
| `stats_correct_answers` | `int` | `0` | Toplam doğru cevap sayısı |
| `stats_wrong_answers` | `int` | `0` | Toplam yanlış cevap sayısı |
| `stats_best_score` | `int` | `0` | Tek bir oturumda elde edilen en yüksek skor |
| `stats_highest_streak` | `int` | `0` | Ulaşılan en uzun kesintisiz doğru cevap serisi |
| `unlocked_achievements` | `List<String>` | `[]` | Kilidi açılmış başarım ID'lerinin listesi |
| `settings_is_dark_mode` | `bool` | `false` | Karanlık tema tercihi |
| `settings_sound_enabled` | `bool` | `true` | Ses efektleri açık/kapalı durumu |
| `onboarding_completed` | `bool` | `false` | İlk tanıtım ekranlarının geçilip geçilmediği |