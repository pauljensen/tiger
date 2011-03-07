classdef textframe < handle
% TEXTFRAME  Format and pad multi-line text blocks
%
%   TEXTFRAME formats a set of uneven-lengthed strings into blocks
%   of text with vertical and horizontal alignment.  TEXTFRAMEs can
%   be easily combined with other TEXTFRAMEs using the VCAT and HCAT
%   methods.
    
properties
    lines         % cells of text lines
    SPACER = ' '  % character used to pad lines during formatting
end

properties (Dependent)
    width   % width of the longest line
    widths  % width of each individual line
    height  % number of lines
end

methods
    function [obj] = textframe(lines)
        % TEXTFRAME  Construct a TEXTFRAME
        %
        %   [OBJ] = TEXTFRAME(LINES)
        %
        %   Create a TEXTFRAME object.  LINES is an optional cell
        %   array of strings.
        
        if nargin == 0
            lines = {};
        end
        obj.lines = lines(:);
    end
    
    function display(obj)
        % DISPLAY  Display a TEXTFRAME
        %
        %   Displays a TEXTFRAME using default height and width.
        
        display_block = repmat(' ',obj.height,obj.width);
        lines = obj.make_block();
        for i = 1 : obj.height
            display_block(i,:) = lines.lines{i};
        end
        disp(display_block);
    end
    
    % ------- dependent access methods -------
    function [widths] = get.widths(obj)
        widths = cellfun(@length,obj.lines);
    end
    
    function [width] = get.width(obj)
        width = max(obj.widths);
    end
    
    function [height] = get.height(obj)
        height = length(obj.lines);
    end
    
    
    function [block] = make_block(obj,varargin)
        % MAKE_BLOCK  Create a TEXTFRAME with alignment padding
        %
        %   [BLOCK] = MAKE_BLOCK(...params...)
        %
        %   Parameters
        %   'height'    Height (number of lines).
        %   'width'     Width (number of characters).
        %   'halign'    Horizontal alignment.  Lines should be aligned
        %               on the 'left' (default), 'right', or 'center' of
        %               the block.
        %   'valign'    Vertical alignment.  Lines should be aligned on
        %               the 'top' (default), 'bottom', or 'middle' of
        %               the block.
        
        p = inputParser;
        p.addParamValue('height',obj.height);
        p.addParamValue('width',obj.width);
        p.addParamValue('halign','left');
        p.addParamValue('valign','top');
        
        p.parse(varargin{:});
        width = p.Results.width;
        height = p.Results.height;
        halign = p.Results.halign;
        valign = p.Results.valign;
        
        if any(obj.widths > width)
            warning('Some lines will be clipped horizontally.');
        end
        if obj.height > height
            warning('Some lines will be clipped vertically.');
            block = obj.lines(1:height);
        else
            block = obj.lines;
            if obj.height < height
                nulls = arrayfun(@(x) '',1:(height-obj.height), ...
                                 'Uniform',false)';
                switch valign
                    case {'top','t'}
                        block = [block; nulls];
                    case {'bottom','b'}
                        block = [nulls; block];
                    case {'middle','m'}
                        cut = length(nulls)/2 + 0.1;
                        block = [nulls(1:floor(cut)); ...
                                 block; ...
                                 nulls(ceil(cut):end)];
                end
            end
        end
        
        for i = 1 : height
            if length(block{i}) > width
                block{i} = block{i}(1:width);
            elseif length(block{i}) < width
                spacer = repmat(obj.SPACER,1,width - length(block{i}));
                switch halign
                    case {'left','l'}
                        block{i} = [block{i} spacer];
                    case {'right','r'}
                        block{i} = [spacer block{i}];
                    case {'center','c'}
                        cut = length(spacer)/2 + 0.1;
                        block{i} = [spacer(1:floor(cut)), ...
                                    block{i}, ...
                                    spacer(ceil(cut):end)];
                end
            end
        end
        
        block = textframe(block);
    end
    
    function [newtf] = hcat2(frame1,frame2,varargin)
        % HCAT2  Horizontally concatenate two TEXTFRAMES
        %
        %   [NEWTF] = HCAT2(FRAME1,FRAME2,...params...)
        %
        %   Horizontally pad and concatenate two TEXTFRAMEs and return
        %   the resulting textframe.  This is an auxiliary function
        %   called by HCAT.
        
        p = inputParser;
        p.addParamValue('height',max([frame1.height,frame2.height]));
        p.addParamValue('spacer', '');
        p.addParamValue('valign','top');
        
        p.parse(varargin{:});
        
        args = {'height',p.Results.height, ...
                'valign',p.Results.valign};
        f1 = frame1.make_block(args{:});
        f2 = frame2.make_block(args{:});
        
        newtf = f1.copy;
        for i = 1 : f1.height
            newtf.lines{i} = [f1.lines{i} p.Results.spacer f2.lines{i}];
        end
    end
    
    function [newtf] = hcat(varargin)
        % HCAT  Horizontally concatenate a series of TEXTFRAMEs
        %
        %   [NEWTF] = HCAT(FRAME1,FRAME2,...,...params...)
        %
        %   Align and concatenate a series of TEXTFRAMEs.  Parameters
        %   are the same as for MAKE_BLOCK.
        
        % separate the textframes from the parameter list
        is_tf = cellfun(@(x) isa(x,'textframe'),varargin);
        tfs = varargin(is_tf);
        args = varargin(~is_tf);
        
        newtf = tfs{1}.copy;
        for i = 2 : length(tfs)
            newtf = newtf.hcat2(tfs{i},args{:});
        end
    end
    
    function [newtf] = vcat(varargin)
        % VCAT  Vertically concatenate a series of TEXTFRAMEs
        %
        %   [NEWTF] = VCAT(FRAME1,FRAME2,...)
        %
        %   Vertically concatenate a series of TEXTFRAME objects.
        %   No alignment is applied; lines are simply added together.
        
        newtf = varargin{1}.copy;
        for i = 2 : length(varargin)
            newtf.lines = [newtf.lines; varargin{i}.lines];
        end
    end
    
    function [new] = copy(obj)
        % COPY  Create a duplicate TEXTFRAME object.
        %
        %   COPY duplicates a TEXTFRAME object with a separate
        %   handle.  This avoids links from simple copies.
        
        new = textframe(obj.lines);
    end
            
    function add_line(obj,fmt,varargin)
        % ADD_LINE  Add a string to a textframe.
        %
        %   ADD_LINE(FMT,...)
        %
        %   Adds a line to the end of a TEXTFRAME.  FMT is a
        %   PRINTF-style format string, with optional arguments.
        
        obj.lines{end+1,1} = sprintf(fmt,varargin{:});
    end
        
end

end % classdef

            
            