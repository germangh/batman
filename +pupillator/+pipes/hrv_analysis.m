function myPipe = hrv_analysis(varargin)
% HRV_ANALYSIS - Extraction of heart rate variability features

import meegpipe.node.*;
import physioset.event.class_selector;
import pset.selector.event_selector;
import physioset.event.value_selector;

USE_OGE = true;
DO_REPORT = true;

nodeList = {};

%% Node: Data importer
myImporter = physioset.import.edfplus(...
    'MetaMapper', @(data) pupillator.meta_mapper(data)); 
myNode = physioset_import.new('Importer', myImporter);
nodeList = [nodeList {myNode}];

%% Node: QRS detection
myNode = qrs_detect.new;
nodeList = [nodeList {myNode}];

%% Node: Generate events marking the experimental conditions boundaries
myEventGenerator = pupillator.block_events_generator;
myNode = ev_gen.new('EventGenerator', myEventGenerator);
nodeList = [nodeList {myNode}];

%% Node: ECG annotation
% Annotate the ECG lead (detect R-peaks) and compute the HRV features
% separately for each experimental block

evFeatNames = {...
    'block', ...
    'block_number_1_21', ...
    'block_number_1_7' ...
    };

evFeat ={...
    @(ev) strrep(get(ev(1), 'Type'), 'block_', ''), ...
    @(ev) get(ev(1), 'Value'), ...
    @(ev) get_meta(ev(1), 'Block_1_7') ...
    };

mySel = cellfun(@(x) value_selector(x), num2cell(1:21), 'UniformOutput', false);

myNode = ecg_annotate.new(...
    'EventSelector',   mySel, ...
    'EventFeatures',   evFeat, ...
    'EventFeatureNames', evFeatNames);

nodeList = [nodeList {myNode}];

myPipe = pipeline.new(...
    'Name',             'pupillator-hrv', ...
    'NodeList',         nodeList, ...
    'Save',             false, ...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    varargin{:});


end