function [qtype] = miqp_type(mip)

if isfield(mip,'Q') && ~isempty(mip.Q) && ~all(mip.Q(:) == 0)
    qtype = 'Q';
elseif isfield(mip,'Qd') && ~isempty(mip.Qd)
    qtype = 'Qd';
elseif isfield(mip,'Qc') && ~isempty(mip.Qc)
    qtype = 'Qc';
else
    qtype = [];
end
