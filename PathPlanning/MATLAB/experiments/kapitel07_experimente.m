%% KAPITEL07_EXPERIMENTE -- alle Experimente aus 07_comparison.md
% Mobile Robots / Path Planning
%
% Dieses Skript fasst die Experimente 1, 2, 4 und 5 aus Kapitel 07 in
% einer Datei zusammen. Experiment 3 (viele Zufallskarten) steht in
% experiment_random_comparison.m.
%
% BENUTZUNG: Abschnitt fuer Abschnitt ausfuehren (Cursor in einen
% %%-Abschnitt setzen, dann "Run Section" bzw. Strg/Cmd+Enter).
% Vorher einmal im Ordner MATLAB/:  setup_path
%
% Die Zahlen (Kosten, Expansionen, Zeit) kommen aus DEINEM Lauf. Die
% Kommentare erklaeren, was man erwarten sollte und warum.

%% Schritt 0 -- Laeuft wirklich MEIN Code? -------------------------------
% check_my_code       testet jeden Algorithmus einzeln (6 Testfaelle)
% check_student_grid  testet das Zusammenspiel Grid -> Graph -> deine Suche
% which ...           zeigt, WELCHE Datei MATLAB tatsaechlich aufruft
setup_path
check_my_code
check_student_grid
which dfs_graph            % muss auf .../MATLAB/tasks/dfs_graph.m zeigen
which search_student_grid  % muss auf .../MATLAB/tools/... zeigen

%% Experiment 1a -- Ein Grid wird zu einem Graphen ----------------------
% M: 0 = freie Zelle, 1 = Hindernis. Jede Zelle hat einen linearen Index
% (spaltenweise durchnummeriert, wie MATLAB Matrizen speichert).
M = [0 0 0 0;
     0 1 0 0;
     0 0 0 0];

% grid_to_graph baut die Kostenmatrix W (n x n, n = numel(M) = 12):
%   W(u,v) > 0  <=>  man darf von Zelle u nach Zelle v fahren, mit diesen Kosten
%   4er-Nachbarschaft: oben/unten/links/rechts, Kosten 1
%   8er-Nachbarschaft: zusaetzlich diagonal, Kosten sqrt(2)
%   false = keine Diagonale "um die Ecke" eines Hindernisses (CornerCut aus)
W4 = grid_to_graph(M, 4, false);
W8 = grid_to_graph(M, 8, false);

% nnz = number of nonzeros = Anzahl gerichteter Kanten.
% Erwartung: nnz(W8) >= nnz(W4), denn jede 4er-Kante ist auch eine 8er-Kante.
% Viel kleiner als numel(M)^2 = 144, weil jede Zelle hoechstens 8 Nachbarn
% hat -> W ist "sparse" (duenn besetzt).
fprintf('nnz(W4) = %d, nnz(W8) = %d, numel(M)^2 = %d\n', ...
    nnz(W4), nnz(W8), numel(M)^2);

% Gleiche Nachbarn ueber den Graphen und direkt ueber das Grid?
% sub2ind wandelt (Zeile 2, Spalte 3) in den linearen Index um.
u = sub2ind(size(M), 2, 3);
[ng, wg] = graph_neighbors(W4, u);   % Nachbarn laut Graph
[nm, wm] = grid_neighbors(M, u, 4);  % Nachbarn laut Grid
% Reihenfolge darf abweichen, die MENGEN muessen gleich sein:
disp('Graph-Nachbarn:'); disp(sort(ng(:)).');
disp('Grid-Nachbarn: '); disp(sort(nm(:)).');

%% Experiment 1b -- Mein A* auf einem Hindernisfeld ----------------------
% maze_obstacles(Zeilen, Spalten, Hindernisdichte, Seed)
% Gleicher Seed = immer dieselbe Karte -> reproduzierbar.
[M, s, t] = maze_obstacles(20, 30, 0.20, 7);
[p, c, st] = search_student_grid(M, s, t, 'astar');
figure
% Expanded (cyan) zeigt, WO die Suche gearbeitet hat; Path ist das Ergebnis.
plot_grid(M, 'Path', p, 'Expanded', st.order, ...
          'Start', s, 'Goal', t, 'Title', 'My A* on an obstacle field');

% BEWEIS, dass DEIN astar_graph laeuft (laut Anleitung, von Hand):
%   1. In tasks/astar_graph.m direkt unter der function-Zeile einfuegen:
%        error('student:test', 'Das ist MEIN A*');
%   2. Diesen Abschnitt erneut ausfuehren -> genau diese Fehlermeldung kommt.
%   3. Zeile wieder LOESCHEN und check_my_code('astar') laufen lassen.

%% Experiment 2 -- Eine Karte, fuenf Suchen -------------------------------
% Alles bleibt gleich (Karte, Start, Ziel, Nachbarschaft, Seed) -- nur der
% Algorithmus wechselt. Nur so ist der Vergleich fair.
[M, s, t] = maze_obstacles(30, 40, 0.25, 7);
methods = {'dfs', 'bfs', 'greedy', 'dijkstra', 'astar'};

figure('Position', [100 100 1500 430]);
fprintf('\n%-9s %8s %6s %10s %10s\n', 'Methode', 'Kosten', 'Steps', 'Expans.', 'Zeit[ms]');
for k = 1:numel(methods)
    method = methods{k};
    [p, c, st] = search_student_grid(M, s, t, method, 'Conn', 4);

    subplot(1, numel(methods), k)
    plot_grid(M, 'Expanded', st.order, 'Path', p, ...
        'Start', s, 'Goal', t, ...
        'Title', sprintf('%s: cost %.0f, %d expanded', ...
                         method, c, st.expansions));
    % Steps = Anzahl Kanten = numel(p)-1. Hier (alle Kanten kosten 1)
    % ist Steps == Kosten; bei Conn 8 waere das NICHT mehr so.
    fprintf('%-9s %8.3f %6d %10d %10.3f\n', ...
        method, c, numel(p)-1, st.expansions, 1000*st.searchTime);
end

% ANTWORTEN zu den Fragen aus Experiment 2:
% 1. Garantiert optimal (4er-Grid, Kosten 1): BFS, Dijkstra, A*
%    (BFS, weil hier "wenigste Schritte" = "billigster Weg").
%    DFS und Greedy koennen zufaellig optimal sein, haben aber keine Garantie.
% 2. Dijkstra und A* haben GLEICHE Kosten, expandieren aber meist
%    VERSCHIEDENE Knoten: Dijkstra waechst kreisfoermig um den Start,
%    A* laeuft dank h als schmaler "Schlauch" Richtung Ziel.
% 3. Die wenigsten Expansionen hat meist Greedy (oder DFS). Das beweist
%    nicht, dass es die beste Methode ist -- der Weg kann deutlich teurer
%    sein. Wegkosten, Rechenzeit und Speicher zaehlen ebenfalls.
% 4. Es gibt oft mehrere verschiedene Wege mit derselben Kostensumme
%    (z. B. erst rechts dann runter vs. erst runter dann rechts). Welcher
%    zurueckkommt, entscheiden Nachbarreihenfolge und Tie-Break in OPEN.

%% Experiment 4A -- Perfektes Labyrinth: nur EIN Weg ----------------------
% maze_random erzeugt ein "perfektes" Labyrinth: die Gaenge bilden einen
% Baum, zwischen zwei Zellen gibt es genau einen einfachen Weg.
M2 = maze_random(10, 15, 42);
s2 = sub2ind(size(M2), 2, 2);
t2 = sub2ind(size(M2), 20, 30);
fprintf('\nPerfektes Labyrinth:\n');
for k = 1:numel(methods)
    [p, c, st] = search_student_grid(M2, s2, t2, methods{k}, 'Conn', 4);
    fprintf('%-9s cost %6.1f, expanded %4d\n', methods{k}, c, st.expansions);
end
% ERWARTUNG: alle Kosten GLEICH (es gibt ja nur einen Weg). Unterschiedlich
% sein koennen nur Expansionen, Groesse von OPEN und Rechenzeit.

%% Experiment 4B -- 8er-Nachbarschaft: weniger Schritte != billiger -------
% Zurueck zur Hinderniskarte aus Experiment 2.
[M, s, t] = maze_obstacles(30, 40, 0.25, 7);
[pB, cB] = search_student_grid(M, s, t, 'bfs',      'Conn', 8);
[pD, cD] = search_student_grid(M, s, t, 'dijkstra', 'Conn', 8);
fprintf('\nBFS:      %d steps, cost %.3f\n', numel(pB)-1, cB);
fprintf('Dijkstra: %d steps, cost %.3f\n', numel(pD)-1, cD);
% ERWARTUNG: BFS hat weniger oder gleich viele Schritte, Dijkstra hat
% kleinere oder gleiche KOSTEN. Grund: gerade Zuege kosten 1, diagonale
% sqrt(2) ~ 1.414. BFS zaehlt nur Kanten, Dijkstra summiert Gewichte.
% Nur das Bewegungsmodell wurde geaendert, kein Hindernis verschoben.

%% Experiment 4C -- A* mit unpassender Heuristik --------------------------
% Bei 8er-Nachbarschaft ist 'octile' die passende (zulaessige) Heuristik.
% 'manhattan' kann ueberschaetzen: eine Diagonale kostet sqrt(2) ~ 1.414,
% Manhattan schaetzt aber 2 -> NICHT zulaessig -> keine Optimalitaets-
% garantie mehr.
[~, cO, stO] = search_student_grid(M, s, t, 'astar', ...
    'Conn', 8, 'Heuristic', 'octile');
[~, cM, stM] = search_student_grid(M, s, t, 'astar', ...
    'Conn', 8, 'Heuristic', 'manhattan');
[~, cRef]    = search_student_grid(M, s, t, 'dijkstra', 'Conn', 8);
fprintf('\nOctile:    cost %.3f, expansions %d\n', cO, stO.expansions);
fprintf('Manhattan: cost %.3f, expansions %d\n', cM, stM.expansions);
fprintf('Dijkstra (Referenz-Optimum): cost %.3f\n', cRef);
% ERWARTUNG: Octile = Dijkstra-Kosten. Manhattan expandiert oft weniger,
% KANN aber teurer sein. Wenn es auf dieser Karte trotzdem optimal ist:
% Eine verletzte Bedingung nimmt nur die GARANTIE weg -- sie heisst nicht,
% dass jedes Ergebnis falsch ist. Darum immer gegen Dijkstra vergleichen.

%% Experiment 5 -- Ingenieursentscheidung (nur Antworten, kein Code) ------
% 1. Ungewichtetes 4er-Grid, nur Schritte zaehlen        -> BFS
%    (optimal bei gleichen Kosten, einfach, keine Prioritaetswarteschlange)
% 2. Gewichtete Karte, Kosten >= 0, keine Heuristik      -> Dijkstra
%    (optimal; A* ohne Heuristik waere ohnehin Dijkstra)
% 3. Grosse Karte, gute konsistente Heuristik, schnell   -> A*
%    (optimal UND meist deutlich weniger Expansionen als Dijkstra)
% 4. Schnell irgendein Weg, Qualitaet egal               -> Greedy
%    (sehr wenige Expansionen, aber keine Optimalitaetsgarantie)
%
% Garantiert ein kuerzester Grid-Weg die schnellste Fahrt fuer ein Auto?
% NEIN. Die Suche minimiert die Summe der Kantenkosten (hier: Distanz).
% Ein echtes Auto hat Wenderadius, begrenzte Beschleunigung und muss vor
% engen Kurven bremsen. Ein etwas laengerer, glatterer Weg kann schneller
% sein. Fuer minimale ZEIT braucht man eine Zeit-Kostenfunktion und ein
% Fahrzeugmodell (-> Kapitel 09).
