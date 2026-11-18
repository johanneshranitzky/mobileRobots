%[text] # Kapitel 06 – `A*`
%[text] **Datei:** `tasks/astar_graph.m`  ·  **Container:** `'minkey'` mit Key $f(v) = g(v) + h(v)$  ·  **Ziel am Kursgraphen:** A–B–E–F, Kosten 3, 4 Expansionen
%[text] **Bevor du startest:** Current Folder auf `MATLAB/` setzen, dann Abschnitt für Abschnitt mit *Run Section* ausführen.
%%
%[text] ## 1  Idee
%[text] `A*` kombiniert Dijkstra und Greedy:
%[text] $f(v) = \\underbrace{g(v)}_{\\mathrm{bisher}} + \\underbrace{h(v)}_{\\mathrm{Rest}}$
%[text] $u = \\arg\\min_{v \\in \\mathrm{OPEN}} \\; f(v)$
%[text] Der Code ist **Dijkstra mit anderem Key** – an genau **zwei** Stellen: beim Start und beim Push in der Schleife.
%[text] `A*` ist optimal, wenn $h$ **zulässig** ist, also die echten Restkosten $h^{\\ast}(v)$ nie überschätzt:
%[text] $0 \\le h(v) \\le h^{\\ast}(v) \\quad \\forall v$
%[text] Mit $h \\equiv 0$ ist `A*` exakt Dijkstra.
%%
%[text] ## 2  Kursgraph mit Heuristik
if exist('setup_path', 'file') ~= 2, cd('..'), end   % falls MATLAB in livescripts/ gewechselt hat
setup_path
G = graph_example();
h = G.h;
plot_graph(G, 'Values', h, 'Label', 'h', 'Title', 'Kursgraph mit h')
%%
%[text] ## 3  Vorbereitung
W = G.W;  s = G.s;  t = G.t;
n      = size(W, 1);
g      = inf(n, 1);
g(s)   = 0;
par    = zeros(n, 1);
closed = false(n, 1);
order  = zeros(1, 0);
OPEN = open_new('minkey');
OPEN = open_push(OPEN, s, g(s) + h(s));   % Key-Stelle 1: f = g + h
%%
%[text] ## 4  Die Suchschleife
%[text] Identisch mit Dijkstra – nur die markierte Push-Zeile hat den Key $g(v) + h(v)$ statt $g(v)$.
while ~open_isempty(OPEN)
    [OPEN, u] = open_pop(OPEN);   % kleinstes f zuerst
    if closed(u), continue, end
    closed(u)      = true;
    order(end + 1) = u;
    trace_step(numel(order), u);
    if u == t, break, end
    [nb, w] = graph_neighbors(W, u);
    for k = 1:numel(nb)
        v = nb(k);
        if closed(v), continue, end
        gNew = g(u) + w(k);
        if gNew < g(v)
            g(v)   = gNew;
            par(v) = u;
            OPEN   = open_push(OPEN, v, g(v) + h(v));   % Key-Stelle 2
        end
    end
end
%%
%[text] ## 5  Ergebnis
%[text:table]
%[text] | Schritt | genommen | neu in OPEN |
%[text] | --- | --- | --- |
%[text] | 1 | A: $f = 0 + 3 = 3$ | B: $1 + 2 = 3$, C: $1 + 3 = 4$, D: $6 + 1 = 7$ |
%[text] | 2 | B: $f = 3$ | E: $2 + 1 = 3$ |
%[text] | 3 | E: $f = 3$ | F: $3 + 0 = 3$ |
%[text] | 4 | F: $f = 3$ | Ziel → Abbruch |
%[text:table]
%[text] Gleicher Weg wie Dijkstra, aber **eine Expansion weniger**: C wird nie angefasst, weil $f(C) = 4 > 3$.
[p, c] = reconstruct_path(par, s, t, W)
expansionen = numel(order)
f = g(:) + h(:);
plot_graph(G, 'Expanded', order, 'Path', p, 'Values', f, 'Label', 'f', 'Title', sprintf('A*: Kosten %g, %d Expansionen', c, expansionen))
%%
%[text] ## 6  Gegenprobe mit deiner Funktion
[p2, c2, st2] = astar_graph(G.W, G.s, G.t, G.h(:));
gleich = isequal(p2, p) && c2 == c && st2.expansions == expansionen
%[text] Mit $h \\equiv 0$ muss `A*` exakt Dijkstra sein:
[pA, cA, stA] = astar_graph(G.W, G.s, G.t, zeros(6, 1));
[pD, cD, stD] = dijkstra_graph(G.W, G.s, G.t);
wie_dijkstra = isequal(pA, pD) && cA == cD && stA.expansions == stD.expansions
%[text] Mit einer **unzulässigen** Heuristik ($h(B) = h(C) = 8$ überschätzt) verliert `A*` die Optimalität:
hBad = [3 8 8 1 1 0].';
[pB, cB] = astar_graph(G.W, G.s, G.t, hBad)
check_my_code('astar')
%%
%[text] ## 7  Für die Prüfung
%[text] - **Greedy vs.** `A*`**?** Greedy: Key $h$. `A*`: Key $g + h$. Durch $g$ sieht `A*` die teure Kante A–D.
%[text] - **Dijkstra vs.** `A*`**?** Gleicher Code, anderer Key. $h$ lenkt die Suche Richtung Ziel → meist weniger Expansionen.
%[text] - **Wann ist** `A*` **optimal?** Wenn $h$ zulässig ist: $h(v) \\le h^{\\ast}(v)$.
%[text] - **Häufigster Fehler?** Den Key nur an einer der zwei Stellen ändern. \\
%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
