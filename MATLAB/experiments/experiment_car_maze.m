%% EXPERIMENT_CAR_MAZE — my planner sends a car through a maze
% Before running:
% 1. Finish car_in_maze.m in tasks/.
% 2. Run check_my_code('astar') and check_car_maze.
% 3. Explain why a grid path is not automatically drivable by a real car.

% ---- ERKLAERUNG (Deutsch) ----------------------------------------------
% Zuerst testen:  check_my_code('astar')  und  check_car_maze
% Dann dieses Skript ausfuehren.
%
% Hinderniskarte 18x25, 20 % Hindernisse, Seed 7 (immer dieselbe Karte)
[M, s, t] = maze_obstacles(18, 25, 0.20, 7);
method = 'astar';          % zum Vergleich: 'bfs' oder 'dijkstra' einsetzen
showAnimation = true;      % false = nur rechnen, kein Fenster
% car_in_maze: 1. planen mit DEINEM Algorithmus, 2. leeren Weg abfangen,
%              3. Auto entlang des Weges animieren
[path, cost, stats] = car_in_maze(M, s, t, method, showAnimation);

fprintf('Algorithm: %s | steps: %d | cost: %.3f | expansions: %d\n', ...
    method, numel(path)-1, cost, stats.expansions);

% OPTIONAL: Switch to 'bfs' or 'dijkstra'; compare routes and expansions.
% OPTIONAL: Change the map seed. Predict what changes before executing.
% The animation has NO physical steering, acceleration, or footprint model.
%
% ---- ANTWORTEN (Deutsch) -----------------------------------------------
% A* vs. BFS auf diesem 4er-Grid (alle Zuege kosten 1): beide finden einen
% Weg mit MINIMALEN Kosten. A* expandiert meist weniger Zellen, weil
% f = g + h die Suche Richtung Ziel lenkt; BFS waechst Schicht fuer
% Schicht gleichmaessig in alle Richtungen.
% Warum kann ein echtes CrazyCar den Weg trotzdem nicht einfach abfahren?
% Der Weg besteht aus 90-Grad-Knicks zwischen Zellmitten. Ein Auto hat
% einen Mindest-Wenderadius, eine Ausdehnung (Footprint) und begrenzte
% Beschleunigung -- nichts davon kennt die Gitter-Suche. Die Animation
% dreht das Rechteck nur in Fahrtrichtung (-> Kapitel 09).
