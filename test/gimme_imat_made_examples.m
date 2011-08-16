% This file contains examples for Figure 5 of the TIGER manuscript.


%%
% GIMME

clear all;
cmpi.init();

cobra_model_extended;
tiger = cobra_to_tiger(cobra);

express = [ 13;   % g4
             6;   % g5a
            12;   % g5b
             2;   % g6
            18;   % g7a
             6;   % g7b
             2;   % g8a
             4 ]; % g8b

thresh = 10;

[states,genes,sol] = gimme(tiger,express,thresh)

%%
% iMAT

clear all;
cmpi.init();

cobra_model_extended;

levels = [ 1;   % g4
           0;   % g5a
           0;   % g5b
           2;   % g6
           2;   % g7a
           2;   % g7b
           1;   % g8a
           2 ]; % g8b

[levels,gene,sol,tiger] = imat(cobra,levels)


%%
% MADE

clear all;
cmpi.init();

cobra_model_extended;
tiger = cobra_to_tiger(cobra);

fold_change = [ 2.1  3.0  0.7;   % g4
                0.5  8.0  0.8;   % g5a
                1.1  0.1  2.2;   % g5b
                3.6  1.6  0.4;   % g6
                1.4  4.2  1.8;   % g7a
                2.3  0.4  0.3;   % g7b
                1.3  7.3  0.2;   % g8a
                0.9  4.1  0.1 ]; % g8b

p_values = [ 0.68  0.08  0.15;   % g4
             0.45  0.44  0.22;   % g5a
             0.07  0.49  0.03;   % g5b
             0.05  0.22  0.48;   % g6
             0.38  0.40  0.43;   % g7a
             0.04  0.19  0.12;   % g7b
             0.40  0.21  0.45;   % g8a
             0.89  0.13  0.28 ]; % g8b

T = [ 0 1 0;
      0 0 2;
      3 0 0 ];

made_sol = made(tiger,fold_change,p_values,'transition_matrix',T);
show_made_results(made_sol,'all');


