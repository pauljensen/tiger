classdef TigerModel
    properties
        compounds
        reactions
    end
    
    methods
        function addExchangeReaction(obj,localizedCompound)
            if iscell(localizedCompound)
                cellfun(@(x) addExchangeReaction(obj,x), localizedCompound);
                return
            end
            equation = [' <=> (1) ' localizedCompound];
            name = ['EX_' localizedCompound];
            obj.reactions(name) = Reaction('id',name,'equation',equation);
        end
        
        function cpd = findCompound(obj,localizedCompound)
            cpdName = regexpref(localizedCompound,'\[.*\]$');
            cpd = values(obj.compounds,cpdName);
        end
        
        function cpds = getCompounds(obj,location)
            locals = uniqueflatmap('localizedCompounds',values(obj.reactions));
            cpds = find_like(['\[' location '\]$'], locals);
        end
    end
    
end
