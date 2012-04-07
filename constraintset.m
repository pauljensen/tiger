classdef constraintset < handle

properties
    coefs = {};
    vars = {};
    ctype = '';
    rhs = [];
    
    ind_row = {};
    ind_id = {};
    indtype = '';
    
    bound_var = {};
    bound_ind = {};
    bound_type = '';
    
    varnames = {};
    vartypes = '';
    lb = [];
    ub = [];
    
    default_lb = 0;
    default_ub = 1;
    default_vartype = 'b';
    
    continuous_nots = true;
    not_prefix = 'NOT__';
end

methods
    function add_ineq(obj,coefs,vars,ctype,rhs)
        if nargin < 4 || isempty(rhs)
            rhs = 0;
        end
        if nargin < 3 || isempty(ctype)
            ctype = '<';
        end
        
        if isempty(coefs)
            coefs = ones(size(vars));
        end
        
        obj.coefs{end+1} = coefs;
        obj.vars{end+1} = vars;
        obj.ctype(end+1) = ctype;
        obj.rhs(end+1) = rhs;
    end
    
    function add_eq(obj,varargin)
        obj.add_ineq(varargin{:});
    end
    
    function add_ind(obj,row,ind,type)
        obj.ind_row{end+1} = row;
        obj.ind_id{end+1} = ind;
        obj.indtype(end+1) = type;
    end
    
    function add_bound(obj,var,ind,type)
        obj.bound_var{end+1} = var;
        obj.bound_ind{end+1} = ind;
        obj.bound_type(end+1) = type;
    end
    
    function add_var(obj,name,type,lb,ub)
        if nargin < 3
            type = obj.default_vartype;
        end
        if nargin < 4
            lb = obj.default_lb;
        end
        if nargin < 5
            ub = obj.default_ub;
        end
        
        obj.varnames{end+1} = name;
        obj.vartypes(end+1) = type;
        obj.lb(end+1) = lb;
        obj.ub(end+1) = ub;
    end
    
    function add_not(obj,var,not_var)
        if nargin < 3
            assert(isa(var,'char'),'first argument must be a name');
            not_var = [obj.not_prefix var];
        end
        obj.add_ineq([1 1],{var,not_var},'=',1);
        if obj.continuous_nots
            obj.add_var(not_var,'c',0,1);
        end
    end
    
    function [mip] = compile(obj,mip)
        obj.vars = map(@to_names,obj.vars);
        obj.ind_id = map(@to_names,obj.ind_id);
        obj.ind_row = map(@(x) to_names(x,mip.rownames),obj.ind_row);
        obj.bound_var = map(@to_names,obj.bound_var);
        obj.bound_ind = map(@to_names,obj.bound_ind);
        
        % create the variables
        all_names = unique(flatten({obj.vars, obj.ind_id, ...
                                    obj.bound_var, obj.bound_ind},2));
        new_names = setdiff(all_names,mip.varnames);
        mip = add_column(mip,new_names,obj.default_vartype, ...
                         obj.default_lb,obj.default_ub);
        [~,loc] = ismember(obj.varnames,mip.varnames);
        for i = 1 : length(loc)
            mip.vartypes(loc(i)) = obj.vartypes(i);
            mip.lb(loc(i)) = obj.lb(i);
            mip.ub(loc(i)) = obj.ub(i);
        end
        
        % add the constraints
        Ncon = length(obj.coefs);
        m = size(mip.A,1);
        mip = add_row(mip,Ncon);
        for i = 1 : Ncon
            idxs = convert_ids(mip.varnames,obj.vars{i},'index');
            mip.A(m+i,idxs) = obj.coefs{i};
            mip.ctypes(m+i) = obj.ctype(i);
            mip.b(m+i) = obj.rhs(i);
        end
        
        % add the indicators
        idxs = convert_ids(mip.rownames,obj.ind_row,'index');
        ind_idxs = convert_ids(mip.varnames,obj.ind_id,'index');
        for i = 1 : length(idxs)
            mip.ind(idxs(i)) = ind_idxs(i);
            mip.indtypes(idxs(i)) = obj.indtype(i);
        end
        
        % add the binding constraints
        var_idxs = convert_ids(mip.varnames,obj.bound_var,'index');
        ind_idxs = convert_ids(mip.varnames,obj.bound_ind,'index');
        mip.bounds.var = [mip.bounds.var; var_idxs(:)];
        mip.bounds.ind = [mip.bounds.ind; ind_idxs(:)];
        mip.bounds.type = [mip.bounds.type; obj.bound_type(:)];
        
        function [names] = to_names(ids,full_names)
            if nargin < 2
                full_names = mip.varnames;
            end
            if isa(ids,'double')
                names = convert_ids(full_names,ids,'name');
            else
                names = ids;
            end
        end
    end
end
end
