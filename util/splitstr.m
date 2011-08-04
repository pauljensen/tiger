function [parts] = splitstr(str,regex)
% SPLITSTR  Perl-style string splitting
%
%   [PARTS] = SPLITSTR(STR,REGEX) splits STR by the regular expression
%   REGEX, returning the remaining sections as PARTS.

parts = regexp(str,regex,'split');
