# Vera Projesi Geliştirme Yol Haritası (Roadmap)

## Aşama 1: Temel Çatı ve Altyapı Kurulumu 🏗️

- [x] Uygulamanın temel MVVM klasör mimarisinin oturtulması (Models, Views, ViewModels, Services).
- [x] Temel renk skalasının (Light/Dark mode) ve tipografinin belirlenmesi.
- [x] Ana navigasyon yapısının (Tab Bar veya Navigation Drawer) oluşturulması.
- [x] Ağ (Network) ve Veritabanı (Local Storage - CoreData/UserDefaults) servis katmanlarının temellerinin atılması.

## Aşama 2: Temel ve En Çok Kullanılan İslami Modüller 🕋

- [x] **Namaz Vakitleri:** Konuma göre günlük namaz vakitlerinin API'den çekilmesi ve güncel tarihlerle gösterimi.
- [x] **Kıble:** Cihazın pusula ve konum sensörlerini kullanarak Kıble yönünün pürüzsüz animasyonla UI üzerinde gösterilmesi.
- [x] **Zikirmatik:** Haptik (titreşim) geri bildirimli, ses efektli, Tesbihat şablonlu ve tam kaydedilebilir dijital zikir ekranı.

## Aşama 3: Kuran, Dualar ve Eğitim 📖

- [x] **Kuran-ı Kerim:** Cüzler, sureler listesi ve Arapça/Türkçe meal okuma ekranı. (Hızlı arama ve Meal yazar seçimi).
- [x] **Esmaül Hüsna:** Allah'ın 99 isminin listesi, anlamları ve faziletleri.
- [x] **Dualar:** Günlük okunacak genel duaların (Namaz sureleri ve duaları) listelendiği sayfa.
- [ ] **Kütüphane:** Namaz kılınış rehberi, tesbihatın tanımı ve hatim duası gibi kılavuz bilgilerin eklenmesi.
- [ ] **Haftanın Hutbesi:** Her hafta güncellenen Diyanet hutbesinin okunabileceği alan.

## Aşama 4: Özel Günler ve Takip Modülleri 🗓️

- [ ] **Amel Defteri (Task Manager):** Kullanıcının günlük ibadetlerini (5 vakit namaz, Kuran okuma vb.) işaretleyip kendi gelişimini takip edeceği bölüm.
- [x] **İmsakiye:** Ramazan ayına özel 30 günlük çizelge ve iftar/sahur sayacı.
- [x] **Dini Günler:** Yıl içerisindeki Kandiller, Bayramlar ve önemli ayların (Üç Aylar) listelenmesi.
- [ ] **Miladi-Hicri Takvim Dönüşümü:** Basit bir tarih çevirici aracı.

## Aşama 5: Araçlar ve Topluluk Asistanı 🛠️

- [x] **Keşfet (Menü) Ekranı:** Uygulamadaki tüm aktif ve yakında gelecek modüllerin (Katalog) şık bir düzende sergilendiği ana sekme.
- [ ] **Zekat Hesaplama Modülü:** Altın, nakit para vb. değerlerin girilerek güncel zekat tutarının otomatik hesaplandığı araç.
- [x] **Yakın Camiler:** Harita üzerinde kullanıcının etrafındaki camilerin (MapKit/Google Maps ile) gösterimi.

## Aşama 6: Ayarlar ve Yayın Öncesi Cila ⚙️

- [x] **Ayarlar:** Tema değişimi (Light/Dark), Meal yazarı seçimi ve sistem tercihleri.
- [x] **Vakit Alarları:** Her vakit için özel ezan sesi, hatırlatıcı ve granular bildirim yönetimi.
- [x] **Destek:** Kullanıcının feedback verebileceği veya iletişim kurabileceği bölümler.
- [x] **Soft UI & Premium Design:** Glassmorphism, atmosfere göre değişen canlı arkaplanlar ve yumuşak geçişler.
- [ ] Simgelerin (Iconography) optimizasyonu ve uygulamanın beta teste çıkarılması!
