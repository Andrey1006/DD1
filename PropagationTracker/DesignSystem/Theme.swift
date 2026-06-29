import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }

    init(light: UInt, dark: UInt) {
        self.init(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        })
    }
}

extension UIColor {
    convenience init(hex: UInt, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}

enum AppTheme {
    static let primary = Color(hex: 0x2E7D5B)
    static let primaryDeep = Color(hex: 0x1F5E43)
    static let accent = Color(hex: 0xC8745A)
    static let gold = Color(hex: 0xD9A441)
    static let info = Color(hex: 0x4E8FB0)

    static let background = Color(light: 0xF7F5F0, dark: 0x111512)
    static let surface = Color(light: 0xFFFFFF, dark: 0x1C211D)
    static let surfaceAlt = Color(light: 0xEFEDE5, dark: 0x252B26)

    static let textPrimary = Color(light: 0x1F2A24, dark: 0xF1F4F0)
    static let textSecondary = Color(light: 0x606B63, dark: 0xA6B0A8)

    static var heroGradient: LinearGradient {
        LinearGradient(
            colors: [primary, primaryDeep],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var accentGradient: LinearGradient {
        LinearGradient(
            colors: [accent, Color(hex: 0xB35C44)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}
