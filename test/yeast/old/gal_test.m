
gal = add_growth_constraint(trn,0.13,'ctype','=','valtype','abs');
gal.lb(carbon_idxs) = 0;
gal.lb(425) = -100;

gal.obj(425) = 1;

sol = fba(gal)

%cmpi.show_mip(make_milp(gal))