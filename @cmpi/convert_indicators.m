function [mip] = convert_indicators(mip)
% CONVERT_INDICATORS  Convert indicators to MILP constraints
%
%   [MIP] = CONVERT_INDICATORS(MIP)
%
%   Converts the indicators indentified by the 'ind' and 'indtypes' fields
%   to MILP constraints.  The constraints generated depend on the 
%   indicator types:
%       'p'  Ax (<=/=/>=) b  => I = 1  becomes  Ax + s (<=/=/>=) b
%                                               I + s >= IND_EPS
%
%       'b'  Ax (<=/=/>=) b <=> I = 1  becomes  Ax + s (<=/=/>=) b
%                                               I + s >= IND_EPS
%                                               s_lb*(1-I) <= s
%                                               s <= s_ub*(1-I)
%
%   The function adds a slack variable s to each constraint that is tied 
%   to an indicator and either 1 or 3 constraints per indicator, depending
%   on if the indicator was a positive ('p') or bound ('b') indicator.
%
%   The CMPI setting IND_EPS is used to construct one of the constraints
%   for each indicator.

IND_EPS = cmpi.get_ind_eps();

idx_p = find((mip.ind > 0) & (mip.indtypes == 'p'));
idx_b = find((mip.ind > 0) & (mip.indtypes == 'b'));

np = length(idx_p);
nb = length(idx_b);
N = np + nb;

[m,n] = size(mip.A);

i = [idx_b idx_p];
j = [1:nb 1:np];
s = ones(1,N);
IA = sparse(i,j,s,m,N,N);

s_ub = zeros(1,N);
s_lb = zeros(1,N);

for k = 1 : N
    Aup = mip.A(i(k),:) .* ub;
    Adn = mip.A(i(k),:) .* lb;
    
    s_ub(k) = sum(max(Aup,Adn));
    s_lb(k) = sum(min(Aup,Adn));
end
mip = add_column(mip,[],'c',s_lb,s_ub,[],IA);

mip = add_row(mip,np+3*nb);
roff = n;
for k = 1 : N
    roff = roff + 1;
    mip.A(roff,[mip.ind(i(k)) k]) = [1 1];
    mip.b(roff) = IND_EPS;
    mip.ctypes(roff) = '>';
end

for k = 1 : nb
    roff = roff + 1;
    mip.A(roff,[mip.ind(idx_b(k)) k]) = [1 s_lb(k)];
    mip.b(roff) = s_lb(k);
    mip.ctypes(roff) = '>';
    
    roff = roff + 1;
    mip.A(roff,[mip.ind(idx_b(k)) k]) = [1 s_ub(k)];
    mip.b(roff) = s_ub(k);
    mip.ctypes(roff) = '<';
end
