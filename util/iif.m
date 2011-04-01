function [val] = iif(test,val1,val2)
% IIF  Inline operator form of the IF structure
%
%   [VAL] = IIF(TEST,VAL1,VAL2)
%
%   If TEST is true, VAL = VAL1.  Otherwise, VAL = VAL2.  If no value is
%   given for VAL2, the default is [].

if nargin == 2
    val2 = [];
end

if nargin < 2
    error('at least two inputs required');
end

if test
    val = val1;
else
    val = val2;
end
