function [val] = iif(test,val1,val2,lazy)
% IIF  Inline operator form of the IF structure
%
%   [VAL] = IIF(TEST,VAL1,VAL2)
%
%   If TEST is true, VAL = VAL1.  Otherwise, VAL = VAL2.  If no value is
%   given for VAL2, the default is [].

if nargin < 4
    lazy = false;
end

if nargin == 2
    val2 = [];
end

if nargin < 2
    error('at least two inputs required');
end

if test
    if lazy
        val = eval(val1);
    else
        val = val1;
    end
else
    if lazy
        val = eval(val2);
    else
        val = val2;
    end
end
