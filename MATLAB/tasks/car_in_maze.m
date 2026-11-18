function [path, cost, stats] = car_in_maze(M, s, t, method, showAnimation)
%CAR_IN_MAZE  Student task: use YOUR search to drive a displayed car in a grid.
%
%   [path,cost,stats] = car_in_maze(M,s,t,'astar',true)
%
%   TODO 1  Call search_student_grid(M,s,t,method). Explain why this is
%           YOUR algorithm, whereas search_grid is the reference solver.
%   TODO 2  Handle an empty path (goal unreachable) before animation.
%   TODO 3  If showAnimation is true, use animate_car_grid(M,path).
%
%   Visual playback is not a physically valid steering trajectory.
%   Refer to ANLEITUNGEN/08_car_in_maze.md for the guided exercise.
%
% =====================================================================
%  ERKLAERUNG (Deutsch)
% ---------------------------------------------------------------------
%  Diese Funktion verbindet zwei Dinge, die bewusst GETRENNT sind:
%
%    1. PLANEN      -> einen Weg im Grid finden   (deine Suchalgorithmen)
%    2. AUSFUEHREN  -> ein Auto den Weg abfahren lassen (nur Animation)
%
%  Eingaben:
%    M              Belegungsgitter: 0 = frei, alles andere = Hindernis
%    s, t           Start- und Zielzelle als LINEARER Index (sub2ind)
%    method         'dfs' | 'bfs' | 'greedy' | 'dijkstra' | 'astar'
%    showAnimation  true = Auto animieren, false = nur rechnen (fuer Tests)
%
%  Ausgaben:
%    path   Zellen des Weges von s nach t (linear), [] = kein Weg
%    cost   Summe der Kantenkosten des Weges, Inf = kein Weg
%    stats  Statistik DEINER Suche (expansions, order, searchTime, ...)
%
%  Wichtig fuer die Pruefung: Die Animation ist KEINE Fahrzeugsimulation.
%  Lenkwinkel, Wenderadius, Geschwindigkeit, Beschleunigung und die
%  Groesse des Autos werden nicht beruecksichtigt. Das Auto "springt"
%  einfach von Zellmitte zu Zellmitte und dreht sich in Fahrtrichtung.
% =====================================================================

% Standardwerte, falls Argumente fehlen (nargin = Anzahl uebergebener Argumente)
if nargin < 4 || isempty(method), method = 'astar'; end
if nargin < 5 || isempty(showAnimation), showAnimation = true; end

% ---------------------------------------------------------------------
% TODO 1 -- PLANEN mit DEINEM Algorithmus
% ---------------------------------------------------------------------
% search_student_grid ist nur ein "Adapter" (tools/search_student_grid.m):
%   - wandelt das Grid M in eine Kostenmatrix W um (grid_to_graph),
%     jede freie Zelle wird ein Knoten, Nachbarzellen werden Kanten
%   - baut die Heuristik h (bei 4er-Nachbarschaft: Manhattan-Distanz)
%   - ruft dann per switch DEINE Funktion auf, z. B. astar_graph(W,s,t,h)
% Darum ist das DEIN Algorithmus. search_grid dagegen waere eine fertige,
% unabhaengige Referenzloesung -- die wuerde deinen Code gar nicht testen.
[path, cost, stats] = search_student_grid(M, s, t, method);

% ---------------------------------------------------------------------
% TODO 2 -- SICHERHEIT: gibt es ueberhaupt einen Weg?
% ---------------------------------------------------------------------
% Wenn das Ziel nicht erreichbar ist, liefert reconstruct_path path = []
% und cost = Inf. Mit einem leeren Weg kann man nichts animieren, also
% hier abbrechen. Mit isempty pruefen -- ein leerer Weg ist NICHT dasselbe
% wie ein Weg der Laenge 0 (Start == Ziel ergibt path = s, also 1 Zelle).
if isempty(path)
    fprintf('No route found with %s -- nothing to animate.\n', method);
    return      % path, cost, stats werden trotzdem zurueckgegeben
end

% ---------------------------------------------------------------------
% TODO 3 -- AUSFUEHREN: Auto entlang des Weges zeigen
% ---------------------------------------------------------------------
% Nur wenn gewuenscht (check_car_maze ruft mit false auf, damit beim
% automatischen Test kein Fenster aufgeht). animate_car_grid zeichnet das
% Grid und bewegt ein Rechteck Zelle fuer Zelle entlang path.
% 'StepPause' (Standard 0.05 s) ist nur die Anzeigepause, KEINE
% Geschwindigkeit -- sie aendert weder Weg noch Kosten.
if showAnimation
    animate_car_grid(M, path);
end
end
