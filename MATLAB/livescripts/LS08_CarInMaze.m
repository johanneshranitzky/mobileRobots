%[text] # Kapitel 08 – Auto im Labyrinth
%[text] **Datei:** `tasks/car_in_maze.m`  ·  **Idee:** deinen eigenen Planer mit einer Fahrzeug-Animation verbinden
%[text] **Bevor du startest:** Current Folder auf `MATLAB/` setzen, dann Abschnitt für Abschnitt mit *Run Section* ausführen.
%%
%[text] ## 1  Idee: Planen und Ausführen sind getrennt
%[text] - **Planen** – einen Weg im Grid finden, mit deinem Algorithmus aus `tasks/`
%[text] - **Ausführen** – ein Auto-Symbol fährt den Weg ab, das ist nur eine Animation \\
%[text] Die drei gelösten TODOs in `car_in_maze.m`:
%[text:table]
%[text] | TODO | Code | Bedeutung |
%[text] | --- | --- | --- |
%[text] | 1 | `[path, cost, stats] = search_student_grid(M, s, t, method);` | Weg mit **deinem** Algorithmus planen |
%[text] | 2 | `if isempty(path), return, end` | kein Weg → nichts animieren |
%[text] | 3 | `if showAnimation, animate_car_grid(M, path); end` | Auto nur zeigen, wenn gewünscht |
%[text:table]
%%
%[text] ## 2  Vom Grid zum Graphen
%[text] Das Grid $M$ hat $R$ Zeilen und $C$ Spalten, $M(r,c) = 0$ heißt frei. Jede Zelle bekommt einen **linearen Index** (spaltenweise gezählt):
%[text] $i = r + (c - 1) \\cdot R$
%[text] `grid_to_graph` macht jede freie Zelle zu einem Knoten. Bei 4er-Nachbarschaft kostet jeder Schritt 1, bei 8er-Nachbarschaft kosten Diagonalen $\\sqrt{2}$.
%[text] Für `A*` und Greedy baut `search_student_grid` die **Manhattan-Heuristik** zum Ziel $(r_t, c_t)$:
%[text] $h(v) = |r_v - r_t| + |c_v - c_t|$
%[text] Sie ist bei 4er-Nachbarschaft zulässig, weil man mindestens so viele Schritte braucht.
if exist('setup_path', 'file') ~= 2, cd('..'), end   % falls MATLAB in livescripts/ gewechselt hat
setup_path
[M, s, t] = maze_obstacles(18, 25, 0.20, 7);
[rs, cs] = ind2sub(size(M), s)
[rt, ct] = ind2sub(size(M), t)
plot_grid(M, 'Start', s, 'Goal', t, 'Title', 'Hinderniskarte 18 x 25, Seed 7')
%%
%[text] ## 3  Planen mit deinem `A*`
%[text] `search_student_grid` ist nur ein Adapter: Grid → $W$, Heuristik $h$ bauen, dann **deine** Funktion `astar_graph(W, s, t, h)` aufrufen.
[p, c, st] = search_student_grid(M, s, t, 'astar');
kosten      = c
schritte    = numel(p) - 1
expansionen = st.expansions
plot_grid(M, 'Expanded', st.order, 'Path', p, 'Start', s, 'Goal', t, 'Title', sprintf('A*: Kosten %g, %d Expansionen', c, st.expansions))
%%
%[text] ## 4  Vergleich: BFS auf derselben Karte
%[text] Im 4er-Grid mit Kosten 1 sind beide optimal – gleiche Kosten, aber BFS wächst in alle Richtungen, `A*` läuft dank $h$ Richtung Ziel.
[pB, cB, stB] = search_student_grid(M, s, t, 'bfs');
gleiche_kosten = (cB == c)
expansionen_BFS = stB.expansions
plot_grid(M, 'Expanded', stB.order, 'Path', pB, 'Start', s, 'Goal', t, 'Title', sprintf('BFS: Kosten %g, %d Expansionen', cB, stB.expansions))
%%
%[text] ## 5  Deine Funktion `car_in_maze` testen
%[text] Mit `showAnimation = false` wird nur geplant – so prüft auch `check_car_maze`.
[pathCar, costCar, statsCar] = car_in_maze(M, s, t, 'astar', false);
gleich = isequal(pathCar, p) && costCar == c
check_car_maze
%%
%[text] ## 6  Animation
%[text] Jetzt fährt das Auto. `StepPause` ist nur die Anzeigepause, **keine** Geschwindigkeit – Weg und Kosten ändern sich dadurch nicht.
car_in_maze(M, s, t, 'astar', true);
%%
%[text] ## 7  Für die Prüfung
%[text] - **Warum** `search_student_grid` **und nicht** `search_grid`**?** `search_grid` ist eine fertige Referenzlösung. Nur `search_student_grid` ruft **deinen** Code auf.
%[text] - **Warum zuerst** `isempty(path)` **prüfen?** Das Ziel kann unerreichbar sein. Mit leerem Weg gibt es nichts zu animieren.
%[text] - **Kann ein echtes Auto den Weg fahren?** Nein. Der Weg hat 90°-Knicks zwischen Zellmitten. Wenderadius, Fahrzeuggröße und Beschleunigung werden nicht berücksichtigt (→ Kapitel 09). \\
%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
