classdef event_selector < physioset.event.selector

    
    methods
        function [evArray, idx] = select(~, allEvents)
            
            evSel = physioset.event.class_selector('Type', 'PVT');
            
            [evArray, idx] = select(evSel, allEvents);
            
            % Find the nearest (in the past) non-PVT events, which should
            % tell in which block the PVT event is located
            nonPVT = allEvents(setdiff(1:numel(allEvents), idx));
            nonPVTSample = get_sample(nonPVT);
            PVTSample = get_sample(evArray);
            for i = 1:numel(evArray)
                blockEvIdx = find(nonPVTSample < PVTSample(i), 1, 'last');
                if isempty(blockEvIdx), continue; end
                blockEv    = nonPVT(blockEvIdx);
                meta = get_meta(blockEv);
                if ~isempty(meta),
                    evArray(i) = set_meta(evArray(i), meta);
                end
                blockID = get(blockEv, 'Type');
                evArray(i) = set_meta(evArray(i), ...
                    'block', regexprep(blockID, '^block_', ''));
            end
        end
        
        function obj = not(obj)
            warning('Method not() is not implemented!');
        end
        
    end
    
    
    
end