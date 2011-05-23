function [results] = old_average_by_subsystem(subSystems,data)

data = data(:);

sublists = mapcc( @(s) regexp(s, ';', 'split'), subSystems );

subsystems = {};
for i = 1 : length(sublists)
    for j = 1 : length(sublists{i})
        subsystems{end+1} = sublists{i}{j};
    end
end

subsystems = unique(subsystems);
not_null = mapcv( @(s) ~strcmpi(s, ''), subsystems );
subsystems = subsystems(logical(not_null));

results = zeros(size(subsystems));
for s = 1 : length(subsystems)
    xidx = false(1, length(sublists));
    for i = 1 : length(sublists)
        xidx(i) = ismember(subsystems{s}, sublists{i});
    end
    
    results(s) = mean(data(xidx(:) & isfinite(data)));
end
