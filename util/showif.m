function showif(tf,fmt,varargin)
% SHOWIF  Conditionally display to the command window
%
%   SHOWIF(TF,FMT,...) prints the PRINTF format string FMT if TF is true.
%   It is silent otherwise.  Additional arguments are passed to FPRITNF.

if tf
    fprintf(fmt,varargin{:});
end
