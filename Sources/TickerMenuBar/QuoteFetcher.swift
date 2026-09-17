import Foundation
import Combine

@MainActor
final class QuoteFetcher: ObservableObject {
    @Published private(set) var quote: Quote?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var lastUpdated: Date?

    private var timer: Timer?
    private let session = URLSession(configuration: .ephemeral)

    func start(symbol: String, interval: RefreshInterval) {
        timer?.invalidate()
        Task { await refresh(symbol: symbol) }
        timer = Timer.scheduledTimer(withTimeInterval: Double(interval.rawValue), repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.refresh(symbol: symbol)
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func refresh(symbol rawSymbol: String) async {
        let symbol = rawSymbol.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !symbol.isEmpty else {
            errorMessage = "Bitte Symbol eingeben"
            return
        }

        isLoading = true
        defer { isLoading = false }

        let candidates = candidateTickers(for: symbol)

        for (index, ticker) in candidates.enumerated() {
            if let result = try? await fetchQuote(ticker: ticker, displaySymbol: symbol) {
                quote = result
                lastUpdated = Date()
                errorMessage = nil
                return
            }
            if index == candidates.count - 1 {
                errorMessage = "Symbol „\(symbol)“ nicht gefunden"
            }
        }
    }

    /// Reihenfolge der Ticker-Varianten, die nacheinander bei Yahoo Finance versucht werden.
    private func candidateTickers(for symbol: String) -> [String] {
        if symbol.contains("-") {
            return [symbol]
        }
        if KnownAssets.cryptoSymbols.contains(symbol) {
            return ["\(symbol)-USD", symbol]
        }
        return [symbol, "\(symbol)-USD"]
    }

    private func fetchQuote(ticker: String, displaySymbol: String) async throws -> Quote {
        guard let encoded = ticker.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "https://query1.finance.yahoo.com/v8/finance/chart/\(encoded)?interval=1d&range=1d") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.setValue(
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko)",
            forHTTPHeaderField: "User-Agent"
        )

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(ChartResponse.self, from: data)
        guard let result = decoded.chart.result?.first else {
            throw URLError(.cannotParseResponse)
        }
        let meta = result.meta
        guard let price = meta.regularMarketPrice else {
            throw URLError(.cannotParseResponse)
        }

        let previousClose = meta.previousClose ?? meta.chartPreviousClose
        var changePercent: Double?
        if let previousClose, previousClose != 0 {
            changePercent = (price - previousClose) / previousClose * 100
        }

        return Quote(
            symbol: displaySymbol,
            name: meta.longName ?? meta.shortName,
            price: price,
            changePercent: changePercent,
            isCrypto: ticker.hasSuffix("-USD")
        )
    }
}

private struct ChartResponse: Decodable {
    let chart: Chart
}

private struct Chart: Decodable {
    let result: [ChartResult]?
}

private struct ChartResult: Decodable {
    let meta: Meta
}

private struct Meta: Decodable {
    let currency: String?
    let symbol: String?
    let regularMarketPrice: Double?
    let previousClose: Double?
    let chartPreviousClose: Double?
    let longName: String?
    let shortName: String?
}
