function show_flux(tiger,sol,show_cond)

if nargin < 3
    show_cond = 'x ~= 0';
end

x = sol.x;
to_show = find(eval(show_cond));

x(tiger.vartypes ~= 'c') = round(x(tiger.vartypes ~= 'c'));

for i = 1 : length(to_show)
    if tiger.vartypes(to_show(i)) == 'c'
        fmt = '%10s:  %+08f\n';
    else
        fmt = '%10s:  %i\n';
    end
    fprintf(fmt,tiger.varnames{to_show(i)},x(to_show(i)));    
end
