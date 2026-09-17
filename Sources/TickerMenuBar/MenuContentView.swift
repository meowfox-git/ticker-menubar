import SwiftUI
import AppKit

struct MenuContentView: View {
    @ObservedObject var fetcher: QuoteFetcher
    @AppStorage("symbol") private var symbol = "BTC"
    @AppStorage("refreshInterval") private var intervalRaw = RefreshInterval.seconds60.rawValue
    @State private var symbolInput: String = ""

    private var interval: RefreshInterval {
        RefreshInterval(rawValue: intervalRaw) ?? .seconds60
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(fetcher.quote?.name ?? symbol)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                if fetcher.isLoading {
                    ProgressView().controlSize(.small)
                }
            }

            if let quote = fetcher.quote {
                Text(formattedPrice(quote.price))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            } else if let error = fetcher.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.caption)
            } else {
                Text("Lade Kurs …")
                    .foregroundStyle(.secondary)
            }

            if let change = fetcher.quote?.changePercent {
                Label(String(format: "%.2f %%", change), systemImage: change >= 0 ? "arrow.up.right" : "arrow.down.right")
                    .foregroundStyle(change >= 0 ? .green : .red)
                    .font(.caption)
            }

            if let updated = fetcher.lastUpdated {
                Text("Aktualisiert: \(updated.formatted(date: .omitted, time: .standard))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Divider()

            HStack {
                TextField("Symbol (z. B. AAPL, BTC)", text: $symbolInput)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(applySymbol)
                Button("OK", action: applySymbol)
            }

            Picker("Aktualisierung", selection: $intervalRaw) {
                ForEach(RefreshInterval.allCases) { i in
                    Text(i.label).tag(i.rawValue)
                }
            }
            .onChange(of: intervalRaw) { _ in
                fetcher.start(symbol: symbol, interval: interval)
            }

            Divider()

            Button("Jetzt aktualisieren") {
                Task { await fetcher.refresh(symbol: symbol) }
            }

            Button("Beenden") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(12)
        .frame(width: 260)
        .onAppear {
            symbolInput = symbol
            fetcher.start(symbol: symbol, interval: interval)
        }
    }

    private func applySymbol() {
        let cleaned = symbolInput.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !cleaned.isEmpty else { return }
        symbol = cleaned
        symbolInput = cleaned
        fetcher.start(symbol: symbol, interval: interval)
    }

    private func formattedPrice(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = value < 1 ? 6 : 2
        return formatter.string(from: NSNumber(value: value)) ?? "$\(value)"
    }
}
