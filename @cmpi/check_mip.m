function [mip] = check_mip(mip)
% CHECK_MIP  Ensure that the sense, ind, and indtypes fields are filled
%
%   [MIP] = CHECK_MIP(MIP)
%
%   Checks that the fields 'sense', 'ind', and 'indtypes' fields exist 
%   and are the correct size.  Returns the valided MIP.

m = size(mip.A,1);

set_if_not_field('sense',1);
set_if_not_field('ind',zeros(m,1));
set_if_not_field('indtypes',repmat(' ',m,1));
set_if_not_field('options',[]);

if length(mip.ind) < m
    mip.ind = expand_to(mip.ind,m);
end
if length(mip.indtypes) < m
    mip.indtypes = fill_to(mip.ind,m,' ');
end

function set_if_not_field(name,val)
    if ~isfield(mip,name)
        mip.(name) = val;
    end
end

end