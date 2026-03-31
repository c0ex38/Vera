# ⚙️ Teknik Altyapı (Technical Infrastructure)

Bu doküman, Vera projesinin arka plandaki servis katmanlarını, veri yönetimini ve teknik entegrasyonlarını açıklar.

## 🗄️ 1. Veritabanı Yönetimi (`AppDatabaseManager`)

Uygulamanın kalıcı veri depolama katmanı, SQLite üzerine inşa edilmiştir.

### Uygulama Detayları:
-   **Thread Safety**: Swift 6 `actor` yapısı kullanılarak veritabanına erişim izole edilir ve veri yarışmaları (data racing) önlenir.
-   **Dosya Yönetimi**: Veritabanı dosyası (`vera.sqlite`) uygulama paketi içerisinde gelir. İlk açılışta kullanıcının `Documents` dizinine kopyalanır.
-   **Versiyonlama**: `VeraDatabaseVersion_Refactor` key değeri ile veritabanı sürümü takip edilir. Yeni bir şema veya veri seti eklendiğinde, sürüm artırılarak veritabanının otomatik olarak yenilenmesi sağlanır.

---

## 📢 2. Bildirim Servisleri (`NotificationManager`)

Namaz vakitleri ve önemli dini günlerin hatırlatılması `UNUserNotificationCenter` üzerinden yönetilir.

### Uygulama Detayları:
-   **Kuyruğa Ekleme**: `scheduleWeekly` fonksiyonu, bir sonraki 7 günlük vakitleri bildirim kuyruğuna ekler.
-   **Yetkilendirme**: Kullanıcıdan bildirim izni `LocationProvider` üzerinden talep edilir.
-   **Özelleştirme**: Ayarlar ekranında her vakit için (Ezan sesi, kısa ses veya sessiz) ayrı tercihler yapılabilir.

---

## 💰 3. Abonelik Sistemi (`SubscriptionManager`)

Uygulamanın Pro özelliklerinin (Reklamsız deneyim, özel temalar vb.) yönetimidir.

### Uygulama Detayları:
-   **StoreKit Entegrasyonu**: Apple'ın StoreKit framework'ü ile satın alma işlemleri ve abonelik doğrulaması yapılır.
-   **Pro Status**: `isPro` değişkeni üzerinden tüm modüllere reklam gösterimi veya özellik kısıtlaması kararı verilir.
-   **Restore Purchases**: Kullanıcının daha önceki satın alımlarını geri getirme yeteneği sunulur.

---

## 📺 4. Reklam Entegrasyonu (AdMob)

Uygulama genelinde sunulan reklamların yönetimidir.

### Uygulama Detayları:
-   **Banner Ads**: Belirli sayfaların altında yer alan ufak reklam alanları.
-   **Interstitial Ads**: Sayfa geçişlerinde (örneğin Hadis sayfasından geri çıkarken) gösterilen tam ekran reklamlar.
-   **App Open Ads**: Uygulama her ön plana geldiğinde gösterilen açılış reklamları.
-   **Yönetim**: `isPro` aktifse hiçbir reklam birimi yüklenmez veya gösterilmez.
