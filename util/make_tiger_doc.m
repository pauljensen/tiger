
prev = cd;
cd('~/work');

m2html('mfiles','tiger','htmldir','tiger/doc/m2html', ...
       'recursive','on','global','on')

cd('~/work/tiger/util');
system(['perl add_categories.pl ../doc/m2html/index.html ' ...
        'categories.txt > ../doc/m2html/index2.html'])
system('mv ../doc/m2html/index2.html ../doc/m2html/index.html')
   
cd(prev);