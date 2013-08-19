classdef pvt_selector < physioset.event.abstract_selector
    % pvt_selector - Selects the first PVT occurrence in each block
    %
    % See also: batman
    
    properties
        
        MinBlockDistance  = 5*60*1000; % In samples
        EventType = {'^stm\+$', '^DIN4$'};
        Negated   = false;
        
    end
    
    % Consistency checks
    methods
        
        function obj = set.MinBlockDistance(obj, value)
            
            import exceptions.*;

            if isempty(value),
                obj.MinBlockDistance = 5*60*1000;
                return;
            end
            
            if numel(value) ~= 1 || value < 0,
                throw(InvalidPropValue('MinBlockDistance', ...
                    'Must be a positive scalar'));
            end
            
            obj.MinBlockDistance = value;
            
        end
        
        function obj = set.EventType(obj, value)
            
            import exceptions.*;
            import misc.join;
            
            
            if ~iscell(value), value = {value}; end
            
            isString = cellfun(@(x) misc.isstring(x), value);
            
            if ~all(isString),
                throw(InvalidPropValue('EventType', ...
                    'Must be a cell array of strings'));
            end
            
            obj.EventType = value;
            
            
            if isempty(obj.Name),
                
                % Name is based on the types of selected events
                name = join('_', value);
                obj = set_name(obj, name);
                
            end
            
        end
        
        function obj = set.Negated(obj, value)
            import exceptions.*;
            
            if numel(value) ~= 1 || ~islogical(value),
                throw(InvalidPropValue('Negated', ...
                    'Must be a logical scalar'));
            end
            obj.Negated = value;
            
        end
    end
    
    % selector interface
    methods
        
        function obj = not(obj)
            
            obj.Negated = ~obj.Negated;
            
        end
        
        function [evArray, idx] = select(obj, evArray)
            
            selected = true(size(evArray));
            
            % Select only events of the right type
            if isempty(obj.EventType),
                
                thisSelected = true(size(selected));
                
            else
                
                thisSelected = false(size(selected));
                for i = 1:numel(obj.EventType),
                    regex = obj.EventType{i};
                    af = @(x) ~isempty(regexp(get(x, 'Type'), regex, 'once'));
                    
                    thisSelected = thisSelected | arrayfun(af, evArray);
                end
                
            end
            
            selected = selected & thisSelected;            
           
            % Distance between events            
            sampl = get_sample(evArray(selected));
            dist  = diff(sampl);
           
            thisSelected = [true;dist(:) > obj.MinBlockDistance];            
         
            idxSelected = find(selected);
            selected(idxSelected(~thisSelected)) = false;            
            
            if obj.Negated,
                selected = ~selected;
            end
            
            evArray = evArray(selected);
            
            idx = find(selected);
        end
        
    end
    
    % Constructor
    methods
        
        function obj = pvt_selector(varargin)
            
            import misc.process_arguments;
            
            obj = obj@physioset.event.abstract_selector(varargin{:});
            
            if nargin < 1, return; end
            
            opt.MinBlockDistance = 5*60*1000;
            opt.EventType  = {'^ars\+$'};
            
            [~, opt] = process_arguments(opt, varargin);
            
            obj.MinBlockDistance = opt.MinBlockDistance;
            obj.EventType  = opt.EventType;
            
        end
        
    end
    
    
end