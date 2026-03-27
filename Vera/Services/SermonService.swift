import Foundation

class SermonService {
    static let shared = SermonService()
    private let baseURL = "https://dinhizmetleri.diyanet.gov.tr"
    private let sermonsURL = "https://dinhizmetleri.diyanet.gov.tr/kategoriler/yayinlarimiz/hutbeler/t%C3%BCrk%C3%A7e"
    
    func fetchLatestSermons() async throws -> [Sermon] {
        guard let url = URL(string: sermonsURL) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let html = String(data: data, encoding: .utf8) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        return parseSermons(from: html)
    }
    
    private func parseSermons(from html: String) -> [Sermon] {
        var parsedSermons: [Sermon] = []
        
        // Basit bir regex ile satırları bulmaya çalışalım
        // tr role="row" içindeki td'leri hedefliyoruz
        // Not: SharePoint HTML'i karmaşık olduğu için regex biraz esnek olmalı
        
        let rowPattern = "<tr[^>]*>(.*?)</tr>"
        let cellPattern = "<td[^>]*>(.*?)</td>"
        let linkPattern = "href=\"([^\"]+?\\.pdf)\""
        let datePattern = "(\\d{2}\\.\\d{2}\\.\\d{4})" // Herhangi bir yerdeki tarih formatını bul
        
        do {
            let rowRegex = try NSRegularExpression(pattern: rowPattern, options: [.dotMatchesLineSeparators])
            let cellRegex = try NSRegularExpression(pattern: cellPattern, options: [.dotMatchesLineSeparators])
            let linkRegex = try NSRegularExpression(pattern: linkPattern, options: [])
            let dateRegex = try NSRegularExpression(pattern: datePattern, options: [])
            
            let nsHtml = html as NSString
            let rowMatches = rowRegex.matches(in: html, options: [], range: NSRange(location: 0, length: nsHtml.length))
            
            for rowMatch in rowMatches {
                let rowContent = nsHtml.substring(with: rowMatch.range(at: 1))
                let nsRowContent = rowContent as NSString
                let cellMatches = cellRegex.matches(in: rowContent, options: [], range: NSRange(location: 0, length: nsRowContent.length))
                
                // Beklenen hücre yapısı: 0: Checkbox (veya boş), 1: Tarih, 2: Başlık, 3: PDF Link
                if cellMatches.count >= 3 {
                    let combinedContent = nsRowContent as String
                    
                    // Tarih ayıklama (Tüm satırda ara, daha garantidir)
                    var date = ""
                    if let dateMatch = dateRegex.firstMatch(in: combinedContent, options: [], range: NSRange(location: 0, length: (combinedContent as NSString).length)) {
                        date = (combinedContent as NSString).substring(with: dateMatch.range(at: 1))
                    }
                    
                    // Link ve Başlık ayıklama
                    var pdfURL = ""
                    var title = ""
                    
                    // Linki bul
                    if let linkMatch = linkRegex.firstMatch(in: combinedContent, options: [], range: NSRange(location: 0, length: (combinedContent as NSString).length)) {
                        let relativePath = (combinedContent as NSString).substring(with: linkMatch.range(at: 1))
                        pdfURL = baseURL + (relativePath.starts(with: "/") ? relativePath : "/" + relativePath)
                    }
                    
                    // Başlığı bul (cell 2 genellikle en temiz yerdir, ama link hücresinde de olabilir)
                    let candidateCell = nsRowContent.substring(with: cellMatches[min(2, cellMatches.count - 1)].range(at: 1))
                    title = candidateCell.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression).trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    if !title.isEmpty && !date.isEmpty && !pdfURL.isEmpty {
                        let sermon = Sermon(date: date, title: title, pdfURL: pdfURL, audioURL: nil)
                        parsedSermons.append(sermon)
                    }
                }
            }
        } catch {
            print("Regex Error: \(error)")
        }
        
        return parsedSermons
    }
}
