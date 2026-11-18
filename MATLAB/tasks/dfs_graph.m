function [path, cost, stats] = dfs_graph(W, s, t)
%DFS_GRAPH  TASK 1 -- depth-first search.
%
%   The skeleton below is complete and runs. Three places are missing,
%   all marked TODO. Do them in order and RUN IT after each one.
%
%   How to run it:
%       G = graph_example();
%       [p, c, st] = dfs_graph(G.W, G.s, G.t)
%
%   Target:  A - D - F, cost 7, 3 expansions.
%
%   Check:   check_my_code('dfs')
%
%   See also OPEN_NEW, GRAPH_NEIGHBORS, RECONSTRUCT_PATH.

%
% =====================================================================
%  ERKLAERUNG (Deutsch) -- Tiefensuche (DFS)
% ---------------------------------------------------------------------
%  Idee: Mache immer mit dem ZULETZT entdeckten Knoten weiter. Die Suche
%  "taucht" so tief wie moeglich in einen Ast hinein, bevor sie zurueck-
%  geht. Dafuer braucht OPEN das Verhalten eines Stapels (LIFO).
%  Kantenkosten spielen bei der Auswahl KEINE Rolle -> nicht optimal.
%  Kursgraph: A -> D -> F (Kosten 7), obwohl A-B-E-F nur 3 kostet.
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
% TODO 2: 'lifo' = last in, first out = Stapel -> Tiefensuche.
% (Im Skelett stand absichtlich 'fifo' -- das waere Breitensuche.)
OPEN = open_new('lifo');

% Start als "gesehen" markieren und in OPEN legen.
% WICHTIG: open_push GIBT OPEN ZURUECK -> immer "OPEN = ..." schreiben,
% sonst ist die Aenderung weg (MATLAB uebergibt Structs als Kopie).
seen(s) = true;
OPEN    = open_push(OPEN, s);   % ohne Key: LIFO sortiert nach Reihenfolge

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
        OPEN    = open_push(OPEN, v);   % v auf die Warteliste legen (OPEN = !)
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
