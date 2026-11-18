
```markdown
# System Architecture - GeoMatch

## 1. Architectural Pattern
GeoMatch, **Feature-First Clean Architecture** yaklaşımı ile tasarlanmıştır. Kod tabanı teknik katmanlara göre değil, işlevsel özelliklere (`features/`) göre bölünmüştür. Her özellik kendi içinde **Data**, **Domain** ve **Presentation** katmanlarına ayrılır.

### Dependency Rule (Bağımlılık Kuralı)
Bağımlılıklar her zaman dıştan içe doğrudur:
`Presentation (UI & Cubit) ---> Domain (Entities, UseCases, Repository Interfaces) <--- Data (Models, DataSources, Repository Implementations)`

*Domain katmanı hiçbir Flutter widget'ına veya dış pakete (SharedPreferences vb.) bağımlı değildir. Saf Dart kodudur.*

## 2. Folder Structure (`lib/`)

```text
lib/
├── main.dart
├── app/
│   ├── app.dart                 # MaterialApp, BlocProvider & Theme konfigürasyonu
│   ├── di/
│   │   └── injection.dart       # get_it Dependency Injection kayıtları
│   ├── router/
│   │   └── app_router.dart      # Merkezi sayfa yönlendirme (Navigation)
│   └── theme/
│       ├── app_colors.dart      # Light & Dark renk paleti
│       ├── app_text_styles.dart # Tipografi ölçeği
│       └── app_theme.dart       # ThemeData tanımları
├── core/
│   ├── constants/               # Sabitler (asset yolları, puan katsayıları)
│   ├── error/                   # Failure ve Exception sınıfları
│   └── utils/                   # Yardımcı sınıflar
└── features/
    ├── game/                    # Çekirdek Oyun Özelliği
    │   ├── data/
    │   │   ├── datasources/     # CountryLocalDataSource (JSON okuma)
    │   │   ├── models/          # CountryModel (JSON serialization)
    │   │   └── repositories/    # CountryRepositoryImpl
    │   ├── domain/
    │   │   ├── entities/        # Country, Question, GameSession, GameConfig
    │   │   ├── repositories/    # CountryRepository (Abstract Interface)
    │   │   └── services/        # QuestionGenerator, ScoreCalculator
    │   └── presentation/
    │       ├── cubit/           # GameCubit & GameState
    │       ├── pages/           # GameModePage, DifficultyPage, GamePage, ResultPage
    │       └── widgets/         # FlagCard, OptionButton, ScoreHeader, TimerBar
    ├── home/                    # Ana Ekran, Splash & Onboarding
    ├── stats/                   # İstatistikler & Başarımlar (Achievements)
    └── settings/                # Tema, Ses ve Veri Sıfırlama Ayarları