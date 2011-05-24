classdef statusbar < handle
    
properties
    N
    width = 80;
    n = 0;
    show_N = true;
    show_percent = true;
    margin = '  ';
    barchar = '=';
    reprint = false;
    display = true;
end

methods
    function [obj] = statusbar(Ntotal,display)
        obj.N = Ntotal;
        
        if nargin == 2
            obj.display = display;
        end
    end
    
    function start(obj,msg)
        if ~obj.display
            return;
        end
        
        if nargin < 2 || isempty(msg)
            fprintf('\n%s',obj.getbar(0));
        else
            fprintf('\n%s:\n%s',msg,obj.getbar(0));
        end
    end
    
    function update(obj,n)
        if ~obj.display
            return;
        end
        
        bar = obj.getbar(n);
        if obj.reprint
            fprintf('\n');
        else
            fprintf(repmat('\b',1,length(bar)));
        end
        fprintf('%s',bar);
        
        if n >= obj.N
            fprintf('\n');
        end
    end
    
    function [bar] = getbar(obj,n)
        trailer = '';
        frac = n / obj.N;
        
        if obj.show_N
            Nlen = length(sprintf('%i',obj.N));
            trailer = sprintf(' %*i/%*i',Nlen,n,Nlen,obj.N);
        end
        if obj.show_percent
            trailer = sprintf('%s (%5.1f%%)',trailer,frac*100);
        end
        
        barwidth = obj.width - 2*length(obj.margin) - length(trailer) - 2;
        filled = ceil(frac*barwidth);
        if filled == barwidth && n == obj.N
            indbar = repmat(obj.barchar,1,barwidth);
        elseif filled == 0
            indbar = ['>' repmat(' ',1,barwidth - 1)];
        else
            indbar = [repmat(obj.barchar,1,filled-1) '>' ...
                      repmat(' ',1,barwidth - filled)];
        end
        
        bar = [obj.margin '[' indbar ']' trailer obj.margin];
    end
end

end
        