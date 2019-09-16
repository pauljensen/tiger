# MADE: Metabolic Adjustment by Differential Expression

## Frequently Asked Questions

*   [What type of data do I need to run MADE?](#data)
*   [Can I use different models for each condition?](#model_conditions)
*   [Why is MADE taking a long time to run?](#runtime)
*   [Which MILP solver do you recommend?](#solver)
*   [MADE reports that "at least one of the models does not meet the minimum objective". What does this mean, and how can I fix it?](#minimum_obj)
*   [Can I convert a model returned by MADE into a model for the COBRA Toolbox?](#cobra)

<div class="article1" id="data">

## What type of data do I need to run MADE?

MADE can be used with any expression data (gene or protein) taken from two or more conditions. The conditions can be a control and experimental group, a series of timepoints, or any other set of data.</div>

<div class="article1" id="model_conditions">

## Can I use different models for each condition?

Yes. Prior to TIGER version 1.2, MADE allowed users to specify different lower bounds, upper bounds, and objectives for each condition. Additionally, version 1.2 allows users to input a cell of models for each condition. These models can be different sizes (allowing users to only include condition-specific constraints), although only genes that are found in every model will be fit with MADE -- the other variables are left unconstrained. Version 1.2 can still be used by specifying bounds and an objective for each condition for backwards compatibility.</div>

<div class="article1" id="runtime">

## Why is MADE taking a long time to run?

Our experience is that some models lead to mixed-integer programs that require long solution times. The runtime of a model is difficult to predict from the number of constraints or variables in the model; runtimes can vary widely between models of comparable size. Often times MADE finds a near optimal solution quickly but spends a long time proving the optimality. The user can set a maximum solution time with the <tt>set_solver_options</tt> command. For example,

<tt>set_solver_options('MaxTime',1000);</tt>

will cause MADE to return the best solution found in 1000 seconds.

</div>

<div class="article1" id="solver">

## Which MILP solver do you recommend?

We recommend either the CPLEX or Gurobi solvers for MADE problems (both are freely available for academic use). In our experience, GLPK does not perform well on these problems, returning either infeasible or non-optimal solutions when other solvers work fine. We have had one report of a MADE problem being declared as infeasible by Gurobi by later solved by CPLEX. So, if you have a problem with one of the solvers, it may be worthwhile to try another.</div>

<div class="article1" id="minimum_obj">

## MADE reports that "at least one of the models does not meet the minimum objective". What does this mean, and how can I fix it?

MADE allows the user to set a fraction of the maximum objective flux that must be achieved by each model; this requirement is enforced simultaneously with the expression data integration. However, numerical issues can arrise that cause the resulting models to not be functional -- this is usually do to "leaks" in the integer variables.

MILPs use the "Big-M" formulation to link binary and continuous variables. If we know that the product of gene <tt>G</tt> catalyzes a reaction with flux <tt>v</tt>, we enforce this constraint with the expression

<tt>v <= ub*G</tt>

where "ub" is the maximum flux through the continuous variable <tt>v</tt> (0 <= <tt>v</tt> <= <tt>ub</tt>), and <tt>G</tt> is a binary indicator variable for gene expression. When <tt>G</tt> equals zero, <tt>v</tt> cannot carry flux, since <tt>v</tt> <= <tt>ub</tt>*0\. When <tt>G</tt> is one, <tt>v</tt> <= <tt>ub</tt>*1, which allows <tt>v</tt> to carry flux.

Due to precision errors during the solution process, binary variables are sometimes assigned values that differ very slightly from 0 and 1\. For example, if <tt>ub</tt> = 1000 and G was assigned the value 1e-5, then the Big-M expression would read

<tt>v <= (1000)*(1e-5) = 0.01</tt>

In this case, v is allowed to carry a very small flux due to numerical issues while the reactions should actually be turned "off". In some models, these tiny "leaks" allow a model to function when essential genes are turned off. Later, when MADE is checking the solution, if the numerical error does not appear, the model will not be able to function, resulting in the above error message.

This is a well-known issue in MILP problems, and there are three solutions:

1.  Reduce the integrality tolerance for the solver with the <tt>IntFeasTol</tt> parameter. If <tt>IntFeasTol</tt> = 1e-10, then all integer variables must be within 1e-10 of an integer. Since version 1.0.1, MADE automatically reduces this parameter.
2.  Find tighter bounds for reactions in the model. As shown above, large upper and lower bounds on a reaction magnify the size of integer leaks. For reactions with very low average fluxes, reducting the bounds to more reasonable values can help.
3.  Manually correct problem reactions. MADE-generated models are not functional because an essential gene is removed. The leaked reaction can be identified by comparing the flux vector from the MADE solution (return in the "variables" field of the MADE solution structure) with the known upper bound on the reaction in the condition-specific model.

</div>

<div class="article1" id="cobra">

## Can I convert a model returned by MADE into a model for the COBRA Toolbox?

The models returned by MADE for the TIGER toolbox enforce the gene states by setting the upper bounds on the gene variables to zero for removed genes. This is different from the COBRA strategy, where the GPR's for each reaction are evaluated, and the flux bounds on the reactions are changed. If you use <tt>extract_cobra</tt> on a MADE-derived model to remove the MILP constraints representing the GPR, you lose the effects of removing genes in the model. To create a condition-specific COBRA model, use the COBRA function <tt>deleteModelGenes</tt> to remove genes turned off by MADE (genes with zero in the gene states matrix).</div>
