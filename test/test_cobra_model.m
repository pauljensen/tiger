
model.mets = { 'A', 'B', 'C', 'D' }';
model.metNames = model.mets;

model.rxns = { 'EX_A', 'left', 'right', 'obj', 'EX_C', 'CtoD', 'EX_D' }';
model.rxnNames = model.rxns;

model.S = [-1  -1  -1   0   0   0   0 
            0   1   1  -1   0   0   0
            0   0   0   0  -1  -1   0
            0   0   0   0   0   1  -1];
model.b = [0; 0; 0; 0];
        
model.c = [0 0 0 1 0 0 0]';

model.lb  = [-10  0   0 -10 -10 -10 -10]';
model.ub  = [ 10 10  10  10  10  10  10]';
model.rev = [  1  0   0   1   1   1   1]';

model.genes = {
    'transA'
    'lefty'
    'righty1'
    'righty2A'
    'righty2B'
    'cd'
};

model.grRules = {
    'transA'
    'lefty'
    'righty1 or (righty2A and righty2B)'
    ''
    ''
    'cd'
    ''
};

model.rules = {
    'x(1)'
    'x(2)'
    'x(3) | (x(4) & x(5))'
    ''
    ''
    'x(6)'
    ''
};


model.subSystems = {
    'main'
    'main'
    'main'
    'main'
    'side'
    'side'
    'side'
};






