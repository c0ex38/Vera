import Foundation

// Açılar arası dönüşümleri kolaylaştırmak için matematik uzantıları
extension Double {
    var degreesToRadians: Double { return self * .pi / 180.0 }
    var radiansToDegrees: Double { return self * 180.0 / .pi }
}
