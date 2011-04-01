function [sols] = solve_multiple_mips(mip,alts,varargin)

p = inputParser;
p.addParamValue('restart',true);
p.parse(varargin{:});

if isempty(alts)
    sols = cmpi.solve_mip(mip);
    return;
end

fields = fieldnames(alts);
Ncols = cellfun(@(x) size(alts.(x),2),fields);
Niter = Ncols(1);
assert(all(Ncols == Niter), ...
       'dimensions of each field in ALT are not consistent');

% start the solution
solver = cmpi.get_solver();

if ~issparse(mip.A)
    mip.A = sparse(mip.A);
end

if ~isfield(mip,'sense') || isempty(mip.sense)
    mip.sense = 1;
end

if ~isfield(mip,'options') || isempty(mip.options)
    mip.options = cmpi.get_options();
end

% preserve size before conversion
N = size(mip.A,2);

mip = cmpi.convert_indicators(mip);

sols.x = zeros(N,Niter);
sols.val = zeros(1,Niter);
sols.output = cell(1,Niter);
sols.flag = zeros(1,Niter);

if ~p.Results.restart
    solver = 'CMPI__NO_RESTART';
end

switch solver
    case 'cplex'
        % start acceleration
        cplex = Cplex();
        if mip.sense == 1
            cplex.Model.sense = 'minimize';
        else
            cplex.Model.sense = 'maximize';
        end
        cplex.Model.obj = mip.obj;
        mip.A(mip.ctypes == '>',:) = -mip.A(mip.ctypes == '>',:);
        mip.b(mip.ctypes == '>') = -mip.b(mip.ctypes == '>');
        cplex.Model.A = mip.A;
        cplex.Model.ctype = mip.vartypes;
        cplex.Model.lb = mip.lb(:);
        cplex.Model.ub = mip.ub(:);
        cplex.Model.rhs = mip.b(:);
        lhs = -inf*ones(size(mip.b(:)));
        lhs(mip.ctypes == '=') = mip.b(mip.ctypes == '=');
        cplex.Model.lhs = lhs;
        
        for i = 1 : Niter
            for f = 1 : length(fields)
                cplex.Model.(fields{f}) = alts.(fields{f})(:,i);
            end
            cplex.solve();
            sol.x = cplex.Solution.x;
            sol.flag = get_cplex_flag(cplex.Solution.status);
            sol.val = cplex.Solution.objval;
            sol.output = cplex.Solution.statusstring;
            record_sol(sol);
        end
        
    otherwise
        % call solve_mip on each case
        for i = 1 : Niter
            for f = 1 : length(fields)
                mip.(fields{f}) = alts.(fields{f})(:,i);
            end
            record_sol(cmpi.solve_mip(mip),i);
        end
end

function record_sol(s,j)
    if ~isempty(s.x)
        sols.x(:,j) = s.x(1:N);
    end
    sols.val(j) = s.val;
    sols.output{j} = s.output;
    sols.flag(j) = s.flag;
end

end
