function myPipe = pvt_analysis(varargin)
% PVT_ANALYSIS - Extraction of PVT features (reaction times)

import meegpipe.node.*;
import pupillator.nodes.*;
import physioset.event.class_selector;
import physioset.event.value_selector;
import physioset.event.cascade_selector;
import pset.selector.event_selector;
import pupillator.private.*;

USE_OGE = true;
DO_REPORT = true;

MAX_PVT   = 990;
MIN_PVT   = 100;
PVT_LAPSE = 355; % in ms, after this it will be considered a lapse


nodeList = {};

% Data importer
myNode = physioset_import.new('Importer', physioset.import.pupillator);
nodeList = [nodeList {myNode}];

% Extract PVT features
%
% * Mean PVT response time within a block
% * Std of PVT response time within a block
% * Median PVT response time within a block
% * Same as three above but without lapses
% * Number of PVT misses

firstLevel = { ...
    @(feats, ev, sel) strrep(get(ev(1), 'Type'), 'block_', ''), ...
    @(feats, ev, sel) get(ev(1), 'Value'), ...
    @(feats, ev, sel) get_meta(ev(1), 'Block_1_7'), ...
    @(d, ev, sel) pvt_stat(d, MAX_PVT, MIN_PVT, @(x) mean(x)), ...
    @(d, ev, sel) pvt_stat(d, MAX_PVT, MIN_PVT, @(x) std(x)), ...
    @(d, ev, sel) pvt_stat(d, MAX_PVT, MIN_PVT, @(x) median(x)), ...
    @(d, ev, sel) pvt_stat(d, PVT_LAPSE, MIN_PVT, @(x) mean(x)), ...
    @(d, ev, sel) pvt_stat(d, PVT_LAPSE, MIN_PVT, @(x) std(x)), ...
    @(d, ev, sel) pvt_stat(d, PVT_LAPSE, MIN_PVT, @(x) median(x)), ...
    @(d, ev, sel) pvt_stat(d, MAX_PVT, MIN_PVT, @(x) mean(1000./x)), ...
    @(d, ev, sel) pvt_stat(d, MAX_PVT, MIN_PVT, @(x) std(1000./x)), ...
    @(d, ev, sel) pvt_stat(d, MAX_PVT, MIN_PVT, @(x) median(1000./x)), ...
    @(d, ev, sel) pvt_stat(d, PVT_LAPSE, MIN_PVT, @(x) mean(1000./x)), ...
    @(d, ev, sel) pvt_stat(d, PVT_LAPSE, MIN_PVT, @(x) std(1000./x)), ...
    @(d, ev, sel) pvt_stat(d, PVT_LAPSE, MIN_PVT, @(x) median(1000./x)), ...
    @(d, ev, sel) pvt_nb_lapses(d, PVT_LAPSE) ...
    };
    
featNames = {...
    'block', ...
    'block_number_1_21', ...
    'block_number_1_7', ...
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


for nodeItr = 1:21   
    
    mySel = {...
        event_selector(value_selector(nodeItr)) ...
        };    
    
    myNode = generic_features.new(...
        'TargetSelector',   mySel, ...
        'FirstLevel',       firstLevel, ...
        'SecondLevel',      [], ...
        'FeatureNames',     featNames, ...
        'DataSelector',     pset.selector.sensor_label('diameter'), ...
        'Name',             ['Block ' num2str(nodeItr)] ...
        );

    
    nodeList = [nodeList {myNode}]; %#ok<AGROW>
end


myPipe = pipeline.new(...
    'Name',             'pupillator-pvt', ...
    'NodeList',         nodeList, ...
    'Save',             true, ...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    varargin{:});


end