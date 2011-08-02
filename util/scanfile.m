function [data] = scanfile(filename,format,varargin)
% SCANFILE  Apply TEXTSCAN to a filename
%
%   [DATA] = SCANFILE(FILENAME,FORMAT,...params...)
%
%   Uses TEXTSCAN to parse a file named FILENAME using the format string
%   FORMAT.  Additional parameters are passed to TEXTSCAN.  Returns the
%   TEXTSCAN structure.

fid = fopen(filename);
data = textscan(fid,format,varargin{:});
fclose(fid);

