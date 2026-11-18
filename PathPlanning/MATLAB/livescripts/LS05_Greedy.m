%[text] # Kapitel 05 – Greedy Best-First
%[text] **Datei:** `tasks/greedy_graph.m`  ·  **Container:** `'minkey'` mit Key $h(v)$  ·  **Ziel am Kursgraphen:** A–D–F, Kosten 7, 3 Expansionen
%[text] **Bevor du startest:** Current Folder auf `MATLAB/` setzen, dann Abschnitt für Abschnitt mit *Run Section* ausführen.
%%
%[text] ## 1  Idee
%[text] Greedy nimmt immer den Knoten, der dem Ziel am **nächsten zu sein scheint**. Dafür gibt es die Heuristik $h(v)$ = geschätzte Restkosten von $v$ bis zum Ziel, mit $h(t) = 0$.
%[text] $u = \\arg\\min_{v \\in \\mathrm{OPEN}} \\; h(v)$
%[text] Gegenüber BFS ändern sich genau **zwei** Dinge:
%[text] - `open_new('minkey')` – Prioritätswarteschlange, kleinster Key zuerst
%[text] - bei **jedem** `open_push` den Key $h(\\cdot)$ mitgeben – beim Start und bei jedem Nachbarn \\
%[text] Kein $g$, keine Relaxation: Greedy weiß nicht, was der bisherige Weg gekostet hat.
%%
%[text] ## 2  Kursgraph mit Heuristik
%[text] Die Zahlen unter den Knoten sind $h(v)$.
if exist('setup_path', 'file') ~= 2, cd('..'), end   % falls MATLAB in livescripts/ gewechselt hat
setup_path
G = graph_example();
h = G.h;
plot_graph(G, 'Values', h, 'Label', 'h', 'Title', 'Kursgraph mit h')
%%
%[text] ## 3  Vorbereitung
W = G.W;  s = G.s;  t = G.t;
n      = size(W, 1);
par    = zeros(n, 1);
seen   = false(n, 1);
closed = false(n, 1);
order  = zeros(1, 0);
OPEN = open_new('minkey');        % Aenderung 1
seen(s) = true;
OPEN    = open_push(OPEN, s, h(s));   % Aenderung 2: Key = h(s)
%%
%[text] ## 4  Die Suchschleife
while ~open_isempty(OPEN)
    [OPEN, u] = open_pop(OPEN);   % kleinstes h zuerst
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
        OPEN    = open_push(OPEN, v, h(v));   % Aenderung 2: Key = h(v)
        seen(v) = true;
    end
end
%%
%[text] ## 5  Ergebnis
%[text] Von A aus liegen B, C, D in OPEN mit
%[text] $h(B) = 2, \\quad h(C) = 3, \\quad h(D) = 1 \\;\\Rightarrow\\; u = D$
%[text] D sieht am nächsten aus – dass die Kante A–D 6 kostet, sieht Greedy nicht. Danach $h(F) = 0$ → Ziel.
[p, c] = reconstruct_path(par, s, t, W)
expansionen = numel(order)
plot_graph(G, 'Expanded', order, 'Path', p, 'Values', h, 'Label', 'h', 'Title', sprintf('Greedy: Kosten %g, %d Expansionen', c, expansionen))
%%
%[text] ## 6  Gegenprobe mit deiner Funktion
[p2, c2, st2] = greedy_graph(G.W, G.s, G.t, G.h(:));
gleich = isequal(p2, p) && c2 == c && st2.expansions == expansionen
check_my_code('greedy')
%%
%[text] ## 7  Für die Prüfung
%[text] - **Greedy und DFS liefern hier dasselbe – Zufall?** Ja. DFS nimmt D, weil D zuletzt eingefügt wurde (LIFO). Greedy nimmt D, weil $h(D)$ am kleinsten ist. Andere Regel, zufällig gleiches Ergebnis.
%[text] - **Ist Greedy optimal?** Nein, es ignoriert die bisherigen Kosten $g$.
%[text] - **Vorteil?** Meist sehr wenige Expansionen – schnell, aber nicht gut. \\
%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
