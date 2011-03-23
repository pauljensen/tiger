
prev = cd;
cd('~/work');

m2html('mfiles','tiger','htmldir','tiger/doc/m2html', ...
       'recursive','on','global','on')

cd(prev);