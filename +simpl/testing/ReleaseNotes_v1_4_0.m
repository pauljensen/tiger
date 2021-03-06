%% TIGER Version 1.4.0 Release Notes
%
%
% TIGER v1.4.0 includes improvements to the gene-protein-reaction (GPR)
% conversion algorithm.  Previous TIGER versions used a custom 
% recursive-decent
% parser to translate the GPR rules into mixed-integer inequalities.  For
% very large GPR rules, MATLAB's internal recursion limit prevented the
% parser from completing the transformation.  Version 1.4's parser 
% overcomes these
% limitations and creates smaller, more efficient TIGER models.
%
%% Fast conversion of COBRA models with large GPRs.
%
% TIGER v1.4.0 can convert several large models that previously exhausted
% the MATLAB recursion limit, including the human metabolic models _Recon1_
% and _Recon2_.  Additionally, the conversion of COBRA models to TIGER
% models is over 16 times faster.
%
%% Smaller models with 3x faster solution times.
%
% The version 1.4 parser more aggressively collects terms in the GPR
% rules and includes enhancements in the rule-to-inequality conversion
% process.  The resulting TIGER models require fewer variables and
% constraints than version 1.3 models:
%
% <<benchmark.png>>
% 
% The smaller models solve faster in many applications.  Single gene
% deletion benchmarks with the iMO1086 model indicate an approximately
% 3-fold
% reduction in solution times.
%
%% Backward compatibility.
%
% The new parser is only available for GPR rules, and the version 1.3 
% parser is 
% used to convert non-GPR rules.  The older parser can
% also be enabled for the GPR conversion by building the TIGER model
% with
%
%  tiger = cobra_to_tiger(cobra,'add_gpr','v1.3');
%
%