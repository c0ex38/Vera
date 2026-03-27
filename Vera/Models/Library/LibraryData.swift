import SwiftUI

struct LibraryData {
    static let categories: [LibraryCategory] = [
        LibraryCategory(id: "namaz", title: "Namaz", icon: "figure.hands.folded", color: .blue, description: "Namazın şartları, rükünleri ve kılınış rehberi."),
        LibraryCategory(id: "oruc", title: "Oruç", icon: "moon.stars.fill", color: .orange, description: "Ramazan orucu, kaza ve kefaret bilgileri."),
        LibraryCategory(id: "hac", title: "Hac ve Umre", icon: "house.fill", color: .green, description: "Kutsal topraklar ve ibadetlerin yapılışı."),
        LibraryCategory(id: "temizlik", title: "Temizlik", icon: "drop.fill", color: .cyan, description: "Abdest, boy abdesti ve teyemmüm hükümleri."),
        LibraryCategory(id: "adak", title: "Adak ve Kurban", icon: "gift.fill", color: .red, description: "Kurban ibadeti ve adak hükümlerine dair bilgiler."),
        LibraryCategory(id: "tasavvuf", title: "Tasavvuf", icon: "leaf.fill", color: .purple, description: "Manevi yolculuk ve İslam ahlakı üzerine yazılar.")
    ]
    
    static let articles: [LibraryArticle] = [
        // NAMAZ
        LibraryArticle(id: "abdest", categoryId: "temizlik", title: "Abdest Nasıl Alınır?", content: "Abdestin farzları dörttür: Yüzü yıkamak, kolları dirseklerle beraber yıkamak, başın dörtte birini meshetmek, ayakları topuklarla beraber yıkamak...", source: "Diyanet İşleri Başkanlığı"),
        LibraryArticle(id: "namaz_kilinis", categoryId: "namaz", title: "Namaz Nasıl Kılınır?", content: "Namaz, niyetle başlar. Ayaktayken (kıyam) Kur'an okunur (kıraat), eğilerek rüku edilir ve yere kapanarak secde yapılır...", source: "İlmihal"),
        
        // ORUÇ
        LibraryArticle(id: "oruc_nedir", categoryId: "oruc", title: "Orucun Faziletleri", content: "Oruç, imsak vaktinden iftar vaktine kadar ibadet niyetiyle yemekten, içmekten ve cinsel ilişkiden uzak durmaktır...", source: "Hasan Basri Çantay"),
        
        // HAC
        LibraryArticle(id: "hac_farz", categoryId: "hac", title: "Hac Kimlere Farzdır?", content: "Müslüman olan, akıllı, ergenlik çağına gelmiş, hür ve hacca gidip gelmeye maddi gücü yeten her Müslümana ömründe bir defa hac farzdır.", source: "Fıkıh Kitapları"),
        
        // ADAK
        LibraryArticle(id: "adak_hukmu", categoryId: "adak", title: "Adak Nedir?", content: "Adak, kişinin bir dileğinin gerçekleşmesi halinde Allah rızası için bir ibadet yapacağına dair söz vermesidir...", source: "Diyanet Rehberi"),
        
        // TASAVVUF
        LibraryArticle(id: "edep", categoryId: "tasavvuf", title: "İslam'da Edep", content: "Tasavvuf, baştan başa edeptir. Kulun Rabbiyle ve yaratılanlarla olan ilişkisindeki incelikleri kapsar...", source: "İmam Gazali")
    ]
    
    static func getArticles(for categoryId: String) -> [LibraryArticle] {
        return articles.filter { $0.categoryId == categoryId }
    }
}
