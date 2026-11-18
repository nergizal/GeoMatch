# Software Requirements Specification (SRS) - GeoMatch

## 1. Functional Requirements (Fonksiyonel Gereksinimler)

### Oyun Modları ve Oturum Yönetimi
- **FR-01 (Oyun Modu Seçimi):** Kullanıcı ana ekrandan veya oyun modu ekranından *Flag Quiz*, *Capital Quiz* ve *Country Quiz* modlarından birini seçebilmelidir.
- **FR-02 (Zorluk Seviyesi Seçimi):** Kullanıcı oyun başlamadan önce *Easy*, *Medium*, *Hard* ve *Expert* zorluk seviyelerinden birini seçebilmelidir.
- **FR-03 (Oyun Oturumu Yapısı):** Her oyun oturumu tam olarak **10 sorudan** oluşmalıdır.
- **FR-04 (Soru Tekrarını Önleme):** Aynı oyun oturumu içerisinde aynı ülke iki kez doğru cevap olarak sorulmamalıdır.
- **FR-05 (Seçenek Üretimi):** Her soru için 1 doğru cevap ve aynı zorluk havuzundan/bölgeden seçilmiş 3 farklı yanlış cevap olmak üzere toplam 4 seçenek rastgele sıralanarak sunulmalıdır.
- **FR-06 (Cevap Kontrolü ve Kilitleme):** Kullanıcı bir seçeneğe dokunduğunda sistem cevabı anında doğrulamalı ve sonraki soruya geçilene kadar diğer seçenekleri etkileşime kapatmalıdır (kilitlemelidir).

### Puanlama ve Oyunlaştırma (Gamification)
- **FR-07 (Temel Puanlama):** Her doğru cevap **100 puan**, yanlış cevap **0 puan** kazandırmalıdır.
- **FR-08 (Seri / Streak Bonusu):** Üst üste 3 doğru cevapta **+50 bonus puan**, üst üste 5 ve katları doğru cevapta **+100 bonus puan** eklenmelidir. Yanlış cevapta mevcut seri sıfırlanmalıdır.
- **FR-09 (Süre Mekaniği ve Bonusu):** *Expert* modunda soru başına **10 saniye** geri sayım uygulanmalıdır. Süre dolduğunda soru yanlış sayılmalıdır. Kalan her tam saniye için **+5 puan** süre bonusu verilmelidir.
- **FR-10 (Oyun Sonu Özeti):** 10. sorunun ardından toplam puan, doğru/yanlış sayısı, doğruluk yüzdesi ve oturumdaki en yüksek seri gösterilmelidir.

### Veri ve İlerleme Takibi
- **FR-11 (Yerel İstatistik Kaydı):** Kullanıcının toplam puanı, oynadığı oyun sayısı, toplam doğru/yanlış cevapları, en yüksek skoru ve en yüksek serisi cihaz hafızasında kalıcı olarak saklanmalıdır.
- **FR-12 (Başarımlar / Achievements):** Belirli hedeflere ulaşan kullanıcılara (örn. *İlk Oyun*, *10'da 10 Kusursuz Oyun*, *50 Doğru Cevap*) rozetler tanımlanmalı ve kilidi açılmalıdır.
- **FR-13 (Ayarlar ve Tema):** Kullanıcı Light/Dark tema arasında geçiş yapabilmeli, ses/titreşim geri bildirimlerini açıp kapatabilmeli ve tüm ilerlemesini sıfırlayabilmelidir.

## 2. Non-Functional Requirements (Fonksiyonel Olmayan Gereksinimler)
- **NFR-01 (Offline-First):** Uygulama ilk kurulumdan sonra internet bağlantısı olmaksızın %100 fonksiyonellikle çalışmalıdır.
- **NFR-02 (Performans - Başlangıç):** Uygulama soğuk başlangıçta (cold start) 2 saniyenin altında açılmalıdır.
- **NFR-03 (Performans - Arayüz):** Ekran geçişleri ve bayrak SVG çizimleri 60 FPS akıcılığında çalışmalı, kare atlaması (jank) yaşanmamalıdır.
- **NFR-04 (Erişilebilirlik):** Metin ve arka plan renkleri WCAG AA kontrast oranını (en az 4.5:1) sağlamalıdır.
- **NFR-05 (Sürdürülebilirlik):** İş mantığı (Domain) UI katmanından tamamen bağımsız olmalı ve birim test (Unit Test) kapsamı oyun motoru için %90'ın üzerinde olmalıdır.

## 3. Business Rules (İş Kuralları)
- **BR-01:** Başkenti bulunmayan ülkeler (örn. Antarktika veya resmi başkenti olmayan bölgeler) *Capital Quiz* ve *Country Quiz* soru havuzuna dahil edilmez, yalnızca *Flag Quiz* modunda kullanılabilir.
- **BR-02:** Birden fazla başkenti bulunan ülkelerde (örn. Güney Afrika) başkentler virgül ile birleştirilerek (örn. "Pretoria, Bloemfontein, Cape Town") tek bir seçenek metni olarak sunulur.