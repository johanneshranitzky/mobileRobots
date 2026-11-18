%[text] # Kapitel 08 – Das Fahrzeug in der Nachbarsuche
%[text] **Dateien:** `tasks/car_primitives.m` und `tasks/car_neighbors.m`  ·  **Prüfung:** `checks/check_car_primitives.m`, `checks/check_car_neighbors.m`  ·  **Experiment:** `experiments/experiment_cc_point_vs_model.m`
%[text] **Bevor du startest:** Current Folder auf `MATLAB/` setzen, dann Abschnitt für Abschnitt mit *Run Section* ausführen. Alle Zahlen unter "Erwartete Ausgabe" stammen aus einer Nachrechnung des Labors, die alle Tabellen des Guides reproduziert – vergleiche sie mit deiner MATLAB-Ausgabe.
%%
%[text] ## 1  Die Grundidee in einem Satz
%[text] Bisher war ein **Knoten** eine Zelle $(r, c)$ und ein **Zug** ein Schritt zum Nachbarfeld. Jetzt ist ein Knoten eine **Pose** $(x, y, \\theta)$ und ein Zug ein **Bogen** (Bewegungsprimitiv), den das Auto wirklich fahren kann.
%[text] Drei Dinge muss `car_neighbors` können, die `graph_neighbors` nicht musste:
%[text] 1. den Bogen aus dem **Fahrzeug-Koordinatensystem** ins **Karten-Koordinatensystem** drehen (Rotation mit $\\theta$),
%[text] 2. den **ganzen Körper** (22 × 10,5 cm Rechteck) entlang des Bogens gegen die Wand prüfen – nicht nur den Endpunkt,
%[text] 3. die neue Pose auf einen **Knoten-Index** abbilden (`cc_pose_index`: x, y auf 10 cm gerundet, $\\theta$ auf 22,5°).
%%
%[text] ## 2  Parameter ansehen
%[text] `cc_params` enthält alle Fahrzeugdaten. Wichtig: **Geometrie** (`L`, `lr`, `deltaMax`, `bodyL`, `bodyW`) entscheidet, *welche Route existiert*. **Grip** (`ayMax`) und **Totzone** entscheiden nur, *wie schnell man sie fährt* – das ist Kapitel 09.
if exist('setup_path', 'file') ~= 2, cd('..'), end   % falls MATLAB in livescripts/ gewechselt hat
setup_path
P = cc_params();                                      % echte Strecke ("CrazyCar")
fprintf('L = %.2f m   lr = %.2f m   deltaMax = %d deg\n', P.L, P.lr, P.deltaMax);
fprintf('Körper %.3f x %.3f m   ayMax = %.2f m/s^2\n', P.bodyL, P.bodyW, P.ayMax);
fprintf('Lenkstufen: %s    nTheta = %d    arc = %.3f m\n', mat2str(P.steerLevels), P.nTheta, P.arc);
%[text] **Erwartete Ausgabe:** `L = 0.12 m   lr = 0.06 m   deltaMax = 22 deg` · `Körper 0.220 x 0.105 m   ayMax = 7.85 m/s^2` · Lenkstufen `[-1 -0.5 0 0.5 1]`, `nTheta = 16`, `arc = 0.119 m`.
%%
%[text] ## 3  Warum ein Punkt-Planer scheitert (Rechnung)
%[text] Der Körper ragt in Richtung Wand bis $d(\\psi) = \\tfrac{\\mathrm{bodyL}}{2}\\sin\\psi + \\tfrac{\\mathrm{bodyW}}{2}\\cos\\psi$. Die Wände sind aber nur um **7,25 cm** aufgeblasen (`P.inflate` = halbe Breite + 2 cm) – das passt nur bei $\\psi = 0$.
psi = deg2rad([0 15 30 64.5]);
d   = P.bodyL/2*sin(psi) + P.bodyW/2*cos(psi);        % so weit ragt der Körper zur Wand
for k = 1:numel(psi)
    if d(k) <= P.inflate, urteil = 'passt'; else, urteil = 'PASST NICHT'; end
    fprintf('psi = %4.1f deg:  d = %5.2f cm   (aufgeblasen: %.2f cm)   %s\n', ...
        rad2deg(psi(k)), 100*d(k), 100*P.inflate, urteil);
end
%[text] **Erwartete Ausgabe:** 5,25 cm (passt) · 7,92 cm (passt nicht) · 10,05 cm (passt nicht) · Maximum 12,2 cm bei 64,5°. Eine feste Aufblähung kann nur für **einen** Winkel stimmen – bei einem Rechteck, das doppelt so lang wie breit ist, nie für alle. Größer aufblasen (12,2 cm) schließt die engen Gänge (0,59 m) komplett.
%%
%[text] ## 4  Die Kette Lenkbefehl → Drehung (Formeln)
%[text] Fahrradmodell, Bezugspunkt = **Mitte des Körpers** (nicht die Hinterachse). Deshalb gibt es den Schwimmwinkel $\\beta$:
%[text] $\\beta = \\arctan\\!\\left(\\tfrac{l_r}{L}\\tan\\delta\\right)$  ·  $\\dfrac{d\\theta}{ds} = \\dfrac{\\cos\\beta\\,\\tan\\delta}{L}$
%[text] **Die Geschwindigkeit kürzt sich weg** – die Form eines Bogens hängt nicht davon ab, wie schnell man fährt. Darum kann die Suche in Metern rechnen und Tempo Kapitel 09 überlassen.
for pct = [10 25 50 75 100]
    delta = pct/100 * P.deltaMax;                    % Grad
    d     = deg2rad(delta);
    beta  = atan(P.lr/P.L * tan(d));                 % Schwimmwinkel
    dthds = cos(beta) * tan(d) / P.L;                % Drehung pro Meter [rad/m]
    fprintf('%3d %%: delta=%5.2f  beta=%5.2f  dth/ds=%5.3f rad/m  R=%6.3f m  Drehung pro Bogen=%5.2f deg\n', ...
        pct, delta, rad2deg(beta), dthds, 1/dthds, rad2deg(dthds*P.arc));
end
%[text] **Erwartete Ausgabe (identisch zur Tabelle 3d im Guide):** 10 % → 0,320 rad/m, R 3,124 m, 2,18° · 25 % → 0,801 / 1,248 m / 5,46° · 50 % → 1,612 / 0,620 m / 10,99° · 75 % → 2,442 / 0,410 m / 16,65° · 100 % → 3,300 rad/m, **R = 0,303 m**, 22,50°.
%[text] **Zur Erklärung beim Gespräch:** Fast linear (10 % → 10,3-fache Krümmung), weil $\\tan\\delta$ etwas schneller wächst als $\\delta$, aber $\\cos\\beta$ etwas schrumpft – beides hebt sich fast auf (3 % Fehler).
%%
%[text] ## 5  Warum `arc = 0.119` m?
%[text] Ein Zug muss **genau** auf einer gespeicherten Richtung landen. Es gibt `nTheta = 16` Richtungen, also ist ein Richtungsschritt $2\\pi/16 = 0{,}3927$ rad. Bei Volllenkung dreht das Auto 3,30 rad/m ⇒ die Strecke, die genau einen Richtungsschritt dreht, ist
%[text] $s = \\dfrac{2\\pi/16}{3{,}3002} = 0{,}119\\ \\mathrm{m}$
%[text] Mit 0,15 m wäre die Drehung 0,495 rad = 1,26 Richtungsschritte – die Suche müsste runden, gespeicherte und echte Pose würden auseinanderlaufen, und die Route wäre „gültig" aber nicht fahrbar.
arcExakt = (2*pi/P.nTheta) / (cos(atan(P.lr/P.L*tan(deg2rad(P.deltaMax)))) * tan(deg2rad(P.deltaMax)) / P.L);
fprintf('arc exakt = %.4f m   (P.arc = %.4f m)\n', arcExakt, P.arc);
%[text] **Erwartete Ausgabe:** `arc exakt = 0.1190 m   (P.arc = 0.1190 m)`
%%
%[text] ## 6  `car_primitives` – der Bogen in 4 Teilschritten (gelöst im Repo)
%[text] Der Code in `tasks/car_primitives.m` – hier mit Erklärung nachvollzogen. Für jede der 5 Lenkstufen:
%[text] - **TODO 1:** `beta = atan((P.lr / P.L) * tan(d));`  (Schwimmwinkel)
%[text] - **TODO 2:** `dthdS = cos(beta) * tan(d) / P.L;`  (Drehung pro Meter)
%[text] - **TODO 3:** Bogen in `nSub = 4` Schritte der Länge `ds = P.arc/4` zerlegen. In jedem Schritt: Richtung in der **Mitte** des Schritts `thMid = th + dthdS*ds/2` nehmen (Mittelpunktsverfahren, genauer als Anfang oder Ende), dann `x += ds*cos(thMid + beta)`, `y += ds*sin(thMid + beta)`. Die Fahrtrichtung ist $\\theta + \\beta$, **nicht** $\\theta$. Danach `th += dthds*ds`.
%[text] Gespeichert wird pro Primitiv: Endpunkt `dx, dy, dth`, die 4 Zwischenposen `pts` (damit `car_neighbors` den ganzen Körper prüfen kann), Länge und Kosten `cost = P.arc + P.wSteer*|Stufe|`.
prim = car_primitives(P);
fprintf('%6s %9s %9s %8s %7s\n', 'delta', 'dx', 'dy', 'dth[deg]', 'cost');
for k = 1:numel(prim)
    fprintf('%6.1f %9.5f %9.5f %8.3f %7.3f\n', prim(k).delta, prim(k).dx, prim(k).dy, rad2deg(prim(k).dth), prim(k).cost);
end
%[text] **Erwartete Ausgabe:** −22° → dx 0,10914, dy −0,04559, dth −22,502°, cost 0,139 · −11° → 0,11663 / −0,02277 / −10,993° / 0,129 · 0° → 0,11900 / 0 / 0 / 0,119 · +11° und +22° spiegelbildlich. Beachte **Symmetrie**: dy und dth wechseln nur das Vorzeichen.
%[text] **Kosten:** Volle Lenkung kostet 0,139 m statt 0,119 m (Aufschlag $w_\\mathrm{Steer} = 0{,}02$ m). Das ist ein Tie-Breaker: bei gleich langen Routen gewinnt die, die weniger lenkt. Genau deshalb sind in Kapitel 09 die Suchkosten (6,40 m) größer als die gefahrene Strecke (6,05 m).
%%
%[text] ## 7  Gegenprobe: Stimmen die Bögen mit dem Simulator überein?
%[text] `check_car_primitives` fährt jedes Primitiv im echten Simulator (`cc_step`) ab und vergleicht den Endpunkt mit dem berechneten. Das beweist, dass die Formeln das *simulierte* Auto beschreiben.
check_car_primitives
%[text] **Erwartete Ausgabe:** alles grün (alle fünf Primitive bestehen). In der Nachrechnung weicht der im Simulator gemessene Endpunkt höchstens 0,13 mm (bei ±22°), 0,06 mm (bei ±11°) und 0 mm (bei 0°) von der Formel ab – winzig gegen die 10-cm-Zellen, aber nicht null, weil der Simulator diskrete Schritte macht.
%%
%[text] ## 8  `car_neighbors` – Zeile für Zeile (gelöst im Repo)
%[text] Für eine Pose `(x, y, th)` und jedes der 5 Primitive:
%[text] **(1) Drehen, dann verschieben** (Reihenfolge wichtig!). Ein Punkt `(px', py')` im Fahrzeugsystem liegt in der Karte bei
%[text] `px = x + px'*ct - py'*sn`  ·  `py = y + px'*sn + py'*ct`   mit `ct = cos(th)`, `sn = sin(th)`
%[text] Das gilt für **beide** Koordinaten – wird `dy` nicht gedreht, fällt der Fehler bei `th = 0` nicht auf (`sn = 0`) und taucht erst in Kurven auf.
%[text] **(2) Ganzen Körper prüfen:** Schleife über alle 4 Zwischenposen `pr.pts(q,:)`; `cc_pose_free(CM, px, py, th + pr.pts(q,3))` prüft das gedrehte Rechteck auf der feinen 1-cm-Karte (`Msafe`, inkl. `P.safety`). Reicht eine Zwischenpose nicht → Primitiv verworfen (`break`).
%[text] **(3) Neue Pose + Index:** `nx = x + dx*ct - dy*sn`, `ny = y + dx*sn + dy*ct`, `nth = th + dth`, `idx = cc_pose_index([nx ny nth], CM)`; Kosten `w = pr.cost`.
%[text] Rückgabe: `nb` (Indizes), `w` (Kosten), `poses` (Posen) – nur die erlaubten Züge, **leere** Liste wenn keiner passt.
P  = cc_params('Track', 'oval');
T  = cc_track(P);
CM = cc_car_model(T, P);                              % ruft DEINE car_primitives auf
pose = [2.90 1.00 pi/2];                              % rechte Kurve, Auto zeigt nach oben
[nb, w, poses] = car_neighbors(CM, pose);
disp(round([poses(:,1:2), rad2deg(poses(:,3)), w(:)], 5))
%[text] **Erwartete Ausgabe (5 Nachbarn):** (2,94559 | 1,10914 | 67,5° | 0,139), (2,92277 | 1,11663 | 79,01° | 0,129), (2,90000 | 1,11900 | 90° | 0,119), (2,87723 | 1,11663 | 100,99° | 0,129), (2,85441 | 1,10914 | 112,5° | 0,139). Das Auto zeigt nach oben (90°): geradeaus = +0,119 in y. Das ist die gedrehte Version von `(0,119 | 0)` – ein Beweis, dass die Rotation stimmt.
%[text] **Beachte:** `67,5° = 90° − 22,5°` – die neue Richtung liegt wieder auf dem 22,5°-Raster (nur dann ist `cc_pose_index` exakt).
%%
%[text] ## 9  Die acht Prüffälle
check_car_neighbors
%[text] **Erwartete Ausgabe:** `[1] 5 von 5` Gerade · `[2]` andere Richtung 5/5 · `[3]` rechte Kurve 5/5 · `[4]` linke Kurve 5/5 · `[5]` obere Gerade 5/5 · **`[6] 0 von 5`** Bogen streift die Innenwand · **`[7] 4 von 5`** nur einige frei · **`[8] 0 von 5`** quer im Gang, Auto passt nicht.
%[text] **Was die Fälle zeigen:** Fall 1 besteht auch mit falscher Rotation (th=0). Fall 6 fängt „nur Endpose prüfen" – würde man nur das Ende testen, wären **2 von 5** Züge fälschlich frei (Nachrechnung). Fall 7+8: Gleicher Ort, andere Richtung → andere Antwort – in einer Rastersuche unmöglich.
%%
%[text] ## 10  Das Experiment: Punkt gegen Modell
%[text] **Teil A** plant die Runde mit deinem Raster-A\* (Auto = Punkt, Wände um 7,25 cm aufgeblasen, `cc_shortcut_path` glättet), **Teil B** plant mit deinem Fahrzeugmodell.
run('experiments/experiment_cc_point_vs_model.m')
%[text] **Erwartete Ausgabe Teil A (Raster 5 cm, 8 Nachbarn):**
%[text:table]
%[text] | Leg | Zellen | Länge | Expansionen |
%[text] | --- | --- | --- | --- |
%[text] | 1 | 69 | 3,55 m | 457 |
%[text] | 2 | 45 | 2,44 m | 124 |
%[text] | 3 | 97 | 5,18 m | 1291 |
%[text] | 4 | 62 | 3,39 m | 727 |
%[text] | 5 | 22 | 1,12 m | 23 |
%[text] | 6 | 70 | 3,62 m | 226 |
%[text:table]
%[text] Route 18,12 m, 2848 Expansionen. **RESULT: CRASHED** bei etwa (5,83; 0,70) nach ca. 1,6–1,7 s und nur ca. 2,3 m Fahrstrecke. Das ist die rechte Umkehrkurve (Leg 1): Der Punkt-Planer fährt die Ecke eng an, der 22 cm lange Körper schwingt in die Wand.
%[text] **Teil B:** Fahrzeugplan = 19,23 m, 3657 Expansionen, Runde geschlossen. Die Punkt-Route ist **kürzer** (18,12 m gegen 19,23 m) und für einen Punkt kollisionsfrei – aber nicht fahrbar. Die Modell-Route ist länger, weil die Kurven weiter ausgefahren werden müssen: Die Einschränkung steckt **im Suchraum**, nicht in einer Reparatur danach.
%%
%[text] ## 11  Checkpoint – ohne Code erklären können
%[text] - **Knoten** = Pose (x, y, θ) auf Gitter 10 cm × 10 cm × 22,5° ⇒ 16 Richtungen.
%[text] - **Zug** = Bogen von 0,119 m bei einer von 5 Lenkstufen; dreht um 0 / ±11 / ±22,5° (± 0,5° Rundungsfehler gegen das Raster).
%[text] - **Nachbar erlaubt** ⇔ das **gedrehte Rechteck** liegt in allen 4 Zwischenposen frei.
%[text] - **Kosten** = Bogenlänge + 0,02·|Lenkstufe|.
%[text] - **Heuristik** weiterhin Luftlinie – zulässig, weil jede Route mindestens so lang wie die Luftlinie ist.
