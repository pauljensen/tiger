function [minflux,maxflux] = fva(tiger,varargin)

p = inputParser;
p.addParamValue('vars',1:size(tiger.S,2));
p.addParamValue('frac',1.0);
p.addParamValue('status',true);
p.parse(varargin{:});

vars = convert_ids(tiger.varnames,p.Results.vars,'index');
frac = p.Results.frac;
status = p.Results.status;

nvars = length(vars);
minflux = zeros(nvars,1);
maxflux = zeros(nvars,1);

tiger = add_growth_constraint(tiger,frac);

statbar = statusbar(nvars,status);
statbar.start('Flux Variability status');
for i = 1 : nvars
    tiger.obj(:) = 0;
    
    tiger.obj(vars(i)) = 1;
    
    tiger.sense = 1;
    minflux(i) = get_objval(tiger);
 
    tiger.sense = -1;
    maxflux(i) = get_objval(tiger);
    
    statbar.update(i);
end


function [val] = get_objval(model)
    sol = cmpi.solve_mip(model);
    if ~isempty(sol.x);
        val = sol.val;
    else
        val = NaN;
    end
        