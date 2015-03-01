%% GPR Conversions
%
%% Structure of the GPR
% GPR (Gene-Protein-Reaction) relationships are logical rules that connect
% the gene expression state with a reaction's ability to carry flux.
% For enhanced GPR conversion in version 1.4+, TIGER assumes the following
% about the GPR rules:
%
% # All genes are binary variables.
% # Rules contain only 'or' ('|') or 'and' ('&') operators.
% # The Cobra field grRules is present.
% 
% If any of these assumptions are not true, set the 'method' parameter to
% 'v1.3' to use the version 1.3 GPR encoding method.
%
%% Converting Simple GPRs
%
% For enhanced conversion, a _simple_ rule takes one of the following
% forms:
% 
%  Or Junctions
%  ------------
%  1.  x1 | x2 | ... | xk => I
%  2.  I => x1 | x2 | ... | xk
%  3.  x1 | x2 | ... | xk <=> I
%
%  And Junctions
%  -------------
%  4.  x1 & x2 & ... & xk => I
%  5.  I => x1 & x2 & ... & xk
%  6.  x1 & x2 & ... & xk <=> I
%
% These rules can be converted into equivalent mixed-integer linear 
% inequalities as follows:
%
% # $$ I \ge \frac{1}{k} \sum_{i=1}^k x_i $$
% # $$ I \le \sum_{i=1}^k x_i $$
% # (1) and (2)
% # $$ \sum_{i=1}^k x_i \le I + k - 1 $$
% # $$ I \le \frac{1}{k}\sum_{i=1}^k x_i $$
% # (4) and (5)
%
% Only equations (1) and (5) are mixed integer, while the rest are purely
% binary integer programs.  Rather than produce a mixed integer program,
% equation (1) can be replaced with the set of inequalities
% $I \ge x_i \quad \forall i \in \{1 \ldots k\}$.  Similarly, we can 
% replace (5) with the inequalities 
% $I \le x_i \quad \forall i \in \{1 \ldots k\}$.  The parameter
% 'conversion' can be set to either 'compact' to use equations (1) and (5),
% or 'simple' to use the equivalent set of inequalities.
%
%% Complex GPRs
%
% GPR rules that do not match one of the simple forms can be reduced to a
% set of simple GPRs by substituting non-atomic operands with an indicator
% variable.  For example, the rule
%
%  x | (y & z) => w
%
% can be converted into the following two simple rules:
%
%  x | I => w
%  I <=> y & z
%
% The above simplification applies to any logical rules.  However, for
% GPRs, we can relax the implication in the second from from
% 'if-and-only-if' to 'if' without changing the function of the model.  GPR
% rules bind a reaction index variable to a set of genes.  When the GPR is
% not satisfied, the reaction index is zero, and the corresponding reaction
% flux must also be zero.  However, if a reaction does not carry flux, it
% is not necessarily true that the corresponding genes are 'off' (not
% expressed).  We do not need to enforce that if the reaction index is
% zero, the the corresponding genes must be off.
%
% By default, TIGER 1.4 used 'if' implications to simplify rules.  The 'if'
% format reduces the size and complexity of the model and improves
% runtimes.  However, setting the 'substitution' parameter to 'tight' will
% force TIGER to use the 'if-and-only-if' bindings.  The tighter bindings
% may be useful for algorithms that strongly couple reaction flux to the
% reaction index variables.
%
%% Coupling to fluxes
%
% As mentioned previously, TIGER uses _reaction index variables_ to couple
% the GPR logic to the reaction flux.  The reaction indexes are named
% 'RXN__name', where "name" is the reaction name.  (Note that there are two
% underscores between 'RXN' and 'name'.)  The flux is coupling between a
% reaction index $R$ and a reaction flux $v$ with lower and upper bounds $l$
% and $u$ is achieve with the inequalities
%
% $$lR \le v \le uR$$
%
% Reaction index variables are created for each reaction during GPR
% conversion, with two exceptions.
%
% # Reactions with out GPRs are uncoupled.
% # Reactions with GPRs containing only a single gene do not receive an
% index variable.  The variable for the gene is used as the reaction index.
%
% To force TIGER to create an index for every reaction, set the 'index'
% parameter to 'all'.  This feature is available for algorithms that use
% the reaction index variables directly.
