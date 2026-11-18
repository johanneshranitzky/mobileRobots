%[text] # Kapitel 03 – Breitensuche (BFS)
%[text] **Datei:** `tasks/bfs_graph.m`  ·  **Container:** `'fifo'` (Warteschlange)  ·  **Ziel am Kursgraphen:** A–D–F, 2 Schritte, Kosten 7, 6 Expansionen
%[text] **Bevor du startest:** Current Folder auf `MATLAB/` setzen, dann Abschnitt für Abschnitt mit *Run Section* ausführen.
%%
%[text] ## 1  Idee
%[text] BFS ist **DFS mit einem einzigen geänderten Wort**: `'fifo'` statt `'lifo'`. Damit kommt immer der **am frühesten entdeckte** Knoten zuerst dran:
%[text] $u \\leftarrow$ der am längsten in OPEN wartende Knoten
%[text] Die Suche breitet sich in Schichten aus. $L_d$ ist die Menge der Knoten mit $d$ Schritten Abstand zum Start:
%[text] $L_0 = \\{A\\}, \\quad L_1 = \\{B, C, D\\}, \\quad L_2 = \\{E, F\\}$
%[text] BFS findet den Weg mit den **wenigsten Schritten** $\\min |\\pi|$ – nicht den billigsten $\\min c(\\pi)$.
%%
%[text] ## 2  Kursgraph laden
if exist('setup_path', 'file') ~= 2, cd('..'), end   % falls MATLAB in livescripts/ gewechselt hat
setup_path
G = graph_example();
plot_graph(G, 'Title', 'Kursgraph A–F')
%%
%[text] ## 3  Vorbereitung
%[text] Gleiche Datenstrukturen wie bei DFS – nur der Container ist anders.
W = G.W;  s = G.s;  t = G.t;
n      = size(W, 1);
par    = zeros(n, 1);
seen   = false(n, 1);
closed = false(n, 1);
order  = zeros(1, 0);
OPEN = open_new('fifo');          % DAS EINE GEAENDERTE WORT
seen(s) = true;
OPEN    = open_push(OPEN, s);
%%
%[text] ## 4  Die Suchschleife
%[text] Exakt dieselbe Schleife wie bei DFS. Der Unterschied steckt komplett in `open_pop`: FIFO gibt den ältesten Eintrag zurück.
while ~open_isempty(OPEN)
    [OPEN, u] = open_pop(OPEN);   % FIFO: aeltester Eintrag
    if closed(u), continue, end
    closed(u)      = true;
    order(end + 1) = u;
    trace_step(numel(order), u);
    if u == t, break, end
    nb = graph_neighbors(W, u);
    for k = 1:numel(nb)
        v = nb(k);
        if seen(v) || closed(v), continue, end
        par(v)  = u;
        OPEN    = open_push(OPEN, v);  % hinten anstellen
        seen(v) = true;
    end
end
%%
%[text] ## 5  Ergebnis
%[text] Reihenfolge A, B, C, D, E, F: erst alle Nachbarn von A, dann deren Nachbarn. F wurde über D entdeckt (D kam vor E dran), darum `par(F) = D`.
%[text] $|A \\to D \\to F| = 2$ Schritte, aber $c = 6 + 1 = 7$.
[p, c] = reconstruct_path(par, s, t, W)
schritte    = numel(p) - 1
expansionen = numel(order)
plot_graph(G, 'Expanded', order, 'Path', p, 'Title', sprintf('BFS: Kosten %g, %d Expansionen', c, expansionen))
%%
%[text] ## 6  Gegenprobe mit deiner Funktion
[p2, c2, st2] = bfs_graph(G.W, G.s, G.t);
gleich = isequal(p2, p) && c2 == c && st2.expansions == expansionen
check_my_code('bfs')
%%
%[text] ## 7  Für die Prüfung
%[text] - **DFS vs. BFS?** Nur der Container: LIFO (Stapel) gegen FIFO (Warteschlange). Das ist die Kernaussage der Vorlesung.
%[text] - **Wann ist BFS optimal?** Wenn alle Kanten gleich viel kosten – dann gilt „wenigste Schritte = billigster Weg“.
%[text] - **Warum hier nicht?** Die Kante A–D kostet 6, BFS zählt aber nur Kanten, keine Gewichte. \\
%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
