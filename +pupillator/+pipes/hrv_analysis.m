function myPipe = hrv_analysis(varargin)
% HRV_ANALYSIS - Extraction of heart rate variability features

import meegpipe.node.*;
import physioset.event.class_selector;

USE_OGE = true;
DO_REPORT = true;

nodeList = {};

% Data importer
myNode = physioset_import.new('Importer', physioset.import.edfplus);
nodeList = [nodeList {myNode}];

% Generate events marking the boundaries between experimental conditions
myEventGenerator = pupillator.block_events_generator;
myNode = ev_gen.new('EventGenerator', myEventGenerator);
nodeList = [nodeList {myNode}];

% Get HRV features for each block
blockNames = {...
    'block_dark-pre-7', ...
    'block_dark-pre-pvt-6', ...
    'block_dark-pre-5', ...
    'block_dark-pre-4', ...
    'block_dark-pre-pvt-3', ...
    'block_dark-pre-2', ...
    'block_dark-pre-1', ...
    'block_dark-pre-pvt', ...
    'block_dark-pre', ...
    'block_red', ...
    'block_red-pvt', ...
    'block_red', ...
    'block_dark', ...
    'block_dark-pvt', ...
    'block_dark', ...
    'block_blue', ...
    'block_blue-pvt', ...
    'block_blue', ...
    'block_dark-post', ...
    'block_dark-post-pvt', ...
    'block_dark-post-1', ...
    'block_dark-post-2', ...
    'block_dark-post-pvt-3', ...
    'block_dark-post-4', ...
    'block_dark-post-5', ...
    'block_dark-post-pvt-6', ...
    'block_dark-post-7' ...
    };

mySel = cellfun(@(x) physioset.event.class_selector('Type', ['^' x '$'], 'Name', ...
    regexprep(x, '^block_', '')), blockNames, 'UniformOutput', false);

% Annotate the ECG lead (detect R-peaks) and compute the HRV features
% separtely for each experimental block
myNode = ecg_annotate.new('EventSelector',   mySel);
nodeList = [nodeList {myNode}];

myPipe = pipeline.new(...
    'Name',             'pupillator-hrv', ...
    'NodeList',         nodeList, ...
    'Save',             true, ...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    varargin{:});


end