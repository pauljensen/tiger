% COBRA_MODEL_EXTENDED  Test model in COBRA format

%             1  2  3  4  5  6  7  8  9 10
cobra.S =  [ -1  0  0  0 -1  0  0  0  0  0;   % A
              0 -1  0 -1  0  0  0  0  0  0;   % C
              0  0 -1  0  0 -1  0  0  0  0;   % F
              0  0  0  0  1  1 -1  0  0  0;   % B
              0  0  0  1  0  0 -1 -1  0  0;   % D
              0  0  0  0  0  0  1  0 -1  0;   % E
              0  0  0  0  0  0  0  1  0 -1 ]; % G

cobra.lb = [ -1 -1 -1 -1 -1  0 -1  0  0 -1 ]';
cobra.ub = [  1  1  1  1  1  1  1  1  1  1 ]';

cobra.c  = [  0  0  0  0  0  0  0  0  1  0 ]';

[m,n] = size(cobra.S);

cobra.b = zeros(m,1);

cobra.rxns = array2names('r%i',1:n);
cobra.mets = {'A','C','F','B','D','E','G'}';

cobra.genes = {'g4','g5a','g5b', ...
               'g6','g7a','g7b','g8a','g8b'}';

cobra.grRules = {'';
                 '';
                 '';
                 'g4';
                 'g5a and g5b';
                 'g6';
                 'g7a and g7b';
                 'g8a or g8b';
                 '';
                 ''};

cobra.rules = convert_grRules(cobra);
cobra.rxnGeneMat = make_rxnGeneMat(cobra);

clear m n
