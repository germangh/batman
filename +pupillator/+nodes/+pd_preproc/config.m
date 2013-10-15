classdef config < meegpipe.node.abstract_config
    % CONFIG - Configuration for node pd_preproc
    %   
    %
    % See also: pupillator.nodes
  
    properties
       
        % Add here as many configuration options as your node may have
        Filter = filter.lasip('Gamma', 8:0.2:11, ...
            'Scales', 2*ceil([3 1.45.^(4:16)]), ...
            'Decimation',40, 'Verbose', false)
        BlockSelector = physioset.event.class_selector('Type', '^block_');
        XCal    = 34.2;     % To map PD values to mm
        YCal    = 37.2;
        
    end
    
  
    % Constructor
    methods
        
        function obj = config(varargin)
           
            obj = obj@meegpipe.node.abstract_config(varargin{:});  
            
        end
        
    end
    
    
    
end