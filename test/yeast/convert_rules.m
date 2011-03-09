
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

cellfun(@(x) apply_aliases(x,yeast_aliases), if_exprs);
cellfun(@(x) apply_aliases(x,yeast_aliases),iff_exprs);

tic; tiger_base = cobra_to_tiger(cobra); toc

tic; if_trn  = add_rule(tiger_base,if_exprs);  toc
tic; iff_trn = add_rule(tiger_base,iff_exprs); toc

yeast_if = bind_mets(if_trn);
yeast_if = bind_var(yeast_if,{'EX_glc(e)'},{'glc[e]'});
yeast_iff = bind_mets(iff_trn);
yeast_iff = bind_var(yeast_iff,{'EX_glc(e)'},{'glc[e]'});
