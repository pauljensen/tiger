function [tiger] = add_constraint(tiger,linalgs,varargin)

assert(nargin >= 2, 'ADD_CONSTRAINT requires at least two inputs.');

% if there is no starting model, start with a blank model
if isempty(tiger)
    tiger = create_empty_tiger();
end

% check that a TIGER model was given (and convert if COBRA)
tiger = assert_tiger(tiger);

linalgs = assert_cell(linalgs);
Nrows = length(linalgs);

Nprev = size(tiger.A,1);
tiger = add_row(tiger,Nrows);

for i = 1 : Nrows
    roff = Nprev + i;
    [tf,loc] = ismember(linalgs{i}.vars,tiger.varnames);
    
    if any(~tf)
        tiger = add_column(tiger,linalgs{i}.vars(~tf));
    end
    
    tiger.A(roff,loc) = linalgs{i}.coefs;
    tiger.ctypes(roff) = linalgs{i}.op;
    tiger.b(roff) = linalgs{i}.rhs;
end
