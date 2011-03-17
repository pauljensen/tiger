
init_test

%%
% IFF tests

tiger = create_empty_tiger();

rules = {'a & b <=> c';
         'c | d <=> f'};
     
tiger = add_rule(tiger,rules,'default_ub',3);

t = set_var(tiger,'b',3);
t = set_fieldval(t,'obj','c',1);
sol = fba(t);
assert(near(sol.val,3),'multi iff and1');

t = set_var(tiger,'b',2);
t = set_fieldval(t,'obj','c',1);
sol = fba(t);
assert(near(sol.val,2),'multi iff and2');

t = set_var(tiger,'c',1);
t = set_fieldval(t,'obj','f',1);
sol = fba(t);
assert(near(sol.val,3),'multi iff or1');

t = set_var(tiger,{'c','d'},1);
t = set_fieldval(t,'obj','f',1);
sol = fba(t);
assert(near(sol.val,1),'multi iff or2');

%%
% IF tests

tiger = create_empty_tiger();

rules = {'a & b => c';
         'c | d => f'};
     
tiger = add_rule(tiger,rules,'default_ub',3);

t = set_var(tiger,'b',3);
t = set_fieldval(t,'obj','c',1);
sol = fba(t);
assert(near(sol.val,3),'multi if and1');

t = set_var(tiger,'b',2);
t = set_fieldval(t,'obj','c',1);
sol = fba(t);
assert(near(sol.val,2),'multi if and2');

t = set_var(tiger,'c',1);
t = set_fieldval(t,'obj','f',1);
sol = fba(t);
assert(near(sol.val,3),'multi if or1');

t = set_var(tiger,{'c','d'},1);
t = set_fieldval(t,'obj','f',1);
sol = fba(t);
assert(near(sol.val,1),'multi if or2');

