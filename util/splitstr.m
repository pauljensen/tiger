function [parts] = splitstr(str,regex)

parts = regexp(str,regex,'split');
