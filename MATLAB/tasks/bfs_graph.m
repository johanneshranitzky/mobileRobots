function [path, cost, stats] = bfs_graph(W, s, t)
%BFS_GRAPH  TASK 2 -- breadth-first search.
%
%   Copy your finished dfs_graph in here, rename the function in the
%   first line, and change EXACTLY ONE WORD.
%
%   If you change more than one word you have misunderstood the task --
%   and that one word is the central claim of the whole lecture.
%
%   Target:  A - D - F, 2 steps, cost 7, 6 expansions.
%
%   Check:   check_my_code('bfs')
%
%   Watch the result: breadth-first search finds the path with the
%   FEWEST STEPS. That does not make it the cheapest -- here it costs 7
%   while a route for 3 exists.

%
% =====================================================================
%  ERKLAERUNG (Deutsch) -- Breitensuche (BFS)
% ---------------------------------------------------------------------
%  Idee: Mache immer mit dem FRUEHESTEN entdeckten Knoten weiter. Die
%  Suche breitet sich in Schichten aus: erst alle Knoten 1 Schritt vom
%  Start, dann alle mit 2 Schritten usw. -> OPEN ist eine Warteschlange.
%
%  Der Code ist EXAKT dfs_graph -- nur EIN WORT ist anders: 'fifo'
%  statt 'lifo'. Kernaussage der Vorlesung: der Container bestimmt den
%  Algorithmus.
%
%  BFS findet den Weg mit den WENIGSTEN SCHRITTEN, nicht den billigsten.
%  Kursgraph: A -> D -> F (2 Schritte, Kosten 7), 6 Expansionen.
%
%  Eingaben:  W  Kostenmatrix, W(u,v) > 0 = Kante u->v mit diesen Kosten,
%                0 = keine Kante
%             s  Startknoten (Nummer), t  Zielknoten (Nummer)
%  Ausgaben:  path   Knotenfolge von s nach t ([] = kein Weg)
%             cost   echte Kosten dieses Weges (Summe der Kanten)
%             stats  .expansions = wie viele Knoten aus OPEN genommen
%                    .order      = in welcher Reihenfolge
% =====================================================================

% ---- Datenstrukturen anlegen (n = Anzahl Knoten) -------------------
n      = size(W, 1);
par    = zeros(n, 1);     % par(v) = Vorgaenger von v auf dem Weg (0 = keiner)
seen   = false(n, 1);     % schon EINMAL in OPEN gelegt? -> nie doppelt
closed = false(n, 1);     % schon expandiert (Nachbarn angeschaut)?
order  = zeros(1, 0);     % Expansionsreihenfolge, fuer stats und Plots

% ---- OPEN = die Warteliste der entdeckten, noch nicht expandierten Knoten
% DAS EINE GEAENDERTE WORT: 'fifo' = first in, first out = Warteschlange
OPEN = open_new('fifo');

% Start als "gesehen" markieren und in OPEN legen.
% WICHTIG: open_push GIBT OPEN ZURUECK -> immer "OPEN = ..." schreiben,
% sonst ist die Aenderung weg (MATLAB uebergibt Structs als Kopie).
seen(s) = true;
OPEN    = open_push(OPEN, s);   % ohne Key: FIFO sortiert nach Reihenfolge

% ---- Hauptschleife: solange noch Kandidaten warten ------------------
while ~open_isempty(OPEN)
    % 1. Den naechsten Knoten u herausnehmen. WELCHER das ist, entscheidet
    %    allein der Modus von OPEN -- das ist der ganze Unterschied
    %    zwischen DFS, BFS und Greedy.
    [OPEN, u] = open_pop(OPEN);

    % 2. Schon expandiert? Dann ueberspringen. (Wegen seen kommt das hier
    %    eigentlich nie vor, die Zeile steht nur da, damit das Muster
    %    gleich bleibt wie bei Dijkstra/A*, wo sie wirklich gebraucht wird.)
    if closed(u)
        continue
    end
    closed(u)      = true;      % u gilt jetzt als expandiert
    order(end + 1) = u;   %#ok<AGROW>  % fuer die Statistik mitschreiben
    trace_step(numel(order), u);       % optionale Ausgabe "step k: take X"

    % 3. ZIELTEST (TODO 3): fertig, sobald das Ziel AUS OPEN GENOMMEN wird
    %    (nicht schon beim Hineinlegen).
    if u == t
        break
    end

    % 4. Alle Nachbarn von u anschauen (aufsteigende Nummer = alphabetisch)
    nb = graph_neighbors(W, u);
    for k = 1:numel(nb)
        v = nb(k);
        % schon entdeckt oder schon fertig -> nichts zu tun
        if seen(v) || closed(v)
            continue
        end

        % TODO 1: neuen Nachbarn v merken
        par(v)  = u;   % "v wurde ueber u erreicht" -> daraus wird am Ende der Weg
        OPEN    = open_push(OPEN, v);   % hinten an die Warteschlange (OPEN = !)
        seen(v) = true; % nie wieder einfuegen (erster Fund zaehlt)
    end
end

% ---- Ergebnis --------------------------------------------------------
% Der Weg wird erst JETZT gebaut: von t rueckwaerts ueber par bis s,
% dann umgedreht. Die Kosten kommen aus den echten Kantengewichten W,
% auch wenn DFS/BFS/Greedy diese bei der Auswahl nie benutzt haben.
[path, cost]     = reconstruct_path(par, s, t, W);
stats.expansions = numel(order);
stats.order      = order;
end
