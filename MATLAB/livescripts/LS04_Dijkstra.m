%[text] # Kapitel 04 – Dijkstra
%[text] **Datei:** `tasks/dijkstra_graph.m`  ·  **Container:** `'minkey'` mit Key $g(v)$  ·  **Ziel am Kursgraphen:** A–B–E–F, Kosten 3, 5 Expansionen
%[text] **Bevor du startest:** Current Folder auf `MATLAB/` setzen, dann Abschnitt für Abschnitt mit *Run Section* ausführen.
%%
%[text] ## 1  Idee
%[text] Ab jetzt wird gerechnet. $g(v)$ sind die Kosten des **besten bisher bekannten** Weges von $s$ nach $v$:
%[text] $g(s) = 0$  und  $g(v) = \\infty$ für alle anderen Knoten $v$
%[text] Expandiert wird immer der Knoten mit den kleinsten bisherigen Kosten:
%[text] $u = \\arg\\min_{v \\in \\mathrm{OPEN}} \\; g(v)$
%[text] **Relaxation** – für jede Kante $u \\to v$ mit Gewicht $w(u,v)$:
%[text] $g_{\\mathrm{neu}} = g(u) + w(u,v)$
%[text] Falls $g_{\\mathrm{neu}} < g(v)$:   $g(v) \\leftarrow g_{\\mathrm{neu}}, \\quad \\mathrm{par}(v) \\leftarrow u, \\quad v \\rightarrow \\mathrm{OPEN}$
%[text] Bei Kantengewichten $w \\ge 0$ ist der gefundene Weg **optimal**.
%%
%[text] ## 2  Kursgraph laden
if exist('setup_path', 'file') ~= 2, cd('..'), end   % falls MATLAB in livescripts/ gewechselt hat
setup_path
G = graph_example();
plot_graph(G, 'Title', 'Kursgraph A–F')
%%
%[text] ## 3  Vorbereitung
%[text] Neu: das Array `g`. Weg ist `seen` – ein Knoten **darf** mehrmals in OPEN landen, wenn später ein billigerer Weg auftaucht.
W = G.W;  s = G.s;  t = G.t;
n      = size(W, 1);
g      = inf(n, 1);               % noch kein Weg bekannt
g(s)   = 0;                       % Start kostet nichts
par    = zeros(n, 1);
closed = false(n, 1);
order  = zeros(1, 0);
OPEN = open_new('minkey');
OPEN = open_push(OPEN, s, g(s));  % Key = g(s) = 0
%%
%[text] ## 4  Die Suchschleife mit Relaxation
%[text:table]
%[text] | TODO | Code | Formel |
%[text] | --- | --- | --- |
%[text] | 1 | `gNew = g(u) + w(k);` | $g_{\\mathrm{neu}} = g(u) + w(u,v)$ |
%[text] | 2 | `if gNew < g(v)` | $g_{\\mathrm{neu}} < g(v)$ – nur wenn **echt** billiger |
%[text] | 3 | `g(v) = gNew; par(v) = u; OPEN = open_push(OPEN, v, g(v));` | $g(v) \\leftarrow g_{\\mathrm{neu}}$, $\\mathrm{par}(v) \\leftarrow u$ |
%[text:table]
%[text] Der Check `if closed(u), continue` ist jetzt **wirklich nötig**: liegt ein Knoten zweimal in OPEN, zählt nur der erste (billigste) Eintrag.
while ~open_isempty(OPEN)
    [OPEN, u] = open_pop(OPEN);   % kleinstes g zuerst
    if closed(u), continue, end   % veralteter Eintrag -> weg
    closed(u)      = true;
    order(end + 1) = u;
    trace_step(numel(order), u);
    if u == t, break, end
    [nb, w] = graph_neighbors(W, u);   % Nachbarn UND Kantenkosten
    for k = 1:numel(nb)
        v = nb(k);
        if closed(v), continue, end
        gNew = g(u) + w(k);           % TODO 1
        if gNew < g(v)                % TODO 2
            g(v)   = gNew;            % TODO 3
            par(v) = u;
            OPEN   = open_push(OPEN, v, g(v));
        end
    end
end
%%
%[text] ## 5  Ergebnis
%[text:table]
%[text] | Schritt | genommen | Relaxationen |
%[text] | --- | --- | --- |
%[text] | 1 | A, $g = 0$ | $g(B) = 1$, $g(C) = 1$, $g(D) = 6$ |
%[text] | 2 | B, $g = 1$ | $g(E) = 1 + 1 = 2$ |
%[text] | 3 | C, $g = 1$ | E über C: $1 + 2 = 3 \\not< 2$ → keine Änderung |
%[text] | 4 | E, $g = 2$ | $g(F) = 2 + 1 = 3$ |
%[text] | 5 | F, $g = 3$ | Ziel → Abbruch |
%[text:table]
%[text] D bleibt mit $g(D) = 6$ in OPEN liegen und wird nie herausgenommen. Bei B und C (beide $g = 1$) entscheidet die Knotennummer.
[p, c] = reconstruct_path(par, s, t, W)
expansionen = numel(order)
plot_graph(G, 'Expanded', order, 'Path', p, 'Values', g, 'Label', 'g', 'Title', sprintf('Dijkstra: Kosten %g, %d Expansionen', c, expansionen))
%%
%[text] ## 6  Gegenprobe mit deiner Funktion
[p2, c2, st2] = dijkstra_graph(G.W, G.s, G.t);
gleich = isequal(p2, p) && c2 == c && st2.expansions == expansionen
check_my_code('dijkstra')
%%
%[text] ## 7  Für die Prüfung
%[text] - **Was ist Relaxation?** Prüfen, ob der Weg über $u$ billiger ist, und wenn ja $g$, $\\mathrm{par}$ und OPEN aktualisieren.
%[text] - **Warum strikt** $<$ **und nicht** $\\le$**?** Sonst springt `par` bei gleich teuren Wegen hin und her – im schlimmsten Fall entsteht ein Zyklus.
%[text] - **Warum Zieltest erst beim Herausnehmen?** Erst dann ist sicher, dass $g(t)$ minimal ist – alle Einträge in OPEN haben einen Key $\\ge g(t)$.
%[text] - **Warum kein** `seen`**?** Ein Knoten muss erneut in OPEN dürfen, wenn ein billigerer Weg gefunden wird. \\
%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
