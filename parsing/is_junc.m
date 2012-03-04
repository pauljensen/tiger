function [tf] = is_junc(e)

tf = strcmp(e.op,'and') || strcmp(e.op,'or');
