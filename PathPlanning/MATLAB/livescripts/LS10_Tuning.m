%[text] # Kapitel 10 – Die echte Strecke und das Einstellen von acht Werten
%[text] **Dateien:** `experiments/experiment_cc_lap.m`, `experiments/experiment_cc_tuning.m`, `tools/cc_tuning_defaults.m`, `tools/cc_scorecard.m`, `tools/cc_car_heuristic.m`
%[text] **Bevor du startest:** Current Folder auf `MATLAB/` setzen, dann Abschnitt für Abschnitt mit *Run Section* ausführen. Das Ziel (Schritt 6) ist, **acht Werte** so zu wählen, dass Rundenzeit, Clearance und Grip-Reserve gleichzeitig stimmen – auf der echten Strecke **und** auf dem Oval.
%[text] **Zu den Zahlen:** Wie in Kapitel 09 stehen unter "Erwartete Ausgabe" zwei Varianten: *Guide* (Krümmung über ±3 Punkte, so reproduziert sich jede Zahl des Guides) und *Repo* (Code in `tools/` genau wie gelesen, Krümmung über ±1). Die **Planung** (Legs, Expansionen, Heuristik) ist identisch; Zeiten und Reserve unterscheiden sich. Prüfe in Abschnitt 1, welche Variante dein MATLAB liefert.
%%
%[text] ## 0  Welche Variante hat dein MATLAB? (zuerst ausführen)
%[text] Der Test ist eine einzige Zahl: kleinster Radius der Oval-Route. Ein Auto mit $L = 0{,}12$ m und $\\delta_\\mathrm{max} = 22°$ kann **keinen engeren Kreis als 0,297 m** fahren.
if exist('setup_path', 'file') ~= 2, cd('..'), end
setup_path
P0 = cc_params('Track','oval');
poses0 = cc_lap_plan(cc_car_model(cc_track(P0), P0), 'Verbose', false);
XY0 = cc_resample_path(poses0(:,1:2), 0.04);
[~, kap0] = cc_speed_profile(XY0, P0);
fprintf('kleinster Radius laut cc_speed_profile: %.3f m  (physikalisches Minimum %.3f m)\n', 1/max(kap0), P0.L/tand(P0.deltaMax));
%[text] **0,296 m** ⇒ dein MATLAB entspricht dem Guide, alle Guide-Zahlen sollten stimmen. **0,104 m** ⇒ Repo-Variante (±1): Radius kleiner als das Auto fahren kann = Messartefakt an den Knickstellen der Route (siehe LS09 Abschnitt 9); Zeiten ca. 1 s (Oval) bzw. 3 s (echte Strecke) länger, die Reserve fast immer 60 %.
%%
%[text] ## 1  Die acht Werte (Dateitour)
%[text:table]
%[text] | Wert | Standard | was er entscheidet | wirkt in |
%[text] | --- | --- | --- | --- |
%[text] | `safety` | 0,05 m | Abstand Planer ↔ Wand | Planung (`cc_params`) |
%[text] | `ayPlan` | 1,00 | Bruchteil des Grips, mit dem das Profil plant | `cc_speed_profile` |
%[text] | `ABrake` | 2,5 m/s² | wie hart das Profil bremsen darf | `cc_speed_profile` |
%[text] | `AAccel` | 2,0 m/s² | wie hart es beschleunigen darf | `cc_speed_profile` |
%[text] | `Ld0` | 0,16 m | Vorausschau im Stand | `cc_pure_pursuit` |
%[text] | `kLd` | 0,08 s | zusätzliche Vorausschau pro m/s | `cc_pure_pursuit` |
%[text] | `LdMax` | 0,35 m | längste Vorausschau | `cc_pure_pursuit` |
%[text] | `kv` | 90 %/(m/s) | Gas pro m/s Geschwindigkeitsfehler | `cc_pure_pursuit` |
%[text:table]
%[text] Nicht ändern dürfen wir das **Auto** (`P.ayMax`, `P.bodyL`, `P.bodyW`, `P.L`, `P.deltaMax`, `P.Vdead`). Einstellen = entscheiden, was man von einem *gegebenen* Fahrzeug verlangt. Der **einzige** Block, den man in `experiment_cc_tuning.m` ändert, ist `cfg = cc_tuning_defaults();` oben.
%%
%[text] ## 2  Schritt 1 – Eine Runde auf der echten Strecke
run('experiments/experiment_cc_lap.m')
%[text] **Erwartete Ausgabe (Planung identisch in beiden Varianten):**
%[text:table]
%[text] | Leg | Ziel | Posen | Kosten | Expansionen | Ankunftsrichtung |
%[text] | --- | --- | --- | --- | --- | --- |
%[text] | 1 | (6,18; 1,65) | 30 | 3,53 m | 453 | +90,0° |
%[text] | 2 | (4,35; 2,55) | 21 | 2,46 m | 84 | +179,5° |
%[text] | 3 | (3,00; 1,15) | 46 | 5,69 m | **1955** | +179,0° |
%[text] | 4 | (0,50; 2,45) | 29 | 3,47 m | 935 | +179,5° |
%[text] | 5 | (0,45; 1,35) | 11 | 1,29 m | 46 | +291,5° |
%[text] | 6 | (3,50; 0,60) | 31 | 3,65 m | 184 | +21,5° |
%[text:table]
%[text] `LAP: 163 poses, 20.10 m, 3657 expansions. Closes: yes (95 mm, 21 deg)`. Dann **Guide:** `LAP TIME 12.20 s`, Topspeed 2,02 m/s, Spurfehler max 60 mm. **Repo:** `LAP TIME 15.08 s`, Topspeed 1,95 m/s, Spurfehler max 59 mm.
%[text] **Warum Leg 3 mehr als die Hälfte der Arbeit kostet** (1955 von 3657 Expansionen): Luftlinie von CP2 (4,35; 2,55) nach CP3 (3,00; 1,15) ist nur 1,97 m und läuft **durch die Wand** zwischen rechter oberer Tasche und mittlerem Kanal. Das Auto muss herunter und herum: 5,69 m. Die Heuristik (Luftlinie) ist hier **uniform viel zu klein**. Vergleiche mit dem tatsächlichen Aufwand:
P = cc_params();  T = cc_track(P);  CM = cc_car_model(T, P);
[poses, info] = cc_lap_plan(CM, 'Verbose', false);
pose = P.start;
fprintf(' leg   h(start)  wahre Kosten  Verhältnis  Expansionen\n');
for k = 1:numel(info.legs)
    h = cc_car_heuristic(pose, info.legs(k).goal);           % Luftlinie zum Ziel
    fprintf('  %d   %8.3f   %8.3f      %5.2f      %6d\n', k, h, info.legs(k).cost, info.legs(k).cost/h, info.legs(k).expansions);
    pose = info.legs(k).poses(end,:);                          % nächstes Leg startet hier
end
%[text] **Erwartete Ausgabe (identisch in beiden Varianten):**
%[text:table]
%[text] | leg | h(start) | wahre Kosten | Verhältnis | Expansionen |
%[text] | --- | --- | --- | --- | --- |
%[text] | 1 | 2,878 | 3,531 | 1,23 | 453 |
%[text] | 2 | 2,029 | 2,460 | 1,21 | 84 |
%[text] | 3 | 1,974 | 5,695 | **2,89** | **1955** |
%[text] | 4 | 2,953 | 3,472 | 1,18 | 935 |
%[text] | 5 | 1,150 | 1,290 | 1,12 | 46 |
%[text] | 6 | 3,183 | 3,650 | 1,15 | 184 |
%[text:table]
%[text] **Erklärung:** Fünf Legs haben Sichtlinie zum Ziel, dort liegt der Schätzwert nur ≤ 23 % daneben. Leg 3 ist um den Faktor 2,89 zu klein – und zwar **in der ganzen Region**. A\* nimmt den Knoten mit kleinstem $f = g + h$; ist $h$ überall zu klein, wirken alle Knoten billig, die Suche **breitet sich flächig aus**, statt die Region zu durchqueren – sie degeneriert dort zu Dijkstra. Die Heuristik ist weiterhin **zulässig** (überschätzt nie) ⇒ die Route bleibt optimal, nur die Arbeit ist verschwendet. *Zulässigkeit kauft Korrektheit, nicht Geschwindigkeit.* Dichte: Oval 185/6,05 m ≈ 31 pro m, hier 3657/19,23 m ≈ 190 pro m.
%%
%[text] ## 3  Schritt 2 – Das Rand-Fenster schließt sich
%[text] Dieselbe Schleife wie in Kapitel 09, aber mit `cc_params()` (echte Strecke).
for saf = [0.00 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.10]
    P  = cc_params('safety', saf);
    T  = cc_track(P);
    CM = cc_car_model(T, P);
    try
        [poses, info] = cc_lap_plan(CM, 'Verbose', false);
    catch err
        fprintf('safety %.2f : %s\n', saf, err.message(1:min(40,end)));
        continue
    end
    XY   = cc_resample_path(poses(:,1:2), 0.04);
    vRef = cc_speed_profile(XY, P);
    log  = cc_simulate(T, [XY, vRef]);
    if log.crashed
        fprintf('safety %.2f : CRASH at (%.2f, %.2f) after %.2f s\n', saf, log.crashAt(1), log.crashAt(2), log.t(end));
    else
        fprintf('safety %.2f : %.2f s, clearance %4.1f mm, %d expansions\n', saf, log.lapTime, 1000*cc_clearance(T, log), info.expansions);
    end
end
%[text] **Erwartete Ausgabe:**
%[text:table]
%[text] | `safety` | Guide | Repo | Expansionen |
%[text] | --- | --- | --- | --- |
%[text] | 0,00 | Crash (5,82; 0,68) nach 1,64 s | Crash (5,83; 0,68) nach 1,68 s | |
%[text] | 0,02 | Crash (5,83; 0,68) nach 1,64 s | Crash (5,83; 0,68) nach 1,68 s | |
%[text] | 0,03 | Crash (5,90; 0,71) nach 1,68 s | Crash (5,88; 0,70) nach 1,72 s | |
%[text] | 0,04 | **Crash (1,65; 2,44) nach 8,24 s** | 14,96 s, 9,3 mm | 3615 |
%[text] | 0,05 | 12,20 s, 19,2 mm | 15,08 s, 21,2 mm | 3657 |
%[text] | 0,06 | 12,16 s, 17,0 mm | 15,00 s, 16,5 mm | 3577 |
%[text] | 0,07 | 12,12 s, 21,8 mm | 14,96 s, 19,5 mm | 3295 |
%[text] | 0,08 | 12,32 s, **38,3 mm** | 15,28 s, 36,4 mm | 3138 |
%[text] | 0,10 | **keine Route** (`leg 1 failed`) | **keine Route** | |
%[text:table]
%[text] **(a) Der wandernde Crash (Guide):** Der Rand hat nie *das* Problem gelöst, sondern jeweils das aktuell schlimmste. Bei 0,03 ist die engste Stelle die rechte Umkehrkurve; wird der Rand größer, überlebt man sie, und die **nächst-engste** Stelle am anderen Ende der Strecke wird sichtbar. 0,05 ist der Wert, bei dem die schlimmste verbleibende Stelle zufällig überlebbar ist. ⇒ 0,05 m ist eine **Messung dieser Strecke**, keine Eigenschaft des Autos.
%[text] **(b) Die Zahl, die das Fenster schließt:** Der engste Gang ist **0,59 m** breit. Mit Rand $s$ auf beiden Seiten bleiben $0{,}59 - 2s$. Das schräg stehende Auto ragt $d(\\psi) = \\tfrac{\\mathrm{bodyL}}{2}\\sin\\psi + \\tfrac{\\mathrm{bodyW}}{2}\\cos\\psi$ bis 0,122 m heraus (bei 64,5°). Bei $s = 0{,}10$ m schließen die aufgeblasenen Wände die rechte Umkehrkurve von Leg 1 – keine Posenfolge bleibt. Auf dem Oval war selbst 0,12 m noch bequem: gleicher Code, gleiches Auto, **die Strecke entscheidet**.
%[text] **Merke:** Ein Wert, der fast kostenlos Clearance kauft, ist `safety` 0,05 → 0,08: Clearance 19 → 38 mm, Zeit +0,12 s (Guide) und das Suchen wird sogar **billiger** (3657 → 3138 Expansionen). Diesen Wert zuerst setzen, den Rest dafür ausgeben.
%%
%[text] ## 4  Schritt 3 – Warum zwei Zahlen nicht reichen (Grip-Reserve)
%[text] Die dritte Zahl: Dieselbe Route mit demselben Regler, aber die Reifen werden schrittweise schwächer gemacht (95 %, 90 %, … 60 % von `P.ayMax`). **Reserve** = niedrigster Wert, bei dem die Runde noch klappt. **Klein ist gut.** Ein Auto am Limit hat 100 %; ein reales Auto ist immer ein paar Prozent schlechter als sein Modell.
base = cc_tuning_defaults();
S = cc_scorecard(base);                                   % Standardwerte
fprintf('defaults : %5.2f s | clearance %4.1f mm | reserve %3.0f %% | grip limit in %d of %d steps\n', ...
    S.lap, 1000*S.clear, 100*S.reserve, sum(S.log.slipping), numel(S.log.t));
cfg = base;  cfg.ayPlan = 1.7;
S = cc_scorecard(cfg);
fprintf('ayPlan 1.7: %5.2f s | clearance %4.1f mm | reserve %3.0f %% | grip limit in %d of %d steps\n', ...
    S.lap, 1000*S.clear, 100*S.reserve, sum(S.log.slipping), numel(S.log.t));
%[text] **Erwartete Ausgabe:**
%[text:table]
%[text] | | Guide: Zeit | Clear. | Reserve | am Limit | Repo: Zeit | Clear. | Reserve | am Limit |
%[text] | --- | --- | --- | --- | --- | --- | --- | --- |
%[text] | Standard | 12,20 s | 19,2 mm | 65 % | 2 von 306 | 15,08 s | 21,2 mm | 60 % | 0 von 378 |
%[text] | `ayPlan` 1,7 | **10,68 s** | 18,1 mm | **95 %** | 30 von 268 | 13,24 s | 20,5 mm | 60 % | 3 von 332 |
%[text:table]
%[text] **Was `ayPlan = 1,7` verlangt:** In `vRef(turning) = min(o.VMax, sqrt(o.AyMax ./ kappa(turning)))` wird `AyMax = 1,7·P.ayMax`. Die Kurvengeschwindigkeit darf $\\sqrt{1{,}7} = 1{,}30$-mal höher sein, als die Reifen halten. Das ist keine schnellere Runde, sondern ein Plan **für ein Auto mit 70 % mehr Grip**. Es steht 30 von 306 Schritten am Grip-Limit (statt 2).
%[text] **Was physikalisch beim Versagen passiert:** Sinkt der Grip, kann das Auto die geplante Querbeschleunigung nicht mehr aufbauen, es **untersteuert**: es fährt geradeaus weiter als gelenkt, driftet nach außen – und außen in der Kurve ist die Wand. Die Clearance konnte das nicht zeigen, weil auf der tatsächlich gefahrenen Runde keine Wand nah war. *Zwei Zahlen messen zwei Arten von Platz; dieses Setup hatte den ungemessenen aufgebraucht.*
%[text] **Repo-Variante:** Hier bleibt die Reserve selbst bei `ayPlan` 1,7 auf 60 %, weil das ±1-Profil durch die Knick-Artefakte ohnehin zu vorsichtig plant (kleinster Radius 0,10 statt 0,30 m ⇒ überall Bremsen). Der Zielkonflikt des Guides taucht erst auf, wenn das Profil „richtig" misst.
%%
%[text] ## 5  Schritt 4 – Ein Wert nach dem anderen
%[text] **Vor dem Messen** auf Papier je Wert und Zahl ein Vorzeichen festlegen (24 Felder): besser (+), schlechter (−) oder neutral (0)? Danach messen. Messschleife (am Beispiel `Ld0`; ersetze Feld und Werte):
base = cc_tuning_defaults();
for v = [0.08 0.12 0.16 0.22 0.30]
    cfg = base;  cfg.Ld0 = v;
    S = cc_scorecard(cfg);
    fprintf('Ld0 %.2f -> %5.2f s | reserve %3.0f %% | %4.1f mm | %d slipping\n', ...
        v, S.lap, 100*S.reserve, 1000*S.clear, sum(S.log.slipping));
end
%[text] **Erwartete Ausgabe (Guide-Variante):**
%[text:table]
%[text] | Wert | Zeit | Reserve | Clearance | am Limit |
%[text] | --- | --- | --- | --- | --- |
%[text] | `Ld0` 0,08 | 12,52 s | **90 %** | **29,7 mm** | 7 |
%[text] | `Ld0` 0,12 | 12,24 s | 65 % | 25,6 mm | 4 |
%[text] | `Ld0` 0,16 | 12,20 s | 65 % | 19,2 mm | 2 |
%[text] | `Ld0` 0,22 | 12,12 s | 70 % | **11,0 mm** | 1 |
%[text] | `Ld0` 0,30 | 12,12 s | 70 % | 11,0 mm | 1 |
%[text] | `kLd` 0,00 | Crash bei (4,21; 2,79) nach 4,08 s | | |
%[text] | `kLd` 0,18 | 12,12 s | 70 % | 11,0 mm | 1 |
%[text:table]
%[text] Die übrigen Blöcke (`ayPlan`, `LdMax`, `ABrake`, `AAccel`, `kv`) laufen mit genau derselben Schleife. Zusammenfassung der **Vorzeichen** (Guide-Variante, jeweils beim *Erhöhen* des Werts):
%[text:table]
%[text] | Wert ↑ | Rundenzeit | Clearance | Grip-Reserve (niedrig = gut) |
%[text] | --- | --- | --- | --- |
%[text] | `safety` (0,05→0,08) | ≈ 0 (+0,12 s) | **besser** (19→38 mm) | ≈ 0 (65 %) |
%[text] | `ayPlan` | **besser** (13,9→10,7 s) | ≈ 0 | **schlechter** (60→95 %) |
%[text] | `ABrake` | besser | schlechter (19→16 mm) | schlechter (65→75 %) |
%[text] | `AAccel` | besser | schlechter (19→15 mm) | leicht schlechter (65→70 %) |
%[text] | `Ld0` | leicht besser | **schlechter** (30→11 mm) | **besser** (90→65 %) |
%[text] | `kLd` | wie `Ld0` | wie `Ld0` | wie `Ld0` (bei 0: Crash) |
%[text] | `LdMax` | 0 (ab 0,28 m) | 0 | 0 |
%[text] | `kv` | **besser** (14,8→11,1 s) | ≈ 0 (Schwankung 17–22 mm) | leicht schlechter (60→70 %) |
%[text:table]
%[text] Die Zahlen für `ayPlan`, `ABrake`, `AAccel`, `kv` und `LdMax` stehen im Guide (Schritt 4) und wurden in der Nachrechnung exakt reproduziert.
%%
%[text] ## 6  Schritt 5a – Warum `LdMax` ab 0,28 m nichts ändert
%[text] $L_d = L_{d0} + k_{Ld}\\,v$, gedeckelt bei `LdMax`. Schnellster Punkt der Runde: 2,02 m/s ⇒ größter vorkommender Wert $0{,}16 + 0{,}08\\cdot 2{,}02 = 0{,}32$ m < 0,35 m. Der Deckel wird **nie berührt**. Bei 0,22 beginnt er auf den Geraden zu greifen (nur diese Zeile bewegt sich). Ein Knopf, der nichts tut, ist nicht harmlos – man greift im Fehlerfall danach und verliert eine Stunde.
S0 = cc_scorecard(cc_tuning_defaults(), 'Reserve', false);
vmax = max(S0.log.v);
base = cc_tuning_defaults();
fprintf('v_max = %.2f m/s  =>  Ld_max_noetig = %.3f m  (Deckel %.2f m)\n', vmax, base.Ld0 + base.kLd*vmax, base.LdMax);
%[text] **Erwartete Ausgabe:** Guide `v_max = 2.02 m/s => 0.322 m (Deckel 0.35 m)`; Repo `v_max = 1.95 m/s => 0.316 m`. In beiden Fällen < 0,35 m ⇒ LdMax gehört auf die Liste der **nicht geänderten** Werte.
%%
%[text] ## 7  Schritt 5b – Warum sich die beiden Sicherheitszahlen widersprechen (`Ld0`)
%[text] Lenkgesetz: $\\delta = \\arctan\\!\\left(\\dfrac{2L\\sin\\alpha}{L_d}\\right)$. $L_d$ steht im **Nenner**.
%[text] - **Kurzer Blick (0,08 m): viel Platz, keine Grip-Reserve.** Gleiche Abweichung ⇒ **größerer Lenkwinkel**. Das Auto klebt an der geplanten Linie (die der Planer 50 mm von der Wand legte), korrigiert aber so hart, dass es 7 statt 1 Schritt am Grip-Limit fährt. Fehlen 15 % Grip, kann es die eigenen Korrekturen nicht mehr aufbringen und läuft nach außen: Reserve 90 %.
%[text] - **Langer Blick (0,22 m): kein Platz, Grip im Überfluss.** Das Auto zielt an der Kurve vorbei und **schneidet** sie: schneller, aber die 8 mm Gewinn kommen direkt aus dem Rand des Planers (Clearance 11 mm). Eine geschnittene Kurve hat größeren Radius als die geplante, verlangt also weniger Grip: 1 Schritt am Limit statt 7.
%[text] **Zwei Zahlen = zwei Ausfallarten:** *Clearance* = wie viel vom Rand des Planers der Regler zurückgegeben hat; *Reserve* = wie nah die Runde an der Reifengrenze ist. Deshalb ersetzt keine Einzelzahl die anderen. Erst die Reserve begrenzen (≳ 85 % = nicht fahrbar), den Rest in Zeit ausgeben.
%%
%[text] ## 8  Schritt 6 – Ziel treffen
%[text] **Ziel S (reale Hardware):** Clearance ≥ 35 mm, Reserve ≤ 70 %, Zeit < 11,60 s. **Ziel F (schnell, mit Boden):** Zeit ≤ 11,00 s, Clearance ≥ 25 mm, Reserve ≤ 70 %. Beide müssen mit **denselben Werten** auch das Oval schaffen.
%[text] **Vorgehen:** (1) `safety` zuerst auf 0,08 (Clearance fast gratis). (2) `Reserve=false` zum Suchen (8× schneller), Reserve nur für 2–3 Kandidaten. (3) Oval am Ende.
%[text] **Eingetragene Werte (Konfiguration, die ich mit der Nachrechnung gefunden habe). Wähle die zu deiner Variante aus Abschnitt 0 passende Zeile:**
%[text:table]
%[text] | Wert | **Variante Repo (±1)** | **Variante Guide (±3)** |
%[text] | --- | --- | --- |
%[text] | `safety` | 0,08 | 0,08 |
%[text] | `ayPlan` | 1,40 | 1,10 |
%[text] | `ABrake` | 8 | 2,5 |
%[text] | `AAccel` | 10 | 4 |
%[text] | `Ld0` | 0,10 | 0,10 |
%[text] | `kLd` | 0,12 | 0,08 |
%[text] | `LdMax` | 0,35 (unverändert) | 0,35 (unverändert) |
%[text] | `kv` | 140 | 140 |
%[text:table]
cfg = cc_tuning_defaults();
% ---- VARIANTE REPO (±1), aus Abschnitt 0 -> Radius 0.104 -----------------
cfg.safety = 0.08;   cfg.ayPlan = 1.40;  cfg.ABrake = 8;    cfg.AAccel = 10;
cfg.Ld0    = 0.10;   cfg.kLd    = 0.12;  cfg.LdMax  = 0.35; cfg.kv     = 140;
% ---- VARIANTE GUIDE (±3) -> Radius 0.296: diese Zeilen statt der obigen ----
% cfg.safety = 0.08; cfg.ayPlan = 1.10;  cfg.ABrake = 2.5;  cfg.AAccel = 4;
% cfg.Ld0    = 0.10; cfg.kLd    = 0.08;  cfg.LdMax  = 0.35; cfg.kv     = 140;
S = cc_scorecard(cfg);                                  % echte Strecke
O = cc_scorecard(cfg, 'Track', 'oval');                  % Gegenprobe: Oval
fprintf('echte Strecke: %5.2f s | clearance %4.1f mm | reserve %3.0f %%\n', S.lap, 1000*S.clear, 100*S.reserve);
fprintf('Oval         : %5.2f s | clearance %4.1f mm | reserve %3.0f %%\n', O.lap, 1000*O.clear, 100*O.reserve);
%[text] **Erwartete Ausgabe:**
%[text:table]
%[text] | | Variante Repo | Variante Guide |
%[text] | --- | --- | --- |
%[text] | echte Strecke | **10,92 s / 38,7 mm / 65 %** | **10,96 s / 47,6 mm / 70 %** |
%[text] | Oval | 4,08 s / 45,5 mm / 60 % | 3,92 s / 55,1 mm / 60 % |
%[text] | Ziel S (≥ 35 mm, ≤ 70 %, < 11,60 s) | **erfüllt** | **erfüllt** |
%[text] | Ziel F (≤ 11,00 s, ≥ 25 mm, ≤ 70 %) | **erfüllt** | **erfüllt** (10,96 s ist knapp unter 11,00) |
%[text:table]
%[text] **Wichtig:** Die Werte der einen Variante funktionieren in der anderen **nicht** (Repo-Werte unter ±3: 9,60 s, 19,8 mm, **100 %** Reserve; Guide-Werte unter ±1: 13,48 s). Sie sind also an das jeweilige Geschwindigkeitsprofil angepasst. Falls dein MATLAB leicht andere Zahlen liefert (Simulator, Rundung), starte mit meinen Werten und verbessere die Kandidaten mit `Reserve=false`.
%%
%[text] ## 9  Was abzugeben ist (Vorlage)
%[text] **1. Meine acht Werte und die drei Zahlen auf beiden Strecken:** siehe Tabelle oben.
%[text] **2. Pro geändertem Wert: was ich gekauft und was ich bezahlt habe** (Guide-Variante, ausgehend vom Standard 12,20 s / 19,2 mm / 65 %):
%[text] - `safety` 0,05 → 0,08: kaufte **+19 mm Clearance** (19 → 38), zahlte 0,12 s – weil der Rand die Route in die Gangmitte drückt (größerer Radius), nebenbei 500 Expansionen weniger.
%[text] - `kv` 90 → 140: kaufte **≈ 0,7 s** (12,20 → 11,48), zahlte ≈ 5 Punkte Reserve (65 → 70 %) – der Regler jagt dem Soll-Tempo härter nach und verbringt mehr Schritte am Grip-Limit (2 → 5).
%[text] - `ayPlan` > 1: kauft pro 0,1 ca. 0,3 s, zahlt aber **Reserve** – darum nur wenig anheben (1,1) bzw. nur, wenn die Reserve unter 70 % bleibt.
%[text] - `Ld0` 0,16 → 0,10: bezahlt etwas Clearance, bringt Reserve – der Gegenpol zu `ayPlan`.
%[text] **3. Nicht geänderte Werte und warum:** `LdMax` (greift nie, 0,16 + 0,08·2,02 = 0,32 < 0,35; Schritt 5a).
%[text] **4. Ein Satz zum gewählten Ziel:** *Ich habe Ziel S gewählt (und F erfüllt es ebenfalls): ein Lauf mit ≥ 35 mm Rand und 30 % Grip-Reserve ist das, was man für ein Auto will, das viele Runden unbeaufsichtigt überleben muss; für eine Vorführung vor der Klasse genügt F.*
%%
%[text] ## 10  Checkpoint
%[text] - `experiment_cc_lap.m` ergibt eine Runde, die schließt ✔
%[text] - Warum Leg 3 mehr als die Hälfte der Suche kostet (Heuristik 2,89× zu klein) ✔
%[text] - Warum das Rand-Fenster 0,05–0,08 m ist (engster Gang 0,59 m, Auto-Überstand 0,122 m) ✔
%[text] - 24-Felder-Vorhersagetabelle **vor** dem Messen ausfüllen ✔ (Vorlage in Abschnitt 5)
