load yeast_trn_model

base_closed = close_bounds(base,bounds);
base_mets = add_rule(base_closed,met_rules);

y = add_rule(base_mets,{'o2[e] or not ROX1 <=> HAP1', ...
                        'o2[e] and HAP1 <=> ROX1', ...
                        '"EX_o2(e)" < -0.24338 <=> high_o2', ...
                        'glc[e] and HAP1 and (not ROX1 or high_o2)) <=> YHR007C'});
                    
fba(y)