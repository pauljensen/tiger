
tiger = create_empty_tiger();

rules = {'a & b => c';
         'c | d <=> ~f'};
     
tiger = add_rule(tiger,rules,'default_ub',3);
