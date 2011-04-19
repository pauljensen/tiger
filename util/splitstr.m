function [substrs] = splitstr(str,regex)

substrs = regexp(str,regex,'split');
