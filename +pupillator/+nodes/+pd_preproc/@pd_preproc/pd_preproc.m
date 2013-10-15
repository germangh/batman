classdef pd_preproc < meegpipe.node.abstract_node
    % PD_PREPROC - Pre-processing of pupil diameter traces
    %
    % See also: pupillator
    
    methods (Static, Access = private)
       h = plot_before(data, xCal, yCal);
       captions =overlay_after(data, h, blockEvs, xCal, yCal);
    end
    
    methods
        
        [data, dataNew] = process(obj, data)
        
    end
    
    % Constructor
    methods
        
        function obj = pd_preproc(varargin)
            import pset.selector.*;
            
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % Copy constructor
                return;
            end
            
            
            if isempty(get_data_selector(obj));
                % By default process only the PD traces.
                mySel1 = sensor_class('Class', 'pupillometry');
                %mySel2 = sensor_label('diameter');
                set_data_selector(obj, mySel1);
            end
            
            
            if isempty(get_name(obj)),
                obj = set_name(obj, 'pd_preproc');
            end
            
        end
        
    end
    
    
end