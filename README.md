# Kopalnia Klocków

Kreskówkowa, automatyczna gra idle o rozwijaniu ekipy górników. Projekt Godot 4, docelowo Android.

## Ustalenia MVP
- Pierwsza kopalnia: 30 pięter.
- Każde piętro ma własną rozbudowę 0–800.
- Górnicy kopią automatycznie.
- Waluty: monety i kryształy; dodatkowe nagrody: skrzynie.
- Zapis lokalny, gra offline.

## Testy
```sh
godot --headless --editor --path . --import
godot --headless --path . --script tests/run_tests.gd
```

## APK
Każdy push uruchamia GitHub Actions. Po udanej kompilacji APK znajduje się w artefaktach workflow `Android APK`.
