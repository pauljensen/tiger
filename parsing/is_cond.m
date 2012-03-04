function [tf] = is_cond(e)

tf = ismember(e.op,{'=','<','>','<=','>=','~='});
