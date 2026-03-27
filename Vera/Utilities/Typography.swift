import SwiftUI
import UIKit

extension Font {
    static var adaptiveLargeTitle: Font {
        UIDevice.current.userInterfaceIdiom == .pad ? .system(size: 44, weight: .bold) : .largeTitle
    }
    
    static var adaptiveTitle: Font {
        UIDevice.current.userInterfaceIdiom == .pad ? .system(size: 36, weight: .bold) : .title
    }
    
    static var adaptiveHeadline: Font {
        UIDevice.current.userInterfaceIdiom == .pad ? .system(size: 24, weight: .bold) : .headline
    }
    
    static var adaptiveBody: Font {
        UIDevice.current.userInterfaceIdiom == .pad ? .system(size: 20, weight: .regular) : .body
    }
    
    static var adaptiveSubheadline: Font {
        UIDevice.current.userInterfaceIdiom == .pad ? .system(size: 18, weight: .medium) : .subheadline
    }
    
    static var adaptiveFootnote: Font {
        UIDevice.current.userInterfaceIdiom == .pad ? .system(size: 16, weight: .regular) : .footnote
    }
}

extension View {
    func adaptivePadding() -> some View {
        self.padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 64 : 32)
    }
}
