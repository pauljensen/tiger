function [data] = scanfile(filename,format,varargin)

fid = fopen(filename);
data = textscan(fid,format,varargin{:});
fclose(fid);

