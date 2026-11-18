function [path, cost, stats] = dijkstra_graph(W, s, t)
%DIJKSTRA_GRAPH  TASK 4 -- Dijkstra.
%
%   From here on there is arithmetic. Two things come in:
%
%     g(v)         what the best route to v found so far costs
%     relaxation   is going through u cheaper than what we knew?
%
%   That is why the seen array is gone: a node MAY enter OPEN again when
%   a cheaper route to it turns up. And that is why the line
%   "if closed(u)" now really matters -- the same node can sit in OPEN
%   several times and only the first one out counts.
%
%   Target:  A - B - E - F, cost 3, 5 expansions.
%            D stays in OPEN with g = 6 and is never taken out.
%
%   Check:   check_my_code('dijkstra')

%
% =====================================================================
%  ERKLAERUNG (Deutsch) -- Dijkstra
% ---------------------------------------------------------------------
%  Idee: Expandiere immer den Knoten mit den KLEINSTEN BISHERIGEN
%  KOSTEN g(v). So waechst die Suche "kreisfoermig" nach Kosten um den
%  Start. Mit nichtnegativen Kanten ist der gefundene Weg OPTIMAL.
%  Key in OPEN = g(v).
%  Kursgraph: A,B,C,E,F expandiert -> A-B-E-F, Kosten 3, 5 Expansionen.
%  D bleibt mit g=6 in OPEN liegen und wird nie herausgenommen.
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
OPEN = open_push(OPEN, s, g(s));     % Key = g(s) = 0

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
            OPEN   = open_push(OPEN, v, g(v)); % Key = g(v) (bisherige Kosten)
        end
    end
end

% ---- Ergebnis --------------------------------------------------------
[path, cost]     = reconstruct_path(par, s, t, W);  % rueckwaerts ueber par
stats.expansions = numel(order);
stats.order      = order;
stats.g          = g;          % alle g-Werte, zum Nachschauen/Erklaeren
end
