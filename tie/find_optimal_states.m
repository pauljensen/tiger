function [states,score,matched,total] = find_optimal_states(d,T,w)
% FIND_OPTIMAL_STATES  Find optimal binary states
%
%   [STATES,SCORE,MATCHED,TOTAL] = FIND_OPTIMAL_STATES(D,T,W)
%
%   Returns a binary sequence STATES that most closely match the
%   transitions in D (1 -> increase, -1 -> decrease, 0 -> no change).
%   The columns in D are described by the transition matrix T (see MADE
%   for details on T).  If given, the transitions are weighted by W; if
%   unspecified, W is a vector of ones (i.e., the maximum number of
%   transitions is matched).
%
%   SCORE is the MADE score for STATES.  MATCHED is the number of
%   transitions in D that are matched by STATES.  TOTAL is the number
%   of transitions in D.

if nargin < 3 || isempty(w)
    w = ones(size(d));
end

N = length(T);
total = length(d);

best_score   = -1e100;
best_states  = zeros(1,N);
best_matched = 0;
for i = 0 : 2^(N-1)
    states  = int2bin(i,N);
    score   = 0;
    matched = 0;
    for j = 1 : total
        [cond1,cond2] = find_conditions(j,T);
        if d(j) == 0
            score = score - w(j)*(states(cond1) == states(cond2));
        else
            d_obs = states(cond2) - states(cond1);
        	score = score - w(j)*abs(d_obs - d(j));
        end
        matched = matched + (states(cond2) - states(cond1) == d(j));
    end
    if score > best_score
        best_score   = score;
        best_states  = states;
        best_matched = matched;
    end
end

states  = best_states;
score   = best_score;
matched = best_matched;