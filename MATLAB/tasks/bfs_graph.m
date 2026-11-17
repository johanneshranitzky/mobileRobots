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

n      = size(W, 1);
par    = zeros(n, 1);     % par(v): which node did we come from to reach v
seen   = false(n, 1);     % already put into OPEN once?
closed = false(n, 1);     % neighbours already looked at?
order  = zeros(1, 0);     % which nodes came out, in order

% Copied from dfs_graph. Only difference: the container.
OPEN = open_new('fifo');   % SOLVED: the ONE changed word -- FIFO = queue = breadth-first

seen(s) = true;
OPEN    = open_push(OPEN, s);

while ~open_isempty(OPEN)
    [OPEN, u] = open_pop(OPEN);

    % A stale entry? Skip it. (In this pattern the line never fires,
    % because seen already prevents duplicates. It is here so the loop
    % stays unchanged when you move to task 4, where it is essential.)
    if closed(u)
        continue
    end
    closed(u)      = true;
    order(end + 1) = u;   %#ok<AGROW>
    trace_step(numel(order), u);

    % TODO 3 -- When are we done? Replace false by the condition.
    % SOLVED: stop as soon as the goal is taken out of OPEN
    if u == t
        break
    end

    nb = graph_neighbors(W, u);
    for k = 1:numel(nb)
        v = nb(k);
        if seen(v) || closed(v)
            continue
        end

        % TODO 1 -- Two lines are missing here:
        %             - remember that we reached v coming from u
        %             - put v into OPEN  (open_push)
        % SOLVED:
        par(v)  = u;                   % we reached v coming from u
        OPEN    = open_push(OPEN, v);  % v waits in OPEN (assign OPEN!)
        seen(v) = true;
    end
end

[path, cost]     = reconstruct_path(par, s, t, W);
stats.expansions = numel(order);
stats.order      = order;
end
