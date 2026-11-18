# Erklärungen zu Aufgabe 8–10 (PathPlanning)

| Datei | Was sie tut |
|---|---|
| `MATLAB/livescripts/LS08_Fahrzeug.m` | Live Script Kap. 08: erklärt `car_primitives`/`car_neighbors` (Bögen, Rotation, Körperprüfung), führt `check_car_primitives`, `check_car_neighbors` und `experiment_cc_point_vs_model` aus. |
| `MATLAB/livescripts/LS09_Rundkurs.m` | Live Script Kap. 09 (Oval): Checkpoint-Kette, Fünf-Stufen-Pipeline, Tempo-Decken, Vollgas-Crash, `safety`-Sweep, Ankunftsrichtungen (4b), Messbasis ±1/±3. |
| `MATLAB/livescripts/LS10_Tuning.m` | Live Script Kap. 10 (echte Strecke): Heuristik-Tabelle, Rand-Fenster, Grip-Reserve, Einzelwert-Sweeps, `LdMax`/`Ld0`-Erklärung, Zielwerte S/F im `cfg`-Block. |
| `ERKLAERUNG/08_…html`, `09_…html`, `10_…html` | Eine Erklärseite pro Aufgabe (im Browser öffnen): was gemacht wurde, Wirkung, Ausgabe-Analyse, Prüfungsfragen. |

Hinweis: Die erwarteten Ausgaben stammen aus einer Python-Nachrechnung, nicht aus MATLAB. Zuerst `LS10_Tuning.m` Abschnitt 0 ausführen (kleinster Radius 0,296 m = Guide-Variante, 0,104 m = Repo-Variante mit ±1-Krümmung).
