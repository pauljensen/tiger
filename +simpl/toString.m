function str = toString(x)

if ~isa(x,'numeric')
    error('SIMPL:toString:conversion', ...
          ['no toString method for class ' class(x)]);
end

str = num2str(x);
