function [path, cost, stats] = astar_graph(W, s, t, h)
%ASTAR_GRAPH  TASK 5 -- A*.
%
%   Copy your finished dijkstra_graph in here and change ONLY THE KEY.
%
%       Dijkstra   key = g(v)
%       A*         key = g(v) + h(v)
%
%   Careful: the key appears at TWO places -- once when the start is
%   pushed, once inside the loop. Both have to change.
%
%   Target:  A - B - E - F, cost 3, 4 expansions.
%            Same path as Dijkstra, one expansion less.
%
%   Check:   check_my_code('astar')

%
% =====================================================================
%  ERKLAERUNG (Deutsch) -- A*
% ---------------------------------------------------------------------
%  Idee: Wie Dijkstra, aber der Key ist f(v) = g(v) + h(v):
%    g(v) = was der Weg bis v WIRKLICH gekostet hat (wie Dijkstra)
%    h(v) = was es von v bis zum Ziel VERMUTLICH noch kostet (wie Greedy)
%  Damit beachtet A* die teure Kante A-D (anders als Greedy) UND sucht
%  zielgerichtet (anders als Dijkstra) -> meist weniger Expansionen.
%
%  Gegenueber dijkstra_graph ist NUR der Key anders -- an ZWEI Stellen:
%  beim Start und beim Push im Schleifenkoerper.
%
%  Optimal nur, wenn h ZULAESSIG ist (h ueberschaetzt nie die echten
%  Restkosten). Mit h = 0 ist A* exakt Dijkstra.
%  Kursgraph: A,B,E,F expandiert -> A-B-E-F, Kosten 3, 4 Expansionen
%  (C mit f = 1+3 = 4 wird nie angefasst).
%
%  Neu gegenueber DFS/BFS/Greedy:
%    g(v)        Kosten des BESTEN bisher bekannten Weges von s nach v
%    Relaxation  "Ist der Weg ueber u billiger als alles, was ich ueber v
%                weiss?" -> wenn ja: g(v), par(v) aktualisieren und v
%                (erneut) in OPEN legen.
%  Darum gibt es KEIN seen mehr: ein Knoten darf MEHRMALS in OPEN landen,
%  wenn spaeter ein billigerer Weg auftaucht. Der alte, teurere Eintrag
%  bleibt liegen und wird spaeter vom closed-Check weggeworfen.
%
%  Eingaben:  W  Kostenmatrix (W(u,v) > 0 = Kante mit diesen Kosten)
%             s  Start, t  Ziel
%             h  Schaetzung der Restkosten pro Knoten, h(t) = 0
%  Ausgaben:  path, cost, stats (.expansions, .order, .g)
% =====================================================================

% ---- Datenstrukturen -------------------------------------------------
n      = size(W, 1);
g      = inf(n, 1);       % noch kein Weg bekannt -> unendlich teuer
g(s)   = 0;               % zum Start kostet es nichts
par    = zeros(n, 1);     % Vorgaenger fuer die Wegrekonstruktion
closed = false(n, 1);     % endgueltig fertig (billigster Weg steht fest)
order  = zeros(1, 0);     % Expansionsreihenfolge

% Prioritaetswarteschlange: der Knoten mit dem kleinsten Key kommt zuerst.
% Bei gleichem Key entscheidet die Knotennummer (reproduzierbar).
OPEN = open_new('minkey');
OPEN = open_push(OPEN, s, g(s) + h(s));   % Key-Stelle 1: f = g + h

% ---- Hauptschleife ---------------------------------------------------
while ~open_isempty(OPEN)
    [OPEN, u] = open_pop(OPEN);    % Knoten mit kleinstem Key holen

    % Veralteter Eintrag? Ein Knoten kann mehrfach in OPEN liegen. Nur der
    % ERSTE, der herauskommt, ist der billigste -- alle spaeteren ignorieren.
    % Ab hier ist diese Zeile WIRKLICH noetig (bei DFS/BFS nicht).
    if closed(u)
        continue
    end
    closed(u)      = true;
    order(end + 1) = u;   %#ok<AGROW>
    trace_step(numel(order), u);

    % Zieltest beim HERAUSNEHMEN: erst jetzt ist sicher, dass g(t) minimal
    % ist (alle anderen Eintraege in OPEN haben einen Key >= diesem).
    if u == t
        break
    end

    % [nb, w]: Nachbarn UND die Kosten der Kanten dorthin (w(k) gehoert zu nb(k))
    [nb, w] = graph_neighbors(W, u);
    for k = 1:numel(nb)
        v = nb(k);
        if closed(v)
            continue                % fuer v steht der billigste Weg schon fest
        end

        % TODO 1: Was kostet der Weg zu v, wenn man ueber u geht?
        %         = Kosten bis u  +  Kante u->v
        gNew = g(u) + w(k);

        % TODO 2: RELAXATION -- nur wenn ECHT billiger (strikt <).
        %         Mit <= koennte par hin- und herspringen (Zyklus-Gefahr).
        if gNew < g(v)

            % TODO 3: Verbesserung uebernehmen
            g(v)   = gNew;            % neuen, besseren Preis merken
            par(v) = u;               % ... und von wo er kommt
            OPEN   = open_push(OPEN, v, g(v) + h(v)); % Key-Stelle 2: f = g + h
        end
    end
end

% ---- Ergebnis --------------------------------------------------------
[path, cost]     = reconstruct_path(par, s, t, W);  % rueckwaerts ueber par
stats.expansions = numel(order);
stats.order      = order;
stats.g          = g;          % alle g-Werte, zum Nachschauen/Erklaeren
end
