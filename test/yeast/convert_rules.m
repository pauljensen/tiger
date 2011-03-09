
load yeast_raw_rules.mat
load yeast_aliases.mat

N = length(yeast_raw_rules);
if_rules  = cell(N,1);
iff_rules = cell(N,1);
for i = 1 : N
    pred = yeast_raw_rules{i,2};
    if_rules{i}  = [pred(3:end)  ' => ' yeast_raw_rules{i,1}];
    iff_rules{i} = [pred(3:end) ' <=> ' yeast_raw_rules{i,1}];
end

if_exprs  = cellfun(@parse_string, if_rules,'Uniform',false);
iff_exprs = cellfun(@parse_string,iff_rules,'Uniform',false);

disp('starting')
cellfun(@(x) apply_aliases(x,yeast_aliases), if_exprs);
disp('half done')
cellfun(@(x) apply_aliases(x,yeast_aliases),iff_exprs);

