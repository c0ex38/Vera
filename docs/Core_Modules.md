# 🏢 Temel Modüller (Core Modules)

Bu doküman, Vera projesinin kalbi olan üç ana modülü teknik ve işlevsel açıdan detaylandırır.

## 🕌 1. Namaz Vakitleri & Konum Yönetimi

Namaz vakitleri modülü, kullanıcının GPS konumunu Diyanet İşleri Başkanlığı'nın API verileriyle eşleştirerek çalışır.

### Teknik İşleyiş:
-   **Konum Tesbiti**: `CLLocationManager` ile GPS verisi alınır.
-   **API Eşleştirme**: `LocationMatcher` servisi, GPS'ten gelen İl/İlçe isimlerini Diyanet API'sindeki (Country/City/District) ID'lerle eşleştirir.
-   **Veri Çekimi**: `PrayerTimeService`, 30 günlük vakitleri çeker ve JSON olarak cihazda önbelleğe alır.
-   **Bildirimler**: `NotificationManager`, her vakit için (Ezan veya hatırlatıcı) sistem bildirimlerini kuyruğa ekler.

### Öne Çıkan Özellikler:
-   Otomatik konum bazlı vakit bulma.
-   İmsakiye görünümü ve iftar/sahur sayacı.
-   Özelleştirilebilir vakit alarmları.

---

## 📖 2. Kuran-ı Kerim Motoru

Kuran modülü, hem okuma deneyimini hem de farklı mealler üzerinden çalışma yapmayı mümkün kılar.

### Teknik İşleyiş:
-   **Veri Kaynağı**: `AppDatabaseManager` üzerinden SQLite veritabanına sorgu atılır.
-   **Sayfa Bazlı Okuma**: Mushaf düzenine uygun olarak ayetler sayfa bazlı (`fetchVersesForPage`) çekilir.
-   **Meal Yönetimi**: `selectedQuranAuthorId` UserDefaults üzerinden takip edilerek, ayetlerin farklı yazarlara ait mealleri anlık olarak `translations` tablosundan getirilir.

### Öne Çıkan Özellikler:
-   114 Sure listesi ve Hızlı Cüz navigasyonu.
-   Arapça metin, Türkçe meal ve Transkripsiyon (okunuş) bir arada.
-   Göz yormayan, premium serif tipografisiyle okuma deneyimi.

---

## 📜 3. Hadisler Modülü

Hadisler modülü, projenin en kapsamlı veri setlerinden birini (999 Hadis) performanslı bir şekilde sunar.

### Teknik İşleyiş:
-   **Lazy Loading (Sayfalama)**: Bellek performansını korumak için hadisler 20'şerli gruplar halinde (`fetchHadithsPaged`) yüklenir. Kullanıcı aşağı doğru kaydırdıkça yeni sayfalar eklenir.
-   **Global Arama**: `searchHadiths` fonksiyonu, tüm veritabanı (999 hadis) üzerinde anlık metin taraması yaparak sonuçları döner.
-   **Search Debounce**: Arama çubuğuna yazılan her harf için veritabanına gitmek yerine 0.5s bekleme (debounce) süresi kullanılarak akıcılık sağlanır.

### Öne Çıkan Özellikler:
-   Rastgele "Günün Hadisi" algoritması.
-   Sonsuz kaydırma (Infinite scroll) desteği.
-   Bağımsız sayfa görünümü (`HadithPageView`).
