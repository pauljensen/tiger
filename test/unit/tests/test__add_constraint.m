
t = create_empty_tiger();
t = add_column(t,{'a','b','c'},'c',[0 0 -10],[10 10 5]);

l1 = linalg({{1,'a'},{1,'b'},{-1,'c'}},'<',0);
l2 = linalg({{1,'a'}},'>',3);
l3 = linalg({{1,'b'}},'>',3);

t1 = add_constraint(t,l1);
t2 = add_constraint(t1,l2);
t3 = add_constraint(t2,l3);

clear l1 l2 l3 t t1 t2 t3
