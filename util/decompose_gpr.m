function decompose_gpr(cobra)

byg = sum(cobra.rxnGeneMat,1);
byr = sum(cobra.rxnGeneMat,2);

[nr,ng] = size(cobra.rxnGeneMat);

none = count(byr == 0);
fprintf('No GPR:   %i / %i (%.1f%%)\n',none,nr,none/nr*100);

one = count(byr == 1);
fprintf('One ORF:  %i / %i (%.1f%%)\n',one,nr,one/nr*100);

promis = count(byg > 1);
fprintf('2+ rxns:  %i / %i (%.1f%%)\n',promis,ng,promis/ng*100);

and_cnt = cellfun(@(x) length(regexp(x,'&')),cobra.rules);
 or_cnt = cellfun(@(x) length(regexp(x,'\|')),cobra.rules);

fprintf('Isozymes:  %i\n',sum(or_cnt));
fprintf('Subunits:  %i\n',sum(and_cnt));
