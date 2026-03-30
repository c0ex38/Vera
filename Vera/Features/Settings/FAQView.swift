import SwiftUI

struct FAQView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let faqs = [
        ("Uygulama ücretli mi?", "Vera'nın temel özellikleri tamamen ücretsizdir."),
        ("Namaz vakitleri nasıl hesaplanıyor?", "Vakitler, Diyanet İşleri Başkanlığı'nın verilerine göre hesaplanmaktadır."),
        ("İnternet bağlantısı gerekli mi?", "Bildirimler ve günlük vakitlerin hesabı için bir kere konum alındıktan sonra çevrimdışı çalışabilmektedir.")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            VeraCustomHeader(title: "Yardım", subtitle: "Sıkça Sorulan Sorular") {
                presentationMode.wrappedValue.dismiss()
            }
            
            ScrollView {
                VStack(spacing: 20) {
                    // Yardım Açıklaması
                    Text("Vera ile ilgili en çok merak edilen konuları aşağıda bulabilirsiniz. Aradığınız cevabı bulamazsanız 'Bize Ulaşın' kısmından bize yazabilirsiniz.")
                        .font(.system(size: 14))
                        .foregroundColor(.themeTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top, 10)

                    VStack(spacing: 16) {
                        FAQItem(
                            question: "Namaz vakitleri hangi kaynağa göre hesaplanıyor?",
                            answer: "Vera, tüm vakit hesaplamalarında Diyanet İşleri Başkanlığı'nın resmi verilerini kullanmaktadır."
                        )
                        
                        FAQItem(
                            question: "Konumumu nasıl değiştirebilirim?",
                            answer: "Ana sayfada en üstte yer alan konum ismine (ilçe/şehir) tıklayarak manuel arama yapabilir veya mevcut konumunuzu güncelleyebilirsiniz."
                        )
                        
                        FAQItem(
                            question: "Vakit bildirimleri gelmiyor, ne yapmalıyım?",
                            answer: "Ayarlar -> Bildirimler kısmının açık olduğundan emin olun. Ayrıca telefonunuzun Ayarlar -> Vera -> Bildirimler menüsünden izinlerin verildiğini kontrol edin."
                        )
                        
                        FAQItem(
                            question: "Kuran meali yazarını nasıl değiştirebilirim?",
                            answer: "Ayarlar -> Kuran-ı Kerim sekmesi altında yer alan 'Meal Yazar Seçimi' menüsünden dilediğiniz yazarı seçebilirsiniz."
                        )
                        
                        FAQItem(
                            question: "İnternetsiz çalışıyor mu?",
                            answer: "Konumunuz bir kez belirlenip vakitler indirildikten sonra, uygulama temel vakit gösterimi için internete ihtiyaç duymaz."
                        )
                        
                        FAQItem(
                            question: "Reklamları nasıl kaldırabilirim?",
                            answer: "Reklamları kaldırma özelliği (Premium) üzerinde çalışıyoruz. Çok yakında bir güncelleme ile bu özelliği sunmayı planlıyoruz."
                        )
                    }
                }
                .padding()
            }
            .background(Color.themeBackground)
        }
        .navigationBarHidden(true)
    }
}

struct FAQItem: View {
    let question: String
    let answer: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundColor(.themePrimary)
                    .font(.system(size: 18))
                
                Text(question)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.themeText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Text(answer)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.themeTextSecondary)
                .lineSpacing(4)
                .padding(.leading, 28)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.themeSurface)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
    }
}
