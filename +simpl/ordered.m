function [varargout] = ordered(varargin)
% sorts a variable number of arguments into descending order

orders = cellfun(@order,varargin);
[~,idx] = sort(orders,2,'descend');
varargout = varargin(idx);
