function S = make_validated_struct(inputs,required_names,defaults)
% names is a cell array of fieldnames that must be in the final struct
% fieldvals can be either:
%   - a single struct
%   - a cell array of {'field1',value1,'field2',value2,...}

S = struct(inputs{:});

isin = isfield(S,required_names);
if ~all(isin)
    error('TIGER:StructValid:NameNotFound', ...
          ['The following fieldnames are required: ', ...
           strjoin(required_names(~isin),', ')]);
end

for i = 1 : 2 : length(defaults)
    if ~isfield(S,defaults{i})
        S.(defaults{i}) = defaults{i+1};
    end
end
