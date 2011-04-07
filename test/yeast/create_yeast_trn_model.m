function create_yeast_trn_model()

load ind750

[cobra,bounds] = open_bounds(cobra);

fid = fopen('aliases.csv');
aliases = textscan(fid,'%q%q','Delimiter',',','CollectOutput',true);
aliases = aliases{1};
fclose(fid);

fid = fopen('interactions.csv');
raw = textscan(fid,'%q%q%q%q','Delimiter',',','CollectOutput',true);
raw = raw{1};
fclose(fid);

fid = fopen('met_rules.csv');
met_rules = textscan(fid,'%s','Delimiter','$','CollectOutput',true);
met_rules = met_rules{1};
met_rules = met_rules(1:66);
fclose(fid);

orfs = unique(raw(:,1));
Norfs = length(orfs);
rules = cell(Norfs,1);
for i = 1 : Norfs
    [~,~,tf] = find_like(['^' orfs{i} '$'],raw(:,1));
    orf_rules = raw(tf,:);
    [~,~,tf] = cellfilter(@(x) x == 'A',orf_rules(:,4));
    actstr = combine_rules(orf_rules( tf,:));
    repstr = combine_rules(orf_rules(~tf,:));
    
    if ~isempty(actstr) && ~isempty(repstr)
        rules{i} = sprintf('(%s) or not(%s) <=> %s', ...
                           actstr,repstr,orfs{i});
    elseif ~isempty(actstr)
        rules{i} = sprintf('%s => %s',actstr,orfs{i});
    elseif ~isempty(repstr)
        rules{i} = sprintf('%s => not %s',repstr,orfs{i});
    else
        rules{i} = '';
    end
end
    
rules = cellfilter(@(x) ~isempty(x),rules);
rules{end+1} = 'HAP1 and ("EX_o2(e)" > -0.24338) => YPR065W';
rules{end+1} = 'etoh[e] <=> not o2[e]';

exprs = parse_string(rules);
celliter(@(x) apply_aliases(x,aliases),exprs);

tic
base = cobra_to_tiger(cobra);
toc
tic
base_rules = add_rule(base,exprs);
yeast_trn = add_rule(base_rules,met_rules);
toc

yeast_trn = close_bounds(yeast_trn,bounds);

save yeast_trn_model.mat base yeast_trn exprs met_rules rules bounds


function [str] = combine_rules(rules)
    is_na = @(x) strcmp(x,'NA');
    
    str = '';
    N = size(rules,1);
    for i = 1 : N
        tf  = rules{i,2};
        met = rules{i,3};
        if ~is_na(tf) && ~is_na(met)
            to_add = sprintf('("%s" & "%s")',tf,met);
        elseif ~is_na(tf)
            to_add = ['"' tf '"'];
        elseif ~is_na(met)
            to_add = ['"' met '"'];
        else
            to_add = '';
        end
        
        if ~isempty(to_add)
            if i > 1
                str = [str ' or ' to_add];
            else
                str = to_add;
            end
        end
    end
            
    