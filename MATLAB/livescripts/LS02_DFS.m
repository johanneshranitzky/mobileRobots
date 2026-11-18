%[text] # Kapitel 02 – Tiefensuche (DFS)
%[text] **Datei:** `tasks/dfs_graph.m`  ·  **Container:** `'lifo'` (Stapel)  ·  **Ziel am Kursgraphen:** A–D–F, Kosten 7, 3 Expansionen
%[text] **Bevor du startest:** Current Folder auf `MATLAB/` setzen, dann dieses Script Abschnitt für Abschnitt mit *Run Section* ausführen.
%%
%[text] ## 1  Idee
%[text] DFS macht immer mit dem **zuletzt entdeckten** Knoten weiter und taucht so tief wie möglich in einen Ast hinein. OPEN verhält sich wie ein Stapel:
%[text] $u \\leftarrow$ der zuletzt in OPEN eingefügte Knoten
%[text] Kantenkosten spielen bei der Auswahl **keine** Rolle. Die Kosten des gefundenen Weges $\\pi = (v_1, \\dots, v_k)$ werden erst am Ende berechnet:
%[text] $c(\\pi) = \\sum_{i=1}^{k-1} w(v_i, v_{i+1})$
%%
%[text] ## 2  Kursgraph laden
%[text] Start A, Ziel F. Die Kante A–D kostet 6 – das ist die „Falle“.
if exist('setup_path', 'file') ~= 2, cd('..'), end   % falls MATLAB in livescripts/ gewechselt hat
setup_path
G = graph_example();
plot_graph(G, 'Title', 'Kursgraph A–F')
%%
%[text] ## 3  Vorbereitung
%[text] - `par(v)` – Vorgänger von $v$ auf dem Weg (0 = keiner)
%[text] - `seen(v)` – $v$ lag schon einmal in OPEN → nie doppelt einfügen
%[text] - `closed(v)` – $v$ wurde schon expandiert
%[text] - `order` – Reihenfolge der Expansionen \\
W = G.W;  s = G.s;  t = G.t;
n      = size(W, 1);
par    = zeros(n, 1);
seen   = false(n, 1);
closed = false(n, 1);
order  = zeros(1, 0);
OPEN = open_new('lifo');          % TODO 2: Stapel -> Tiefensuche
seen(s) = true;
OPEN    = open_push(OPEN, s);     % OPEN = ... nicht vergessen!
%%
%[text] ## 4  Die Suchschleife
%[text] Pro Runde: Knoten $u$ holen → Zieltest → alle Nachbarn $v$ merken und in OPEN legen. Die drei gelösten TODOs:
%[text:table]
%[text] | TODO | Code | Bedeutung |
%[text] | --- | --- | --- |
%[text] | 1 | `par(v) = u; OPEN = open_push(OPEN, v);` | $v$ wurde über $u$ erreicht, $v$ wartet in OPEN |
%[text] | 2 | `open_new('lifo')` | Stapel: neuester Knoten zuerst |
%[text] | 3 | `if u == t, break` | fertig, sobald das Ziel **herausgenommen** wird |
%[text:table]
while ~open_isempty(OPEN)
    [OPEN, u] = open_pop(OPEN);   % LIFO: zuletzt eingefuegter Knoten
    if closed(u), continue, end
    closed(u)      = true;
    order(end + 1) = u;
    trace_step(numel(order), u);  % druckt "step k: take X"
    if u == t, break, end         % TODO 3
    nb = graph_neighbors(W, u);   % Nachbarn aufsteigend: B, C, D ...
    for k = 1:numel(nb)
        v = nb(k);
        if seen(v) || closed(v), continue, end
        par(v)  = u;              % TODO 1a
        OPEN    = open_push(OPEN, v);  % TODO 1b
        seen(v) = true;
    end
end
%%
%[text] ## 5  Ergebnis
%[text] A legt B, C, D ab → D liegt oben → D kommt als Nächstes → D legt F ab → F ist das Ziel.
%[text] $c(A \\to D \\to F) = 6 + 1 = 7$, obwohl $c(A \\to B \\to E \\to F) = 1 + 1 + 1 = 3$ möglich wäre.
[p, c] = reconstruct_path(par, s, t, W)
expansionen = numel(order)
plot_graph(G, 'Expanded', order, 'Path', p, 'Title', sprintf('DFS: Kosten %g, %d Expansionen', c, expansionen))
%%
%[text] ## 6  Gegenprobe mit deiner Funktion
%[text] Die Schleife oben ist identisch mit `tasks/dfs_graph.m`. Beide müssen dasselbe liefern:
[p2, c2, st2] = dfs_graph(G.W, G.s, G.t);
gleich = isequal(p2, p) && c2 == c && st2.expansions == expansionen
check_my_code('dfs')
%%
%[text] ## 7  Für die Prüfung
%[text] - **Was macht DFS zu DFS?** Nur der Container `'lifo'` – der zuletzt entdeckte Knoten wird zuerst expandiert.
%[text] - **Ist DFS optimal?** Nein. Es ignoriert Kosten und garantiert weder minimale Kosten noch minimale Schritte.
%[text] - **Wo entsteht der Weg?** Nicht während der Suche – nur `par` wird gefüllt, `reconstruct_path` läuft am Ende rückwärts von $t$ nach $s$.
%[text] - **Warum** `OPEN = open_push(...)`**?** MATLAB übergibt Structs als Kopie; ohne Zuweisung ist die Änderung weg. \\
%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
