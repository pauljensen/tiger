function show_tiger(tiger,showvars)
% SHOW_TIGER  Show a TIGER model as a MIP

if nargin < 2
    showvars = false;
end

cmpi.show_mip(make_milp(tiger),'showvars',showvars);
