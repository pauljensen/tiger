classdef Parameter
    properties
        name
    end
    
    properties (Access = private)
        value
    end
    
    methods
        function obj = Parameter(name)
            obj.name = name;
            obj.value = ['SIMPL_PARAMETER(''' obj.name ''')'];
        end
        
        function dbl = double(obj)
            try
                dbl = evalin('caller',obj.value);
            catch ME
                if regexp(ME.message, ...
                          'Undefined function ''SIMPL_PARAMETER')
                    % no hash in caller space
                    error('SIMPL:Parameter:NoMap', ...
                          ['Map SIMPL_PARAMETER must be defined ' ...
                           'to evaluate parameters.']);
                elseif strcmp(ME.identifier, 'MATLAB:Containers:Map:NoKey')
                    % undefined parameter
                    error('SIMPL:Parameter:Undefined', ...
                          ['Undefined parameter: ' obj.name]);
                else
                    rethrow(ME);
                end
            end
        end
        
        function string = num2str(obj)
            string = obj.value;
        end
        
        function param = plus(a,b)
            param = simpl.Parameter.makefun('plus',a,b);
        end
        
        function param = minus(a,b)
            param = simpl.Parameter.makefun('minus',a,b);
        end
        
        function param = uminus(a)
            param = simpl.Parameter.makefun('uminus',a);
        end
        
        % =============== display functions ===============
        function str = toString(obj)
            str = obj.value;
        end
        
        function disp(obj)
            simpl.defaultDisplay(obj);
        end
    end 
    
    methods (Static)
        function obj = anonymous(expstr)
            persistent namegen
            if isempty(namegen)
                namegen = RandomNameGenerator('PARAMx',99999);
            end
            obj = simpl.Parameter(getName(namegen));
            obj.value = expstr;
        end
        
        function obj = makefun(f,a,b)
            if nargin == 1
                string = [f '()'];
            elseif nargin == 2
                string = [f '(' num2str(a) ')'];
            elseif nargin == 3
                string = [f '(' num2str(a) ',' num2str(b) ')'];
            end
            obj = simpl.Parameter.anonymous(string);
        end
    end
end
    