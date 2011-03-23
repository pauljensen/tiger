
%          r1 r2 r3 r4 r5
cobra.S = [ 1 -1  0  0  0;  % A
            0  1  0 -1  0;  % B
            0  0  1 -1  0;  % C
            0  0  0  1 -1]; % D

cobra.c = [ 0  0  0  0  1]';
cobra.lb = -10*ones(size(cobra.c));
cobra.ub =  10*ones(size(cobra.c));

cobra.b = zeros(size(cobra.S,1),1);
        
cobra.rxns = {'rxn1';'rxn2';'rxn3';'rxn4';'rxn5'};
cobra.mets = {'A';'B';'C';'D'};

cobra.genes = {'AB1';'AB2';'BCD1';'BCD2'};
cobra.grRules = {'';'AB1 or AB2';'';'BCD1 and BCD2';''};
