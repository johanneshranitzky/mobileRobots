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

n      = size(W, 1);
par    = zeros(n, 1);     % par(v): which node did we come from to reach v
seen   = false(n, 1);     % already put into OPEN once?
closed = false(n, 1);     % neighbours already looked at?
order  = zeros(1, 0);     % which nodes came out, in order

% Copied from bfs_graph. Two changes: container and key.
OPEN = open_new('minkey'); % SOLVED change 1: sort by a key (priority queue)

seen(s) = true;
OPEN    = open_push(OPEN, s, h(s));   % SOLVED change 2: key = h(s)

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
        OPEN    = open_push(OPEN, v, h(v));  % SOLVED change 2: key = h(v), only the estimate
        seen(v) = true;
    end
end

[path, cost]     = reconstruct_path(par, s, t, W);
stats.expansions = numel(order);
stats.order      = order;
end
