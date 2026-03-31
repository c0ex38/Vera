# ✨ Spiritüel ve Yardımcı Özellikler

Bu modüller, projenin günlük ibadet ve İslami araçlar tarafındaki işlevlerini detaylandırır.

## 📿 1. Zikirmatik (Dhikr Counter)

Zikirmatik modülü, kullanıcının hem şablon zikirleri çekmesini hem de kendi özel zikirlerini takip etmesini sağlar.

### Teknik İşleyiş:
-   **Zikir Kaydı**: Ekranın her dokunuşuna (haptik geri bildirimle) bir sayaç (`count`) eklenir. `saveActiveDhikr` fonksiyonu, sayacı veritabanında anlık olarak günceller.
-   **Hedef Sistemi**: Kullanıcı bir `target` belirleyebilir. Sayaç hedefe ulaştığında özel bir görsel efekt veya bildirim sunulabilir.
-   **Veri Kalıcılığı**: Uygulama kapatılsa bile en son çekilen zikir ve sayı, veritabanından (`user_dhikrs` tablosu) tekrar yüklenir.

---

## 🧭 2. Kıble Pusulası (Qibla Compass)

Kıble modülü, kullanıcının bulunduğu yerden Kabe'nin yönünü bulmasını sağlar.

### Teknik İşleyiş:
-   **Sensör Kullanımı**: `CMMotionManager` veya `CoreLocation` üzerinden cihazın manyetik kuzey ve coğrafi kuzey verileri alınır.
-   **Geometrik Hesaplama**: Kullanıcının enlem/boylam verisi ile Mekke'nin koordinatları (21.4225, 39.8262) arasındaki kerte hattı (loxodrome) açısı hesaplanır.
-   **UI Animasyonu**: Hesaplanan açı, pusula görselinin üzerine pürüzsüz bir rotasyon katmanı olarak uygulanır.

---

## 🕌 3. Esmaül Hüsna (Allahu Teala'nın 99 İsmi)

Esmaül Hüsna modülü, zengin bir içerik sunarak her ismin derinliğini kullanıcıya aktarır.

### Teknik İşleyiş:
-   **Veri Seti**: SQLite üzerindeki `esmaul_husna` tablosunda kayıtlı 99 isim (`fetchEsmaulHusna`) kullanılır.
-   **Detay Görünümü**: Her ismin Arapça yazılışı, Türkçe okunuşu, kısa anlamı ve geniş açıklaması (faziletleri) bir arada sunulur.

---

## 💰 4. Zekat Hesaplayıcı

Kullanıcıların mal varlıkları üzerinden verecekleri zekatı kolayca hesaplayabildikleri modüldür.

### Teknik İşleyiş:
-   **Hesaplama Algoritması**: Altın (80.18 gr), gümüş, nakit para, ticari mallar ve borçlar gibi kalemler üzerinden nisap miktarı kontrolü yapılarak %2.5 (1/40) oranında otomatik hesaplama yapılır.
-   **Dinamik Girdi**: Kullanıcının girdiği her tutar, `ZakatModel` içindeki mantıksal katmanda işlenerek anlık olarak zekat tutarını günceller.
