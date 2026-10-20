# Kopalnia Klocków — specyfikacja MVP

## Cel
Kreskówkowa, pionowa gra idle na Androida. Górnicy automatycznie rozbijają bloki; gracz zarabia waluty, kupuje górników i ulepszenia, przechodzi kopalnie oraz piętra.

## Ustalone wymagania
- Nazwa: Kopalnia Klocków.
- Silnik: Godot 4, GDScript; APK testowe budowane przez GitHub Actions.
- Gra działa offline, bez kont, reklam i płatności.
- Pierwsza kopalnia ma dokładnie 30 pięter.
- Każde piętro ma niezależną rozbudowę/ulepszenie na poziomach 0–800.
- Kopanie jest automatyczne; ręczne klikanie nie jest wymagane.
- W grze są monety, kryształy i dodatkowe nagrody (np. skrzynie).
- Postęp zapisuje się lokalnie.
- Kopalnie są podzielone na światy; następne światy odblokowuje się po ukończeniu poprzednich.

## Pętla gry
Górnicy automatycznie zadają obrażenia blokom. Zniszczone bloki dają monety i mogą dać kryształy lub skrzynie. Monety kupują górników i zwykłe ulepszenia; kryształy służą do rzadkich ulepszeń/nagród. Po zniszczeniu wszystkich bloków piętra następuje przejście dalej. Można wrócić do ukończonego piętra i dalej je rozbudowywać.

## Zawartość MVP
- Jedna kopalnia, 30 pięter; następny świat pokazany na mapie jako zablokowany.
- Trzy typy górników: Pomocnik, Górnik, Wiertacz.
- Ulepszenia: siła górników, szybkość pracy, wartość nagród i szansa na kryształ.
- Osobny poziom rozbudowy 0–800 dla każdego piętra. Rozbudowa daje stopniową premię dla danego piętra; można ją kupować za monety, a koszt/efekt wyświetla UI.
- Monety, kryształy, skrzynie/losowa dodatkowa nagroda.
- Ekrany: kopalnia, ekipa, ulepszenia, mapa, ustawienia.
- Lokalny zapis stanu i bezpieczne uruchomienie nowej gry przy braku lub błędzie zapisu.
- Prosta kreskówkowa grafika/placeholdery, czytelna w orientacji pionowej.

## Zapis
Zapis obejmuje waluty, liczby górników, poziomy globalnych ulepszeń, aktywny świat/piętro, odblokowanie światów, poziom rozbudowy każdego piętra i ustawienia. Format zapisu ma numer wersji. Zapis następuje po zakupach, nagrodach, awansie i okresowo.

## Poza MVP
Dodatkowe światy, artefakty, zdolności specjalne górników, prestiż, zadania, osiągnięcia, muzyka, synchronizacja chmurowa, rankingi, reklamy i zakupy.

## Kryteria akceptacji
1. Projekt eksportuje się do APK przez workflow GitHub Actions.
2. Górnicy automatycznie niszczą bloki i przyznają nagrody.
3. Można kupić trzech typów górników i ulepszenia.
4. Każde z 30 pięter ma własny poziom rozbudowy, nie mniejszy niż 0 i nie większy niż 800.
5. Zniszczenie bloków kończy piętro; ukończone piętra można odwiedzić ponownie.
6. Monety, kryształy i dodatkowa nagroda są poprawnie naliczane.
7. Stan gry odtwarza się po restarcie; uszkodzony zapis nie wyłącza gry.
8. Interfejs działa w orientacji pionowej i pozostaje czytelny na ekranie telefonu.

## Otwarte do strojenia
Startowe ceny, zdrowie bloków, nagrody, krzywe kosztu i premia rozbudowy będą wartościami konfiguracyjnymi, dostrajanymi podczas testów.