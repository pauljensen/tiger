function [mip] = prepare_mip(mip)

if ~issparse(mip.A)
    mip.A = sparse(mip.A);
end

if isfield(mip,'sense') && isa(mip.sense,'char')
    switch mip.sense
        case {'max','maximize'}
            mip.sense = -1;
        otherwise
            mip.sense = 1;
    end
elseif ~isfield(mip,'sense') || isempty(mip.sense)
    mip.sense = 1;
end

if ~isfield(mip,'options') || isempty(mip.options)
    mip.options = cmpi.get_options();
end

% preserve size before conversion
mip.param.pre_mip_N = size(mip.A,2);

mip = cmpi.convert_var_bindings(mip);
mip = cmpi.convert_indicators(mip);

mip.param.qp = ~isempty(cmpi.miqp_type(mip));

if mip.param.qp
    mip = cmpi.convert_miqp(mip);
end

mip.param.prepared = true;
