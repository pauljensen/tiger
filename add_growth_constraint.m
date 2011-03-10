function [tiger] = add_growth_constraint(tiger,val,varargin)

p = inputParser;
p.addParamValue('ctype','>');
p.addParamValue('valtype','frac');
p.parse(varargin{:});

switch p.Results.valtype
    case 'frac'
        sol = fba(tiger);
        assert(sol.val > 1e-8, 'FBA objective near zero.');
        value = val*sol.val;
    case 'abs'
        value = val;
end

tiger.A(end+1,:) = tiger.obj';
tiger.d(end+1) = value;
tiger.ctypes(end+1) = p.Results.ctype;
tiger.rownames{end+1} = 'GROWTH';
tiger.obj(:) = 0;
