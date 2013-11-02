function temp_explore(varargin)
% TEMP_EXPLORE - A simple exploratory pipeline for the temperature data

import meegpipe.node.*;
import physioset.event.class_selector;
import pset.selector.event_selector;

USE_OGE   = true;
DO_REPORT = true;

nodeList = {};

%% NODE: Data importer

% The raw data files (in .mff format) have been previously splitted into
% single sub-block files in .pseth format.

myNode = physioset_import.new('Importer', physioset.import.physioset);
nodeList = [nodeList {myNode}];

%% NODE: Event generation (specification of data epochs)

% We want to extract average temp values in correlative epochs of 1 min of
% and 50 seconds of overlap between correlative epochs
myEvGen = physioset.event.periodic_generator(...
    'Period',   10, ... % A new event (epoch) every 10 seconds
    'Duration', 60, ... % Each epoch lasts for 60 seconds
    'Type',     '__TempEpoch');

myNode = ev_gen.new('EventGenerator', myEvGen);


%% NODE: Extract basic features

% * Average temp value in every data epoch at all sensor locations



end