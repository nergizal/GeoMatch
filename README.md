# 🌍 GeoMatch — Offline-First Geography Trivia & Flag Quiz
<img width="295" height="615" alt="Ekran Resmi 2026-11-18 16 22 49" src="https://github.com/user-attachments/assets/eeb67fa7-258a-4e4c-910c-f10db1952160" />

<img width="284" height="600" alt="Ekran Resmi 2026-11-18 16 21 56" src="https://github.com/user-attachments/assets/324043ad-f36a-4ce4-b166-2fa5b1652c3c" />


**GeoMatch**, 195 ülkenin bayraklarını, başkentlerini ve coğrafi konumlarını tamamen çevrimdışı (offline-first) bir mimariyle öğreten, yüksek performanslı bir Flutter mobil bilgi yarışması oyunudur.

Proje; **Feature-First Clean Architecture**, **BLoC (Cubit)** durum yönetimi, **Dependency Injection (`get_it`)**, deterministik soru üretim algoritmaları ve **Aralıklı Tekrar (Spaced Repetition) Tabanlı Hata Defteri** mekanikleri üzerine inşa edilmiştir.

---

##  Temel Özellikler

* **100% Offline-First Mimari:** İlk kurulumdan sonra internet bağlantısına ihtiyaç duymadan 195 ülke verisi (`countries.json`) ve 195 vektörel SVG bayrak varlığı (`assets/flags/*.svg`) ile kesintisiz çalışır.
* **3 Farklı Oyun Modu:**
  * **Flag Quiz (Bayrak Bilmece):** Gösterilen vektörel bayrağın hangi ülkeye ait olduğunu tahmin etme.
  * **Capital Quiz (Başkent Bulma):** Verilen ülkenin başkentini eşleştirme.
  * **Country Quiz (Başkentten Ülkeye):** Verilen başkentin hangi ülkeye ait olduğunu bulma.
* **4 Zorluk Kademesi:** *Easy*, *Medium*, *Hard* ve soru başına **10 saniyelik** geri sayım sayacı içeren *Expert* modu.
* **Dinamik Puanlama & Seri (Streak) Sistemi:**
  * Her doğru cevap **+100 puan**.
  * Üst üste 3 doğru cevapta **+50 seri bonusu**, 5 ve katlarında **+100 seri bonusu**.
  * *Expert* modunda kalan her tam saniye için **+5 hız bonusu**.
* **Hata Defteri (Mistake Notebook):** Oyunlarda yanlış bilinen veya süresi dolan ülkeleri otomatik olarak yerel hafızada biriktirir. Oyuncu yalnızca hata yaptığı ülkelerden oluşan özel tekrar oturumları başlatabilir; doğru bildiği ülkeler listeden otomatik temizlenir.
* **Başarımlar & Kalıcı İstatistikler:** Toplam puan, en yüksek skor, en uzun seri, doğruluk oranı ve 6 farklı başarım rozeti cihaz hafızasında kalıcı olarak tutulur.
* **Çift Dil & Tema Desteği:** Türkçe (`TR`) / İngilizce (`EN`) anlık dil geçişi ve WCAG AA kontrast standartlarına uygun Light / Dark tema desteği.

---

## 🏗️ Sistem Mimarisi (Feature-First Clean Architecture)

Kod tabanı teknik katmanlara göre değil, işlevsel özelliklere (`features/`) göre bölünmüştür. Bağımlılık kuralı (Dependency Rule) gereği `Domain` katmanı hiçbir Flutter widget'ına veya dış kütüphaneye bağımlı değildir:

```text
Presentation (Pages, Widgets, Cubits)
       │
       ▼
Domain (Entities, Repository Interfaces, QuestionGenerator, ScoreCalculator)
       ▲
       │
Data (Models, LocalDataSources, Repository Implementations, SharedPreferences)
```

### Klasör Yapısı

```text
GeoMatch/
├── assets/
│   ├── data/countries.json         # 195 ülkenin TR/EN isim, başkent, bölge ve zorluk verisi
│   └── flags/*.svg                 # 195 ülkenin yüksek çözünürlüklü vektörel SVG bayrakları
├── docs/                           # SRS, Use Cases, Architecture & Data Dictionary dokümanları
├── lib/
│   ├── app/
│   │   ├── app.dart                # MaterialApp, BlocProvider & Theme konfigürasyonu
│   │   ├── di/injection.dart       # get_it Service Locator kayıtları
│   │   ├── router/app_router.dart  # Merkezi isimlendirilmiş sayfa yönlendirmesi
│   │   └── theme/                  # Light & Dark renk paleti ve tipografi ölçeği
│   ├── core/
│   │   └── error/exceptions.dart   # Özel hata sınıfları (CacheException, GameEngineException)
│   └── features/
│       ├── game/                   # Oyun motoru, soru üretimi, puanlama ve aktif oyun UI
│       ├── home/                   # Onboarding ve Ana Ekran
│       ├── progress/               # İstatistikler, Başarımlar ve Hata Defteri
│       ├── results/                # Oyun sonu özet ekranı
│       └── settings/               # Tema, dil ve ilerleme sıfırlama ayarları
├── test/                           # Domain Unit Testleri, BLoC Testleri & Persistence Testleri
└── tool/
    └── fetch_countries.dart        # Açık kaynak veri ve bayrak indirme CLI scripti
```

---

## ⚙️ Algoritmik Tasarım & Durum Yönetimi

* **Soru Üretim Algoritması (`QuestionGenerator`):**
  * Başkent modlarında başkenti bulunmayan bölgeler iş kuralı (`BR-01`) gereği otomatik filtrelenir.
  * Tekrarsız hedef seçimi için **Fisher-Yates Shuffle** kullanılır; aynı oturumda aynı ülkenin iki kez sorulma olasılığı %0'dır.
  * Çeldiriciler (yanlış şıklar) öncelikli olarak hedef ülkeyle **aynı kıtadan (`region`)** seçilerek gerçekçi ve eğitici seçenekler sunulur.
  * **Zaman Karmaşıklığı:** $O(K \cdot N)$ ($N = 195$ ülke, $K = 10$ soru için yürütme süresi $< 1\text{ ms}$).
* **Durum Yönetimi (`GameCubit` & `AppCubit`):**
  * Oyun akışı Dart 3 `sealed class` tabanlı sonlu durum makinesi (`GameInitial` $\rightarrow$ `GameLoading` $\rightarrow$ `GamePlaying` $\rightarrow$ `GameAnswered` $\rightarrow$ `GameCompleted`) ile yönetilir.
  * `GameCubit` her yeni oturumda temiz bir bellek durumu için `Factory` olarak, `AppCubit` ise uygulama genelinde `LazySingleton` olarak enjekte edilir.

---

## 🧪 Test Altyapısı

Projede iş mantığı, durum geçişleri ve kalıcı depolama katmanları otomatik testlerle doğrulanmaktadır:

* **Domain Unit Testleri:** Puanlama kuralları, seri/süre bonusları ve sabit tohumlu (`Seeded Random`) deterministik soru üretimi.
* **BLoC Durum Testleri (`bloc_test` & `mocktail`):** Oyun başlatma, cevap sonrası şık kilitleme (çift tıklama koruması) ve Hata Defteri ülke kodlarının takibi.
* **Persistence Testleri:** `SharedPreferences` mock ortamında istatistik biriktirme, rozet kilidi açma ve ilerleme sıfırlama.

```bash
# Tüm testleri çalıştırmak için:
flutter test

# Statik kod analizi için:
flutter analyze
```

---

## 🚀 Kurulum ve Çalıştırma

1. **Depoyu klonlayın:**
   ```bash
   git clone [https://github.com/nergizal/GeoMatch.git](https://github.com/nergizal/GeoMatch.git)
   cd GeoMatch
   ```
2. **Bağımlılıkları yükleyin:**
   ```bash
   flutter pub get
   ```
3. **Uygulamayı başlatın:**
   ```bash
   flutter run
   ```

---

## 🛠️ Teknoloji Yığını

* **Framework:** Flutter & Dart 3
* **State Management:** `flutter_bloc` (Cubit), `equatable`
* **Dependency Injection:** `get_it`
* **Local Storage:** `shared_preferences`
* **UI & Assets:** `flutter_svg`, `google_fonts` (Poppins)
* **Testing:** `flutter_test`, `bloc_test`, `mocktail`
