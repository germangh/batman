function myPipe = pvt_analysis_psvu(varargin)
% PVT_ANALYSIS_PSVU - Extracton of PVT features (reaction times) from psvu

import misc.split_arguments;
import misc.process_arguments;

opt.MaxPVT = 990;
opt.MinPVT = 100;
opt.Lapse  = 355;

[thisArgs, varargin] = split_arguments(opt, varargin);
[~, opt] = process_arguments(opt, thisArgs);

% Initialize the list of pipeline nodes
nodeList = {};

%% Node 1: data importer
% Use a node to import the pupillator .csv files into a meegpipe physioset
% object (the data structure used by the meegpipe toolbox)

% This importer object knows how to read pupillator csv files
myImporter = physioset.import.pupillator;

% We pass the importer above to the constructor of a physioset_import node
% so that the created node will know how to read pupillator's csv files.
% The node will then generate a physioset object with the contents of the
% file.
myNode = meegpipe.node.physioset_import.new('Importer', myImporter);
nodeList = [nodeList {myNode}];

%% Node 2: Extract raw PVT response times

% For this we will use an ev_features node. This class of nodes are able to
% extract selected properties from a set of events. The first thing we need
% to specify is the set of events (from all the events in the physioset)
% from which the features should be extracted. To select a set of events
% you need an appropriate "event selector" object:
evSelector = pupillator.pvt.event_selector;

% Now we need to specify the list of features that we want to extract from
% every event. The list of features is just a list of event properties that
% we want to be extracted from the physioset object:
featList = {'Sample', 'Time', 'Value', 'Block_1_5', 'block'};

% Now we can create the node
thisNode = meegpipe.node.ev_features.new(...
    'EventSelector', evSelector, ...
    'Features',      featList);
nodeList = [nodeList {thisNode}];

%% Node 3: Extract PVT aggregate features 

% The purpose of this node is to extract:
%
% * Mean PVT response time within a block
% * Std of PVT response time within a block
% * Median PVT response time within a block
% * Same as three above but without lapses
% * Number of PVT misses
 
% For this task we will use a generic_features node. The generic_features
% node is quite flexible and because of that it needs quite a bit of tuning
% to make it do what we want. First we need to define the names of the
% aggregated features (aka statistics) that we want to extract from our PVT
% events:
featNames = {...
    'block', ...
    'block_number_1_15', ...
    'block_number_1_5', ...
    'PVTmean', ...
    'PVTstd', ...
    'PVTmed', ...
    'PVTmeanNoLapse', ...
    'PVTstdNoLapse', ...
    'PVTmedNoLapse', ...   
    'SpeedMean', ...
    'SpeedStd', ...
    'SpeedMed', ...
    'SpeedMeanNoLapse', ...
    'SpeedStdNoLapse', ...
    'SpeedMedNoLapse', ...
    'PVTmiss', ...
    };

% Now we have to define how the features/statistics above are computed from
% the PVT events. We do this by using function handles (one-line functions)
% to tell how the corresponding feature is computed from:
%
% d   -> The physioset object that contains all pupillometry data
% ev  -> The array of relevant events (the events needed to compute the feature)
% sel -> The event selector that was used to pick ev from all the events in d

import pupillator.private.pvt_stat;
import pupillator.private.pvt_nb_lapses;
featDescriptors = { ...
    @(d, ev, sel) strrep(get(ev(1), 'Type'), 'block_', ''), ...
    @(d, ev, sel) get(ev(1), 'Value'), ...
    @(d, ev, sel) get_meta(ev(1), 'Block_1_5'), ...
    @(d, ev, sel) pvt_stat(d, opt.MaxPVT, opt.MinPVT, @(x) mean(x)), ...
    @(d, ev, sel) pvt_stat(d, opt.MaxPVT, opt.MinPVT, @(x) std(x)), ...
    @(d, ev, sel) pvt_stat(d, opt.MaxPVT, opt.MinPVT, @(x) median(x)), ...
    @(d, ev, sel) pvt_stat(d, opt.Lapse, opt.MinPVT, @(x) mean(x)), ...
    @(d, ev, sel) pvt_stat(d, opt.Lapse, opt.MinPVT, @(x) std(x)), ...
    @(d, ev, sel) pvt_stat(d, opt.Lapse, opt.MinPVT, @(x) median(x)), ...
    @(d, ev, sel) pvt_stat(d, opt.MaxPVT, opt.MinPVT, @(x) mean(1000./x)), ...
    @(d, ev, sel) pvt_stat(d, opt.MaxPVT, opt.MinPVT, @(x) std(1000./x)), ...
    @(d, ev, sel) pvt_stat(d, opt.MaxPVT, opt.MinPVT, @(x) median(1000./x)), ...
    @(d, ev, sel) pvt_stat(d, opt.Lapse, opt.MinPVT, @(x) mean(1000./x)), ...
    @(d, ev, sel) pvt_stat(d, opt.Lapse, opt.MinPVT, @(x) std(1000./x)), ...
    @(d, ev, sel) pvt_stat(d, opt.Lapse, opt.MinPVT, @(x) median(1000./x)), ...
    @(d, ev, sel) pvt_nb_lapses(d, opt.Lapse) ...
    };
 
% Because we are aggregating the features above within a block (i.e. we
% want mean PVT reaction times in every block) we need to build a series of
% blocks that will do the following:
% - Pick the events in block i
% - Compute the relevant features using the picked events
%
% Each of the 5 nodes created below will select one of the 5 experimental
% (sub-)blocks that contain PVT events. Then it will extract the list of
% features above for that (sub-)block only.
import physioset.event.value_selector;
import pset.selector.event_selector;
for blockItr = 2:3:15  
    
    % This is a "data selector" object that will make the node select only
    % that portion of your data that corresponds to the relevant block
    mySel = {...
        event_selector(value_selector(blockItr)) ...
        };      
    
    myNode = meegpipe.node.generic_features.new(...
        'TargetSelector',       mySel, ...
        'FeatureDescriptors',   featDescriptors, ...
        'FeatureNames',         featNames, ...
        'DataSelector',         pset.selector.sensor_label('diameter'), ...
        'Name',                 ['Block ' num2str(blockItr)] ...
        );
    
    nodeList = [nodeList {myNode}]; %#ok<AGROW>
end


%% Create the pipeline
myPipe = meegpipe.node.pipeline.new(...
    'Name',             'pupillator-pvt-psvu', ...
    'NodeList',         nodeList, ...
    'Save',             true, ...
    varargin{:});
