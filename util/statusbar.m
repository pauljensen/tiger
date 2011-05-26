classdef statusbar < handle
    
properties
    N
    width = 80;
    n = 0;
    
    show_N = true;
    show_percent = true;
    show_elapsed_time = false;
    show_estimated_time = false;
    
    n_before_estimate = 3;
    
    start_tic = [];
    
    margin = ' ';
    barchar = '=';
    
    reprint = false;
    display = true;
    
    update_every = 1;
    last_update = 0;
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
        
        obj.start_tic = tic;

        if nargin < 2 || isempty(msg)
            fprintf('\n');
        else
            fprintf('\n%s:\n',msg);
        end
        
        obj.update(0);
    end
    
    function update(obj,n)
        if ~obj.display ...
              || ((n - obj.last_update) < obj.update_every && n > 0)
            return;
        end

        obj.last_update = n;
        
        bar = obj.getbar(n);
        timebar = obj.get_timebar(n);
        
        if ~obj.reprint && n > 0
            if ~isempty(timebar)
                fprintf(repmat('\b',1,length(timebar)+1));
            end
            fprintf(repmat('\b',1,length(bar)));
        end
        
        if obj.reprint
            fprintf('\n');
        end
        fprintf('%s',bar);
        
        if ~isempty(timebar)
            fprintf('\n%s',timebar);
        end
        
        
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
    
    function [bar] = get_timebar(obj,n)
        bar1 = '';
        bar2 = '';
        
        if obj.show_elapsed_time
            bar1 = sprintf('Elapsed time: %s', ...
                           statusbar.make_timestr(toc(obj.start_tic)));
        end
        
        if obj.show_estimated_time
            if n < obj.n_before_estimate
                timestr = '--:--:--';
            else
                elapsed = toc(obj.start_tic);
                estimate = (obj.N - n) * elapsed / n + (n < obj.N);
                timestr = statusbar.make_timestr(estimate);
            end
            
            bar2 = sprintf('Remaining time: %s',timestr);
        end
        
        if isempty(bar1) && isempty(bar2)
            bar = '';
        elseif isempty(bar1)
            bar = bar2;
        elseif isempty(bar2)
            bar = bar1;
        else
            bar = [bar1 '  ' bar2];
        end
        
        if ~isempty(bar)
            lpad = floor((obj.width - length(bar)) / 2);
            bar = [repmat(' ',1,lpad) bar];
        end
    end
end

methods (Static)
    function test(pause_length)
        if nargin == 0
            pause_length = 0.1;
        end
        
        N = 100;
        s = statusbar(N);
        s.start('Testing statusbar');
        for i = 1 : N
            s.update(i);
            pause(pause_length);
        end
    end
    
    function [timestr] = make_timestr(seconds)
        timestr = datestr(datevec(num2str(seconds),'SS'),'HH:MM:SS');
    end
end

end
        