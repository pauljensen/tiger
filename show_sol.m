function show_sol(tiger,sol,show_cond)
% SHOW_SOL  Show a solution vector
%
%   SHOW_SOL(TIGER,SOL,SHOW_COND)
%
%   Shows the values for each nonzero variable in the solution structure
%   SOL.  The optional string SHOW_COND contains a test on the variable
%   'x' to identify which fluxes should be shown.  The default is
%   'x ~= 0'.  If SHOW_COND = 'all', all variables are shown.

if nargin < 3
    show_cond = 'x ~= 0';
end

x = sol.x;
if strcmpi(show_cond,'all')
    to_show = 1:length(sol.x);
else
    to_show = find(eval(show_cond));
end
    
x(tiger.vartypes ~= 'c') = round(x(tiger.vartypes ~= 'c'));

for i = 1 : length(to_show)
    if tiger.vartypes(to_show(i)) == 'c'
        fmt = '%10s:  %+08f\n';
    else
        fmt = '%10s:  %i\n';
    end
    fprintf(fmt,tiger.varnames{to_show(i)},x(to_show(i)));    
end
