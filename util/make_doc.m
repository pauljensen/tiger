
prev = cd;
cd('~/work');

m2html('mfiles','tiger','htmldir','tiger/doc', ...
       'recursive','on','global','on')

cd(prev);