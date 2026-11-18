%[text] # Kapitel 09 – Die Übungsstrecke (Oval): vom Plan zur Rundenzeit
%[text] **Dateien:** `experiments/experiment_oval_lap.m`, `tools/cc_lap_plan.m`, `cc_resample_path.m`, `cc_speed_profile.m`, `cc_pure_pursuit.m`, `cc_simulate.m`, `cc_clearance.m`
%[text] **Bevor du startest:** Current Folder auf `MATLAB/` setzen, dann Abschnitt für Abschnitt mit *Run Section* ausführen. Nur die erste Stufe (Planung) nutzt deine Arbeit aus Kapitel 08, alle anderen Stufen sind fertig.
%[text] **Wichtiger Hinweis zu den Zahlen:** Unter "Erwartete Ausgabe" stehen zwei Spalten: *Guide* (so steht es im Guide) und *Repo* (was die Nachrechnung mit dem Code in `tools/` genau so, wie er im Repo liegt, ergibt). Die **Planung** (Legs, Posen, Expansionen) ist in beiden Fällen identisch, die **Zeiten** unterscheiden sich – Grund in Abschnitt 9.
%%
%[text] ## 1  Die fünf Stufen von Plan zu Rundenzeit
%[text:table]
%[text] | Stufe | Funktion | rein | raus |
%[text] | --- | --- | --- | --- |
%[text] | 1 | `cc_lap_plan` | Fahrzeugmodell | Liste von **Posen** |
%[text] | 2 | `cc_resample_path` | Posen | Punkte alle **4 cm** |
%[text] | 3 | `cc_speed_profile` | Punkte | eine **Soll-Geschwindigkeit** pro Punkt |
%[text] | 4 | `cc_pure_pursuit` | Route, Zustand des Autos | Gas und Lenkung |
%[text] | 5 | `cc_simulate` | alles | **Rundenzeit** oder Crash |
%[text:table]
%[text] Die Suche kennt nur **Geometrie** (Form der Route). Tempo kommt erst ab Stufe 3 ins Spiel – das ist die Arbeitsteilung, die aus Kapitel 08 folgt (die Geschwindigkeit kürzt sich in $d\\theta/ds$ weg).
%%
%[text] ## 2  Schritt 1 – Eine Runde ist keine einzelne Suche
%[text] **Frage:** Warum nicht eine Suche von Start nach Start? **Antwort:** Start und Ziel sind dieselbe Pose, A\* hört auf, sobald das Ziel erreicht ist – es gibt eine Route der Länge **0** (nur der Startknoten), das Auto bleibt stehen. Eine Runde muss daher als **Kette von Suchen durch Zwischenziele (Checkpoints)** formuliert werden. Die Checkpoints legen auch die Fahrtrichtung fest (Reihenfolge umdrehen ⇒ andere Richtung). Jedes Leg startet in der Pose, in der das vorige endete.
if exist('setup_path', 'file') ~= 2, cd('..'), end
setup_path
P  = cc_params('Track', 'oval');
T  = cc_track(P);
CM = cc_car_model(T, P);
[poses, info] = cc_lap_plan(CM);          % druckt die Leg-Tabelle
%[text] **Erwartete Ausgabe (identisch im Guide und in der Nachrechnung):**
%[text:table]
%[text] | Leg | Ziel | Posen | Kosten | Expansionen | Ankunftsrichtung |
%[text] | --- | --- | --- | --- | --- | --- |
%[text] | 1 | (2,90; 1,00) | 13 | 1,48 m | 36 | +56,0° |
%[text] | 2 | (1,60; 1,50) | 14 | 1,66 m | 25 | +179,5° |
%[text] | 3 | (0,30; 1,00) | 14 | 1,60 m | 65 | +235,5° |
%[text] | 4 | (1,60; 0,50) | 14 | 1,67 m | 59 | +348,0° |
%[text:table]
%[text] `LAP: 52 poses, 6.40 m, 185 expansions. Closes: yes` (Lücke 77 mm, 12°). Die Spalte „Ankunftsrichtung" ist bei der Aufgabe 4b wichtig.
%%
%[text] ## 3  Warum 6,40 m, wenn die Route nur 6,05 m lang ist?
%[text] `6,40 m` sind die **Suchkosten**, `6,05 m` die **gefahrene Strecke**. Der Unterschied sind die Lenkzuschläge: `cost = arc + wSteer·|Lenkstufe|` mit `wSteer = 0,02 m`. Volle Lenkung kostet 0,139 statt 0,119 m, halbe 0,129 m. Der Zuschlag ist ein **Tie-Breaker**: unter gleich langen Routen gewinnt die mit weniger Lenken (weniger Zickzack).
XY = cc_resample_path(poses(:,1:2), 0.04);              % Stufe 2
routeLen = sum(hypot(diff(XY(:,1)), diff(XY(:,2))));
fprintf('Suchkosten %.2f m   gefahrene Strecke %.2f m   Differenz %.2f m\n', info.cost, routeLen, info.cost - routeLen);
%[text] **Erwartete Ausgabe:** `Suchkosten 6.40 m   gefahrene Strecke 6.05 m   Differenz 0.35 m` (51 Züge × 0,119 m = 6,07 m ≈ 6,05 m Sehnenlänge, dazu 0,33 m Lenkzuschläge = 6,40 m).
%%
%[text] ## 4  Schritt 2 – Fahren: das ganze Experiment
run('experiments/experiment_oval_lap.m')
%[text] **Erwartete Ausgabe:**
%[text:table]
%[text] | Größe | Guide | Repo |
%[text] | --- | --- | --- |
%[text] | Route | 6,05 m | 6,05 m |
%[text] | engste Kurve | R = 0,296 m bei (0,34; 0,99) | R = 0,104 m bei (0,56; 1,31) |
%[text] | langsamster Punkt | 1,52 m/s | 0,90 m/s |
%[text] | schnellster Punkt | 2,46 m/s (Topspeed 3,72) | 2,14 m/s |
%[text] | **RUNDENZEIT** | **4,40 s** | **5,48 s** |
%[text] | erreichte Höchstgeschwindigkeit | 1,69 m/s | 1,44 m/s |
%[text] | am Grip-Limit | 0 von 111 Schritten | 0 von 138 Schritten |
%[text] | Spurfehler | max 63 mm, Ø 21 mm | max 64 mm, Ø 21 mm |
%[text:table]
%[text] **Erklärung der zwei Geschwindigkeitsgrenzen (Guide-Zahlen):**
%[text] **1. Die Soll-Geschwindigkeit bleibt unter 2,46 m/s, obwohl das Auto 3,72 kann.** Verantwortlich ist diese Zeile in `cc_speed_profile`: `vRef(turning) = min(o.VMax, sqrt(o.AyMax ./ kappa(turning)));`. In der Kurve wirkt die Querbeschleunigung $v^2/R$, die Reifen halten `ayMax = 7,85 m/s²`, also $v \\le \\sqrt{a_{y,\\max}\\,R}$. Engster Radius 0,296 m ⇒ $\\sqrt{7{,}85 \\cdot 0{,}296} = 1{,}52$ m/s = der „langsamste Punkt". Der Rückwärtsdurchlauf (Bremsen) zieht auch die Geschwindigkeiten *vor* der Kurve herunter. Um die Grenze zu heben, bräuchte die Strecke eine lange Gerade und danach eine sanfte Kurve – auf einem 3,2 m langen Oval gibt es das nicht.
%[text] **2. Das Auto erreicht nur 1,69 m/s.** Das liegt am Regler: `throttle = kv * (vWant - v)` ist ein P-Regler; er braucht einen **Fehler**, um Gas zu geben, hinkt also einem steigenden Soll immer hinterher. Bei Soll, das alle halbe Sekunde steigt und fällt, holt er nie auf. `kv` ist einer der acht Werte aus Kapitel 10.
%%
%[text] ## 5  Der Regler im Detail: Pure Pursuit (zum Erklären)
%[text] Das Auto sucht auf der Route einen **Zielpunkt** im Abstand $L_d$ voraus und lenkt auf ihn zu:
%[text] $L_d = \\min(L_{d,\\max},\; L_{d0} + k_{Ld}\\cdot v)$  ·  $\\delta = \\arctan\\!\\left(\\dfrac{2L\\sin\\alpha}{L_d}\\right)$  ·  $\\mathrm{Gas} = k_v\\,(v_\\mathrm{Soll}-v)$
%[text] $\\alpha$ = Winkel zwischen Fahrtrichtung und Linie zum Zielpunkt. Kurzer Vorausschauabstand ⇒ genau, aber nervös; langer ⇒ ruhig, aber schneidet Kurven. Standardwerte: `Ld0 = 0,16`, `kLd = 0,08`, `LdMax = 0,35`, `kv = 90`; unterhalb von 27,75 % Gas bewegt sich der Motor gar nicht (Totzone).
%%
%[text] ## 6  Schritt 3 – Speed-Profil weglassen
%[text] Dieselbe Route, aber überall Vollgas:
vFlat = repmat(cc_top_speed(P), size(XY,1), 1);
log = cc_simulate(T, [XY, vFlat]);
fprintf('crashed: %d at (%.2f, %.2f) after %.2f s\n', log.crashed, log.crashAt(1), log.crashAt(2), log.t(end));
%[text] **Erwartete Ausgabe (Guide und Repo identisch):** `crashed: 1 at (2.64, 1.61) after 1.44 s`.
%[text] **Was die Suche garantiert hat – und was nicht:** Sie garantiert nur, dass eine **geometrische** Bahn existiert, die die Lenkung erzeugen kann und deren überstrichenes Rechteck die Wände frei lässt. Über Tempo sagt sie *nichts* – die Geschwindigkeit hat sich ja aus $d\\theta/ds$ gekürzt. Tempo hängt nur über den **Grip** ($a_y = v\\cdot\\dot\\theta \\le a_{y,\\max}$) ein, und Grip ist keine geometrische Eigenschaft. Eine Route ist eine **Form**, und erst das Geschwindigkeitsprofil macht daraus einen Plan.
%%
%[text] ## 7  Schritt 4 – Der Zielkonflikt: `P.safety` von 0 bis 0,12 m
%[text] `P.safety` ist der Abstand, den der Planer zwischen Auto-Rechteck und Wand hält. Zwei Zahlen bewerten das Ergebnis: **Rundenzeit** (klein) und **Clearance** (kleinster Abstand Auto ↔ echte Wand über die ganze Runde, groß). „Nicht gecrasht" ist keine Zahl.
%[text] **Vorhersage zuerst (auf Papier festhalten!):** Ich erwarte beim Erhöhen von 0,02 auf 0,12 m: Zeit ↑ (längerer Umweg), Clearance ↑.
for saf = [0.00 0.02 0.03 0.04 0.05 0.07 0.08 0.10 0.12]
    P  = cc_params('Track', 'oval', 'safety', saf);
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
        fprintf('safety %.2f : CRASH at (%.2f, %.2f)\n', saf, log.crashAt(1), log.crashAt(2));
    else
        fprintf('safety %.2f : %.2f s, clearance %4.1f mm, %3d expansions\n', ...
            saf, log.lapTime, 1000*cc_clearance(T, log), info.expansions);
    end
end
%[text] **Erwartete Ausgabe:**
%[text:table]
%[text] | `P.safety` | Guide: Zeit | Guide: Clearance | Repo: Zeit | Repo: Clearance | Expansionen |
%[text] | --- | --- | --- | --- | --- | --- |
%[text] | 0,00 | keine Route | | keine Route | | |
%[text] | 0,02 | 4,28 s | 25,7 mm | 5,36 s | 25,0 mm | 178 |
%[text] | 0,03 | 4,40 s | **11,3 mm** | 5,44 s | 14,9 mm | 167 |
%[text] | 0,04 | 4,40 s | 39,4 mm | 5,48 s | 41,6 mm | 194 |
%[text] | 0,05 | 4,40 s | 39,4 mm | 5,48 s | 41,6 mm | 185 |
%[text] | 0,07 | 4,52 s | 44,1 mm | 5,64 s | 45,7 mm | 143 |
%[text] | 0,08 | 4,40 s | 50,6 mm | 5,64 s | 52,8 mm | 161 |
%[text] | 0,10 | **4,32 s** | **65,2 mm** | 5,52 s | 68,5 mm | 160 |
%[text] | 0,12 | 4,36 s | 80,8 mm | 5,36 s | 84,2 mm | 131 |
%[text:table]
%[text] **Zwei Anomalien – und warum die Vorhersage „mehr Rand = langsamer und sicherer" falsch war:** Der Fehler im Denken ist, `P.safety` als Verschieben *einer festen* Route zu sehen. Es ändert aber, **welche Route die Suche überhaupt findet**.
%[text] - **0,10 schneller als 0,05:** Der zusätzliche Rand drückt die Route zur Mitte des Gangs. Die Mitte einer Kurve ist die Linie mit dem **größten Radius**, und größerer Radius ⇒ höheres Grip-Limit $v \\le \\sqrt{a_{y,\\max} R}$. Die Einschränkung hat Tempo „gekauft". Das ist kein Naturgesetz, sondern Eigenschaft eines Gangs, der breit genug ist.
%[text] - **0,03 schlechter als 0,02 (langsamer *und* näher):** Beide Werte sind unterhalb der Schwelle, ab der der Rand irgendwo bindet. Die Routen unterscheiden sich fast zufällig (Tie-Breaking in OPEN) – ohne Rand lenkt nichts die Suche auf eine vernünftige Linie. 11,3 mm ist Zufall.
%[text] **Merksatz:** *Unterhalb eines Werts schützt der Rand nicht, er ist nur Rauschen; oberhalb wählt der Rand deine Rennlinie.*
%%
%[text] ## 8  Schritt 4b – Warum scheitert `safety = 0`?
%[text] Ein Checkpoint legt einen **Ort** fest, keine Pose: Die Suche stoppt, sobald sie innerhalb von `P.cpTol` ist, egal in welche Richtung das Auto zeigt. Das nächste Leg muss genau mit dieser Richtung weiter. Wir drucken die Ankunftsrichtung an jedem Checkpoint:
for saf = [0.00 0.02 0.05]
    P = cc_params('Track','oval','safety',saf);
    CM = cc_car_model(cc_track(P), P);
    pose = P.start;
    fprintf('safety %.2f:', saf);
    goals = [P.checkpoints; P.start(1), P.start(2)];
    for k = 1:size(goals,1)
        lp = cc_search_car(CM, pose, goals(k,:), P.cpTol);
        if isempty(lp), fprintf('  leg %d FAILS\n', k); break, end
        pose = lp(end,:);
        fprintf('  CP%d at %+6.1f deg', k, mod(rad2deg(pose(3)),360));
    end
    fprintf('\n');
end
%[text] **Erwartete Ausgabe (Guide und Repo identisch):**
%[text] `safety 0.00:  CP1 at +56.0 deg  CP2 at +179.0 deg  CP3 at +212.0 deg  leg 4 FAILS`
%[text] `safety 0.02:  CP1 at +56.0 deg  CP2 at +179.0 deg  CP3 at +222.9 deg  CP4 at +357.4 deg`
%[text] `safety 0.05:  CP1 at +56.0 deg  CP2 at +179.5 deg  CP3 at +235.5 deg  CP4 at +348.0 deg`
%[text] **Erklärung:** Ohne Rand darf Leg 1–3 enger fahren und das Auto erreicht CP3 mit **212°** statt 222,9° oder 235,5°. Aus 212° gibt es mit fünf Vorwärts-Bögen und ohne Rückwärtsgang keine Folge, die im Gang zum Start zurückkommt. Der Planer irrt nicht – das Auto steckt wirklich fest. **Der Zustand, in dem man ankommt, ist Teil des Problems für das nächste Leg** – lokal optimal kann global unmöglich sein. (Lösung wäre: Legs gemeinsam suchen oder Ankunftsrichtung festlegen – zu teuer für dieses Labor.)
%%
%[text] ## 9  Wichtig fürs Gespräch: Abweichung Guide ↔ Repo (±1 gegen ±3)
%[text] Die Krümmung $\\kappa = 1/R$ wird in `cc_speed_profile` aus drei Punkten berechnet (Kreis durch A, B, C): `A = XY(k-1,:); B = XY(k,:); Cp = XY(k+1,:)`, also **Nachbarn ±1**, bei 4 cm Abstand = Basis von nur 8 cm. Die Route besteht aber aus Bögen von 11,9 cm, die an den Posen mit einem **Knick** zusammenstoßen (Linearinterpolation). Wer die Krümmung über 8 cm misst, trifft manchmal einen Knick und liest R = 0,104 m – **enger als das Auto physikalisch fahren kann** (kleinster Radius $L/\\tan 22° \\approx 0{,}30$ m!). Das ist ein Messartefakt, kein echter Radius.
%[text] Alle Zahlen des Guides (z. B. R = 0,296 m ≈ Minimalradius) ergeben sich exakt, wenn man über **±3 Punkte** (Basis 24 cm ≈ 2 Bögen) misst. Das Repo-File misst über ±1. Konsequenz: **gleiche Route, gleiche Planung, aber ein zu vorsichtiges Geschwindigkeitsprofil** ⇒ Runden ca. 1 s (Oval) bzw. ca. 3 s (echte Strecke) langsamer als im Guide.
%[text] **Beim Gespräch:** Das Resultat dieser Aufgabe ist nicht „falsch", sondern ein schönes Beispiel dafür, dass *Krümmung aus diskreten Punkten* von der Messbasis abhängt. Prüfe es selbst im Folgenden:
P  = cc_params('Track','oval');  CM = cc_car_model(cc_track(P), P);
poses = cc_lap_plan(CM, 'Verbose', false);
XY = cc_resample_path(poses(:,1:2), 0.04);
[~, kap1] = cc_speed_profile(XY, P);                 % Repo: Nachbarn +-1
kap3 = local_kappa(XY, 3);                           % Guide: Nachbarn +-3
fprintf('kleinster Radius:  +-1 -> %.3f m    +-3 -> %.3f m    (physikalisches Minimum %.3f m)\n', ...
    1/max(kap1), 1/max(kap3), P.L/tand(P.deltaMax));
%[text] **Erwartete Ausgabe:** `kleinster Radius:  +-1 -> 0.104 m    +-3 -> 0.296 m    (physikalisches Minimum 0.297 m)`
%%
%[text] ## 10  Schritt 4c – `P.safety` wählen (3 Sätze)
%[text] **Muster-Antwort (anpassen!):** *Ich nehme 0,05 m auf dem Oval: Ab dort ist die Clearance stabil bei ca. 39–42 mm und die Zeit flach, darunter ist der Rand nur Rauschen (0,03 → 11–15 mm). Ich gebe etwas Zeit gegenüber 0,10 m ab, weil dessen Vorteil (schneller, 65 mm) auf einem Zufall der Geometrie beruht, der auf anderen Strecken nicht übertragbar ist. Meine Meinung würde sich ändern, wenn Messungen am echten Auto zeigen, dass die Clearance dort deutlich kleiner ist als in der Simulation.*
%%
%[text] ## 11  Checkpoint
%[text] - Runde schließt: `Closes: yes (77 mm, 12 deg)` ✔
%[text] - Die fünf Stufen erklären: Plan → Resample → Geschwindigkeitsprofil → Regler → Simulator.
%[text] - Zwei Geschwindigkeitsgrenzen unterscheiden: **Grip** (Profil) und **Regler** (P-Regler hinkt).
%[text] - Warum eine Route nur eine Form ist, und warum Checkpoints Orte sind, keine Posen.
%%
%[text] ### Hilfsfunktion (Live-Script-Funktionen stehen am Dateiende)
function kappa = local_kappa(XY, m)
% Krümmung 1/R aus dem Kreis durch drei Punkte A=XY(k-m), B=XY(k), C=XY(k+m).
% m = 1 entspricht cc_speed_profile im Repo, m = 3 der Messbasis, mit der die
% Zahlen im Guide reproduzierbar sind.
n = size(XY,1);
kappa = zeros(n,1);
for k = 1+m : n-m
    A = XY(k-m,:);  B = XY(k,:);  C = XY(k+m,:);
    a = hypot(B(1)-A(1), B(2)-A(2));
    b = hypot(C(1)-B(1), C(2)-B(2));
    c = hypot(C(1)-A(1), C(2)-A(2));
    area2 = abs((B(1)-A(1))*(C(2)-A(2)) - (B(2)-A(2))*(C(1)-A(1)));
    if a*b*c > eps && area2 > eps
        kappa(k) = 2*area2/(a*b*c);          % = 1/R
    end
end
kappa(1:m)       = kappa(m+1);               % Ränder auffüllen
kappa(end-m+1:end) = kappa(end-m);
end
