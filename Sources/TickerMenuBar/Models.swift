import Foundation

enum RefreshInterval: Int, CaseIterable, Identifiable {
    case seconds30 = 30
    case seconds60 = 60
    case minutes5 = 300
    case minutes15 = 900

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .seconds30: return "30 Sekunden"
        case .seconds60: return "1 Minute"
        case .minutes5: return "5 Minuten"
        case .minutes15: return "15 Minuten"
        }
    }
}

enum KnownAssets {
    /// Symbole, die zuerst als Krypto-Paar (SYMBOL-USD) versucht werden,
    /// bevor als normales Aktien-Ticker-Symbol nachgeschlagen wird.
    static let cryptoSymbols: Set<String> = [
        "BTC", "ETH", "SOL", "XRP", "DOGE", "ADA", "LTC", "DOT", "MATIC", "AVAX",
        "LINK", "BCH", "XLM", "TRX", "ATOM", "UNI", "ETC", "FIL", "APT", "ARB",
        "OP", "NEAR", "ICP", "HBAR", "VET", "SUI", "SHIB", "TON", "BNB", "PEPE",
        "AAVE", "ALGO", "MKR", "SAND", "MANA", "GRT", "CRV", "LDO"
    ]
}

struct Quote {
    var symbol: String
    var name: String?
    var price: Double
    var changePercent: Double?
    var isCrypto: Bool
}
