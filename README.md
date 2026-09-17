# Ticker Kurs

Eine schlanke macOS-Menüleisten-App, die den aktuellen USD-Kurs eines beliebigen
US-Aktien-Tickers (z. B. `AAPL`, `MSFT`) oder einer Kryptowährung (z. B. `BTC`,
`ETH`, `SOL`, `XRP`) anzeigt.

## Features

- Beliebiges Symbol direkt im Menü eingeben – kein Neustart nötig
- Erkennt bekannte Krypto-Kürzel automatisch und fragt sie als `SYMBOL-USD` ab
- Fällt bei unbekannten Kürzeln automatisch auf die jeweils andere Variante zurück
- Anzeige von Name, Kurs (USD) und 24h-Änderung
- Einstellbares Aktualisierungsintervall (30 Sek. / 1 Min. / 5 Min. / 15 Min.)
- Läuft als reine Menüleisten-App (kein Dock-Icon)

## Datenquelle

Kursdaten werden über die kostenlose, inoffizielle Chart-API von Yahoo Finance
(`query1.finance.yahoo.com`) abgerufen. Es wird kein API-Key benötigt. Da es
sich um eine inoffizielle Schnittstelle handelt, kann sie sich ändern oder
zeitweise nicht verfügbar sein.

## Build

Voraussetzung: Xcode-Kommandozeilentools (Swift 5.9+, macOS 13+).

```bash
swift build -c release
```

Das fertige Binary liegt danach unter `.build/release/TickerMenuBar`. Ein
fertiges `.app`-Bundle lässt sich damit z. B. so zusammenstellen:

```bash
APP="Ticker Kurs.app"
mkdir -p "$APP/Contents/MacOS"
cp .build/release/TickerMenuBar "$APP/Contents/MacOS/TickerMenuBar"
cp Info.plist "$APP/Contents/Info.plist"
printf 'APPL????' > "$APP/Contents/PkgInfo"
codesign --force --deep --sign - "$APP"
open "$APP"
```

## Lizenz

MIT-Lizenz, siehe [LICENSE](LICENSE). Die Lizenzdatei enthält außerdem einen
Haftungsausschluss zu den angezeigten Kursdaten.

## Autor

meowfox
