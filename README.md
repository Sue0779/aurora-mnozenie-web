# Aurora Mnożenie Web

Aurora Mnożenie Web to mała aplikacja Flask do ćwiczenia tabliczki mnożenia. 
Losuje zadania po stronie serwera i prezentuje je w prostej, pastelowej 
aplikacji przeglądarkowej. Odpowiedzi są walidowane z wykorzystaniem sesji, 
dzięki czemu nie można wysłać rozwiązań dla innych przykładów ani ominąć
walidacji poprzez zmianę nagłówków żądań.

## Struktura projektu
- `app.py` – serwer Flask generujący zadania i weryfikujący odpowiedzi.
- `templates/index.html` – interfejs użytkownika aplikacji.
- `static/style.css` – stylizacja interfejsu.
- `setup_mnozenie_web.sh` – pomocniczy skrypt do uruchamiania aplikacji.

## Uruchomienie lokalne
1. Zainstaluj zależności: `pip install flask`.
2. Ustaw opcjonalny sekret sesji: `export FLASK_SECRET_KEY="super_tajny_klucz"`.
3. Uruchom aplikację: `python app.py`.
4. Odwiedź `http://localhost:8000` w przeglądarce.

## Funkcje bezpieczeństwa
- Wymuszanie nagłówka `Content-Type: application/json` w żądaniach weryfikacji.
- Losowanie i przechowywanie zadań w sesji użytkownika z czasem życia 5 minut.
- Sprawdzanie zgodności przesłanych operandów z aktualnym zadaniem.
- Normalizacja i walidacja odpowiedzi, aby odfiltrować błędne dane wejściowe.

Aplikacja może stanowić punkt wyjścia do dalszego rozwijania ćwiczeń
matematycznych w sieci Aurora.
