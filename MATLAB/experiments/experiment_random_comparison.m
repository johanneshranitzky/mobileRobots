%% EXPERIMENT_RANDOM_COMPARISON — guided experiment with YOUR planners
% Mobile Robots / Path Planning · CORE route
%
% BEFORE RUNNING:
%  1. Complete the five tasks/*_graph.m files and run check_my_code.
%  2. Predict: Which methods guarantee the minimum cost in a 4-neighbour
%     grid with all edges costing 1? Which might expand fewer nodes?
%  3. Run setup_path once from the project root.
%
% Run this file as a script. It uses search_student_grid, which calls
% your OWN search functions. No change to the provided tools is required.

% TASK A: Change ONLY seeds to 1:8 if you have extra time.
% TASK B: Change ONE density and predict whether results will change.
%
% ---- ERKLAERUNG (Deutsch) ----------------------------------------------
% Experiment 3 aus 07_comparison.md: EIN Zufallsergebnis ist kein Beweis.
% Darum: 2 Dichten x 8 Seeds = 16 Karten, auf jeder laufen alle 5 Methoden.
%   Zeilen in der Tabelle: 16 Karten x 5 Methoden = 80
%   Planer-Aufrufe gesamt: 80 + 16 Dijkstra-Referenzen = 96
% (Zum schnellen Testen seeds = 1:2 -> 4 Karten, 20 Zeilen, 24 Aufrufe.)
% Laut Anleitung ist 1:8 der eigentliche Versuch, darum hier 1:8.
densities = [0.15, 0.25];        % Anteil der Zellen, die Hindernisse sind
seeds = 1:8;                     % Seed = Zufallsstartwert -> reproduzierbare Karte
methods = {'dfs', 'bfs', 'greedy', 'dijkstra', 'astar'};

rows = cell(0, 7);
for density = densities
    for seed = seeds
        % Karte 30x40 erzeugen; der Generator stellt sicher, dass es einen
        % 4er-verbundenen Weg von s nach t gibt.
        [M, s, t] = maze_obstacles(30, 40, density, seed);
        % Dijkstra ist optimal -> liefert die Referenz-Kosten fuer DIESE Karte
        [~, referenceCost] = search_student_grid(M, s, t, 'dijkstra');

        for k = 1:numel(methods)
            % gleiche Karte, gleicher Start/Ziel -> fairer Vergleich
            [path, cost, stats] = search_student_grid(M, s, t, methods{k});
            % CostRatio = cost / Optimum: 1 = optimal, > 1 = teurerer Weg.
            % SearchMs = NUR die Suchzeit (ohne Graph-Aufbau), in ms.
            rows(end+1,:) = {density, seed, methods{k}, cost, ...
                             stats.expansions, 1000*stats.searchTime, ...
                             cost/referenceCost}; %#ok<AGROW>
        end
    end
end

% Zellarray -> Tabelle mit benannten Spalten
results = cell2table(rows, 'VariableNames', ...
    {'Density', 'Seed', 'Method', 'Cost', 'Expansions', 'SearchMs', 'CostRatio'});

disp('First rows of your measurement table:');
disp(results(1:min(height(results), 10),:));

fprintf('\n%-8s %-9s %10s %12s %12s\n', ...
        'Density','Algorithm','MeanRatio','MeanExpand','MedianMs');
% Zusammenfassung je Dichte und Methode:
%   MeanRatio  = mittlere Wegqualitaet (1.000 = immer optimal)
%   MeanExpand = mittlere Sucharbeit (maschinenunabhaengig)
%   MedianMs   = typische Suchzeit (Median ist robuster gegen Ausreisser)
for density = densities
    for k = 1:numel(methods)
        % logischer Index: alle Zeilen dieser Dichte UND dieser Methode
        idx = results.Density == density & strcmp(results.Method, methods{k});
        fprintf('%-8.2f %-9s %10.3f %12.1f %12.3f\n', ...
            density, methods{k}, mean(results.CostRatio(idx)), ...
            mean(results.Expansions(idx)), median(results.SearchMs(idx)));
    end
end

% THINK (write 1-2 sentences each, no long report):
%  1. Which methods had CostRatio = 1 for all these 4-neighbour maps?
%  2. Which methods had fewer expansions, and at what cost to path quality?
%  3. Do these 8 maps PROVE which algorithm is universally faster? Why not?
%
% ---- ANTWORTEN (Deutsch) -----------------------------------------------
%  1. CostRatio = 1 auf ALLEN Karten: BFS, Dijkstra, A*. Im 4er-Grid mit
%     Kosten 1 sind sie garantiert optimal (A* mit zulaessiger Manhattan-
%     Heuristik). DFS und Greedy haben meist Ratio > 1.
%  2. Weniger Expansionen: meist Greedy (und oft DFS), dafuer schlechtere
%     Wege. A* braucht typischerweise deutlich weniger als Dijkstra/BFS bei
%     gleicher (optimaler) Qualitaet. Mehr Hindernisse zwingen zu Umwegen,
%     die eine Luftlinien-Heuristik nicht vorhersieht -> A*-Vorteil kann
%     schrumpfen (datenabhaengig, nicht zwingend monoton).
%  3. NEIN, 16 Karten beweisen nichts Allgemeines. Das ist eine Stichprobe;
%     Zeiten schwanken je nach Rechner und Lauf. Fuer Laufzeitaussagen:
%     mehr Seeds, wiederholte Messungen, Verteilungen statt Einzelwerte,
%     und Vorbereitungszeit getrennt von der Suchzeit betrachten.
%     Weniger Expansionen heisst auch nicht automatisch weniger Zeit --
%     die Prioritaetswarteschlange (minkey) kostet selbst Zeit.
%
% OPTIONAL: test seeds = 1:8 and compare the summary. For runtime claims,
% repeat measurements and do not confuse graph-building preparation time
% with search time.
