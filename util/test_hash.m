h = hash();

c.a = 'hello';
c.b = 'world';

h.keys = {'a','b',122};
h.vals = {1, 2, c};

h{'a'}