import SwiftUI
import AppKit

@main
struct TickerMenuBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var fetcher = QuoteFetcher()
    @AppStorage("symbol") private var symbol = "BTC"

    var body: some Scene {
        MenuBarExtra {
            MenuContentView(fetcher: fetcher)
        } label: {
            Text(menuBarTitle)
                .task {
                    let intervalRaw = UserDefaults.standard.integer(forKey: "refreshInterval")
                    let interval = RefreshInterval(rawValue: intervalRaw) ?? .seconds60
                    fetcher.start(symbol: symbol, interval: interval)
                }
        }
        .menuBarExtraStyle(.window)
    }

    private var menuBarTitle: String {
        guard let quote = fetcher.quote else { return "\(symbol) …" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = quote.price < 1 ? 4 : 2
        let priceString = formatter.string(from: NSNumber(value: quote.price)) ?? "\(quote.price)"
        return "\(quote.symbol) $\(priceString)"
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}
