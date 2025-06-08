# OpenProject Planning Poker Plugin

Ein Plugin, dass OpenProject um die Funktion Planning Poker zur Aufwandschätzung von User Stories erweitert.

## Funktionen

- Interaktive Planning Poker Sessions für Teams
- Echtzeit-Voting mit mehreren Nutzern
- Tabellarische Gegenüberstellung der Ergebnisse im Team
- Berechnung der Durchschnittswerte und Konsens-Rate
- Automatische Übertragung der Story Points in OpenProject
- Verwaltung von Sessions (Start, Neustart, Beitritt)

## Voraussetzungen

- OpenProject >= 13.0.0
- PostgreSQL Datenbank
- Ein vorhandenes Feld "Story Points" in den jeweiligen Arbeitspaketen

## Installation

### Docker-Installation

1. **Plugin herunterladen** ins eigene OpenProject-Verzeichnis:
```bash
# Im Verzeichnis, dass die Datei docker-compose.yml enthält
mkdir -p plugins
cd plugins
git clone https://github.com/Paul-Hostert/openproject-planning_poker.git
```

2. **Plugin mounten** im eigenen `docker-compose.yml` oder in einer neu erstellten `docker-compose.override.yml`:
```yaml
version: '3.7'

services:
  web:
    volumes:
      - ./plugins/openproject-planning_poker:/app/modules/openproject-planning_poker:ro
  
  worker:
    volumes:
      - ./plugins/openproject-planning_poker:/app/modules/openproject-planning_poker:ro
```

3. **Datenbank-Migrationen durchführen**:
```bash
docker-compose run --rm web bundle exec rake db:migrate
```

4. **Container neustarten**:
```bash
docker-compose down
docker-compose up -d
```

### Manuelle Installation

1. **Plugin clonen** im eigenen OpenProject Modules Verzeichnis:
```bash
cd /path/to/openproject
git clone https://github.com/Paul-Hostert/openproject-planning_poker.git modules/openproject-planning_poker
```

2. **Abhängigkeiten installieren** (falls nötig):
```bash
bundle install
```

3. **Migrationen durchführen**:
```bash
RAILS_ENV=production bundle exec rake db:migrate
```

4. **OpenProject neustarten**:
```bash
sudo systemctl restart openproject
# oder ein eigener Neustart-Befehl
```

## Konfiguration

### 1. Modul aktivieren

1. Zum gewünschten Projekt navigieren
2. Dann zu **Projektkonfiguration** → **Module**
3. Haken bei **Planning Poker** setzen
4. Dann **Speichern**

### 2. Feld für Story Points anlegen (falls nicht vorhanden)

Das Plugin schreibt automatisch Ergebnisse in dieses Feld. So wird es erstellt:

1. Oben rechts beim Admin-Nutzer auf **Administration** → **Benutzerdefinierte Felder**
2. Klick auf **+ Benutzerdefiniertes Feld** für Arbeitspakete
3. Dann:
   - **Name**: Story Points
   - **Format**: Integer
   - **Für alle Projekte**: Ja
4. Dann speichern und zu den gewünschten Typen (z.B. User Story) hinzufügen

Alternativ per Rails-Konsole:
```ruby
cf = WorkPackageCustomField.create!(name: 'Story Points', field_format: 'int', is_for_all: true)
Type.all.each { |t| t.custom_fields << cf unless t.custom_fields.include?(cf) }
```

## Bedienung

### Session starten

1. **Planning Poker** in der Seitenleiste des Projekts anklicken
2. Relevante Stories oder Tasks auswählen
3. Teilnehmende Teammitglieder auswählen (optional)
4. Dann **Planning Poker starten**

### Einer Session beitreten

Wenn eine Session aktiv ist, wird sie anderen Teammitgliedern angezeigt:
- Ein grüner Kasten oben zeigt die Session an (evtl. Refresh nötig)
- Dann Klick auf **Session beitreten**

### Voting

1. Die zuvor ausgewählten Stories werden nacheinander angezeigt
2. Jeder Teilnehmer gibt seine Schätzung ab
3. Danach **Weiter** um die nächste Story zu sehen
4. Zuletzt werden alle Ergebnisse tabellarisch angezeigt

### Ergebnis

Die Ergebnisseite zeigt:
- Votes aller Teammitglieder sortiert nach Story
- Durchschnittswert und gerundeter Wert pro Story
- Konsens-Rate
- Buttons für:
  - **Story Points speichern** in den Arbeitspaketen
  - **Session neustarten**

## Fehlerbehebung

### Modul wird nicht in der Projektkonfiguration angezeigt
- Refresh der Seite, notfalls Server neustarten
- Logs auf Ladefehler des Plugins überprüfen
- Prüfen, ob das Plugin im richtigen Verezichnis liegt

### Story Points werden nicht gesichert
- Sichergehen, ob das Feld "Story Points" existiert
- Prüfen, ob das Feld in allen verwendeten Typen (User Story usw.) aktiviert ist
- Sicherstellen, dass der ausführende Nutzer Arbeitspakete bearbeiten darf

### Session-Probleme
- Sessions laufen nach 2 Stunden Inaktivität ab
- Für jedes Projekt darf es nur eine aktive Session geben
- Falls die Session durch ein anderes Teammitglied beendet wurde, führt ein Refresh zur Startseite zurück

## Entwicklung

### Plugin-Struktur
```
openproject-planning_poker/
├── app/
│   ├── controllers/
│   ├── models/
│   └── views/
├── config/
│   └── routes.rb
├── db/
│   └── migrate/
├── lib/
├── init.rb
└── openproject-planning_poker.gemspec
```

### Versionshistorie

## Weitere Informationen

Entwickelt von Paul Hostert im Rahmen der Bachelorarbeit
**Analyse und Erweiterung der Fähigkeiten von OpenProject in Bezug auf dieeffiziente Planung und Steuerung agiler Software-Entwicklungsprojekte**
