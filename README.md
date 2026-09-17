# Ticker Kurs

A lightweight macOS menu bar app that shows the current USD price of any US
stock ticker (e.g. `AAPL`, `MSFT`) or cryptocurrency (e.g. `BTC`, `ETH`,
`SOL`, `XRP`).

## Features

- Enter any symbol directly from the menu – no restart required
- Automatically recognizes known crypto tickers and queries them as
  `SYMBOL-USD`
- Falls back to the other variant automatically for unknown symbols
- Shows name, price (USD), and 24h change
- Configurable refresh interval (30 sec / 1 min / 5 min / 15 min)
- Runs as a pure menu bar app (no Dock icon)

## Data source

Price data is fetched from the free, unofficial Yahoo Finance chart API
(`query1.finance.yahoo.com`). No API key is required. Since this is an
unofficial interface, it may change or become temporarily unavailable.

## Build

Requirements: Xcode command line tools (Swift 5.9+, macOS 13+).

```bash
swift build -c release
```

The resulting binary will be at `.build/release/TickerMenuBar`. You can
assemble a ready-to-run `.app` bundle from it like this:

```bash
APP="Ticker Kurs.app"
mkdir -p "$APP/Contents/MacOS"
cp .build/release/TickerMenuBar "$APP/Contents/MacOS/TickerMenuBar"
cp Info.plist "$APP/Contents/Info.plist"
printf 'APPL????' > "$APP/Contents/PkgInfo"
codesign --force --deep --sign - "$APP"
open "$APP"
```

## License

MIT License, see [LICENSE](LICENSE). The license file also includes a
disclaimer regarding the displayed price data.

## Author

meowfox
