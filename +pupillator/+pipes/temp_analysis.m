function myPipe = temp_analysis(varargin)
% TEMP_ANALYSIS - Extraction of temperature features

import meegpipe.node.*;
import pupillator.nodes.*;
import physioset.event.class_selector;
import physioset.event.value_selector;
import physioset.event.cascade_selector;
import pset.selector.event_selector;

USE_OGE = true;
DO_REPORT = true;

nodeList = {};

% Data importer
myImporter = physioset.import.edfplus(...
     'MetaMapper', @(data) pupillator.meta_mapper(data)); 
myNode = physioset_import.new('Importer', myImporter);
nodeList = [nodeList {myNode}];

% Generate events marking the boundaries between experimental conditions
myEventGenerator = pupillator.block_events_generator;
myNode = ev_gen.new('EventGenerator', myEventGenerator);
nodeList = [nodeList {myNode}];

% Calibrate the Temp channels
myNode = operator.new(...
    'Operator',         @(x) pupillator.temp.calibrate_temp(x), ...
    'DataSelector',     pset.selector.sensor_label('^Temp'), ...
    'Name',             'temp-calib');
nodeList = [nodeList {myNode}];

% Temperature feature list
featNames = {...
    'block', ...
    'block_number_1_21', ...
    'block_number_1_7', ...
    'temp_indexfinger',  ...
    'temp_forearm' ...
    };


featList = {...
    @(data, ev, sel) strrep(get(ev, 'Type'), 'block_', ''), ...
    @(data, ev, sel) get(ev, 'Value'), ...
    @(data, ev, sel) get_meta(ev, 'Block_1_7'), ...    
    @(data, ev, sel) mean(data(1,:)), ...
    @(data, ev, sel) mean(data(2,:)) ...
    };

% Each of these nodes will select one of the 21 blocks. Then it will
% extract the PD features for that block only.
for nodeItr = 1:21   
    
    mySel = {...
        event_selector(value_selector(nodeItr)); ...
        };
  
    myNode = generic_features.new(...
        'TargetSelector',   mySel, ... 
        'DataSelector',     pset.selector.sensor_label('^Temp'), ...
        'FirstLevel',       featList, ...
        'FeatureNames',     featNames, ...
        'Name',             ['block-' num2str(nodeItr)] ...
        );
    
    nodeList = [nodeList {myNode}]; %#ok<AGROW>
end


myPipe = pipeline.new(...
    'Name',             'pupillator-temp', ...
    'NodeList',         nodeList, ...
    'Save',             true, ...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    varargin{:});


end