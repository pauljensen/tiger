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
sols.time = zeros(1,Niter);

if ~p.Results.restart
    solver = 'CMPI__NO_RESTART';
end

switch solver
    case 'cplex'
        % start acceleration
        cplex = Cplex();
        cplex.DisplayFunc = [];
        if mip.sense == 1
            cplex.Model.sense = 'minimize';
        else
            cplex.Model.sense = 'maximize';
        end
        cplex.Model.obj = mip.obj;
        mip.A(mip.ctypes == '>',:) = -mip.A(mip.ctypes == '>',:);
        mip.b(mip.ctypes == '>') = -mip.b(mip.ctypes == '>');
        cplex.Model.A = mip.A;
        cplex.Model.ctype = upper(mip.vartypes);
        cplex.Model.lb = mip.lb(:);
        cplex.Model.ub = mip.ub(:);
        cplex.Model.rhs = mip.b(:);
        lhs = -inf*ones(size(mip.b(:)));
        lhs(mip.ctypes == '=') = mip.b(mip.ctypes == '=');
        cplex.Model.lhs = lhs;
        
        [~,cplex] = cmpi.set_cplex_opts(mip.options,cplex);
        if isfield(mip.options,'Display')
            if strcmpi(mip.options.Display,'off')
                cplex.DisplayFunc = [];
            end
        end
        
        for i = 1 : Niter
            for f = 1 : length(fields)
                cplex.Model.(fields{f}) = alts.(fields{f})(:,i);
            end
            start_time = tic;
            cplex.solve();
            total_time = toc(start_time);
            sol.x = cplex.Solution.x;
            sol.flag = cmpi.get_cplex_flag(cplex.Solution.status);
            sol.val = cplex.Solution.objval;
            sol.output = cplex.Solution.statusstring;
            record_sol(sol,i);
            if length(cplex.MipStart) > 1
                cplex.MipStart = cplex.MipStart(end);
            end
        end
        
    otherwise
        % call solve_mip on each case
        for i = 1 : Niter
            for f = 1 : length(fields)
                mip.(fields{f}) = alts.(fields{f})(:,i);
            end
            start_time = tic;
            sol = cmpi.solve_mip(mip);
            total_time = toc(start_time);
            record_sol(sol,i);
        end
end

function record_sol(s,j)
    if ~isempty(s.x)
        sols.x(:,j) = s.x(1:N);
    end
    sols.val(j) = s.val;
    sols.output{j} = s.output;
    sols.flag(j) = s.flag;
    sols.time(j) = total_time;
end

end
