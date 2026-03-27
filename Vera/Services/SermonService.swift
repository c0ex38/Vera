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
        
        let rowPattern = "<tr[^>]*role=\"row\"[^>]*>(.*?)</tr>"
        let cellPattern = "<td[^>]*>(.*?)</td>"
        let linkPattern = "href=\"([^\"]+?\\.pdf)\""
        let datePattern = "title=\"(\\d{2}\\.\\d{2}\\.\\d{4})\""
        
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
                
                // Beklenen hücre yapısı: 0: Checkbox, 1: Tarih, 2: Başlık, 3: PDF Link
                if cellMatches.count >= 4 {
                    let dateCell = nsRowContent.substring(with: cellMatches[1].range(at: 1))
                    let titleCell = nsRowContent.substring(with: cellMatches[2].range(at: 1))
                    let linkCell = nsRowContent.substring(with: cellMatches[3].range(at: 1))
                    
                    // Temizlik (HTML tag'lerini kaldır)
                    let title = titleCell.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression).trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Tarih ayıklama
                    var date = ""
                    if let dateMatch = dateRegex.firstMatch(in: dateCell, options: [], range: NSRange(location: 0, length: (dateCell as NSString).length)) {
                        date = (dateCell as NSString).substring(with: dateMatch.range(at: 1))
                    } else {
                        date = dateCell.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression).trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    
                    // Link ayıklama
                    var pdfURL = ""
                    if let linkMatch = linkRegex.firstMatch(in: linkCell, options: [], range: NSRange(location: 0, length: (linkCell as NSString).length)) {
                        let relativePath = (linkCell as NSString).substring(with: linkMatch.range(at: 1))
                        pdfURL = baseURL + relativePath
                    }
                    
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
