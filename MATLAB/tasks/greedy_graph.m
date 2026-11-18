function [path, cost, stats] = greedy_graph(W, s, t, h)
%GREEDY_GRAPH  TASK 3 -- greedy best-first search.
%
%   Same pattern again. This time the order is decided by a number: the
%   estimate h(v) of how far it still is from v to the goal.
%
%   Copy your bfs_graph and change two things:
%     - the container has to sort by a key
%     - the key has to be handed over when pushing:
%           open_push(OPEN, v, <key>)
%
%   Nothing else. No g, no relaxation -- greedy only ever looks ahead.
%
%   h is a vector with one estimate per node, h(t) = 0.
%
%   Target:  A - D - F, cost 7, 3 expansions.
%
%   Check:   check_my_code('greedy')
%
%   Worth thinking about: greedy needs the same number of expansions as
%   depth-first search and finds the same path. Is that a coincidence?

%
% =====================================================================
%  ERKLAERUNG (Deutsch) -- Greedy Best-First
% ---------------------------------------------------------------------
%  Idee: Mache immer mit dem Knoten weiter, der dem Ziel am NAECHSTEN
%  zu sein SCHEINT, also mit dem kleinsten Schaetzwert h(v).
%  Dafuer braucht OPEN eine Prioritaetswarteschlange ('minkey'): sie gibt
%  immer den Eintrag mit dem kleinsten Key heraus.
%
%  Gegenueber bfs_graph sind genau ZWEI Dinge anders:
%    1. open_new('minkey') statt 'fifo'
%    2. bei JEDEM open_push wird der Key h(...) mitgegeben (Start + Nachbar)
%  KEIN g, KEINE Relaxation: Greedy weiss nicht, was der Weg bisher
%  gekostet hat -> nicht optimal.
%  Kursgraph: von A aus h(B)=2, h(C)=3, h(D)=1 -> nimmt D -> A-D-F, Kosten 7.
%
%  Eingaben:  W  Kostenmatrix, W(u,v) > 0 = Kante u->v mit diesen Kosten,
%                0 = keine Kante
%             s  Startknoten (Nummer), t  Zielknoten (Nummer)
%             h  Vektor mit einer Schaetzung pro Knoten: geschaetzte
%                Restkosten bis zum Ziel, h(t) = 0
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
% Aenderung 1: 'minkey' = Prioritaetswarteschlange (kleinster Key zuerst)
OPEN = open_new('minkey');

% Start als "gesehen" markieren und in OPEN legen.
% WICHTIG: open_push GIBT OPEN ZURUECK -> immer "OPEN = ..." schreiben,
% sonst ist die Aenderung weg (MATLAB uebergibt Structs als Kopie).
seen(s) = true;
OPEN    = open_push(OPEN, s, h(s));   % Aenderung 2: Key = h(s)

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
        OPEN    = open_push(OPEN, v, h(v));   % Aenderung 2: Key = NUR die Schaetzung h(v)
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
