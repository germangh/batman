function myPipe = temp_in_epochs(varargin)
% TEMP_IN_EPOCHS - Average temp values in correlative data epochs

import meegpipe.node.*;
import physioset.event.class_selector;
import pset.selector.event_selector;
import physioset.event.value_selector;

USE_OGE   = true;
DO_REPORT = true;

nodeList = {};

%% NODE: Data importer

% The raw data files (in .mff format) have been previously splitted into
% single sub-block files in .pseth format.

% Use AutoDestroyMemMap because the data files can be quite huge 
myImporter = physioset.import.physioset('AutoDestroyMemMap', true);

myNode = physioset_import.new('Importer', myImporter);
nodeList = [nodeList {myNode}];

%% NODE: Create a subset of the data that contains only the temp channels

% We prefer to do this instead of using simple selections because the data
% files are quite large and it pays off to release as much VM as possible
% as soon as possible
tempSelector = pset.selector.sensor_class('Type', 'temp');
myNode = subset.new('DataSelector', tempSelector);
nodeList = [nodeList {myNode}];

%% NODE: Event generation (specification of data epochs)

% We want to extract average temp values in correlative epochs of 1 min of
% and 50 seconds of overlap between correlative epochs
myEvGen = physioset.event.periodic_generator(...
    'Period',   60, ... % A new event (epoch) every 10 seconds
    'Duration', 60, ... % Each epoch lasts for 60 seconds
    'Type',     '__TempEpoch');

myNode = ev_gen.new('EventGenerator', myEvGen);

nodeList = [nodeList {myNode}];

%% NODE: Extract basic features

% * Average temp value in every data epoch at all sensor locations

% At most there are 9 epochs within a subblock (in the baseline block)
% Each selector will produce a row of the features table
selector = cell(9, 1);
for i = 1:9
    selector{i} = event_selector(value_selector(i));
end

% List of extracted features for each epoch
% epoch_idx, chan_1, chan_2, chan_3, ..., chan_12
featList  = cell(16, 1);

featNames = cell(16, 1);
featNames(1:4) = ...
    {...
    'epoch_idx'; ...
    'epoch_onset_abs_time'; ...
    'epoch_onset_in_seconds'; ...
    'epoch_dur_in_seconds'...
    };

featList(1:4) = {...
    @(x, ev, sel) get(ev, 'Value'); ...
    @(x, ev, sel) datestr(get_abs_sampling_time(x, 1)); ...
    @(x, ev, sel) round(get_sampling_time(x, 1)); ...
    @(x, ev, sel) round(size(x,2)/x.SamplingRate) ...
    };

for i = 1:12
    featNames{i+4} = sprintf('chan%d', i);
    featList{i+4} = @(x, ev, sel) mean(x(i,:));
end

myNode = generic_features.new(...
    'TargetSelector',   selector, ...
    'FirstLevel',       featList, ...
    'FeatureNames',     featNames, ...
    'DataSelector',     tempSelector, ...
    'Name',             'temp_in_epochs' ...
    );

nodeList = [nodeList {myNode}];

%% The pipeline

myPipe = pipeline.new(...
    'Name',             'temp_in_epochs', ...
    'NodeList',         nodeList, ...
    'Save',             true, ...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    varargin{:});


end