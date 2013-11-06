function myPipe = abp_analysis(varargin)
% ABP_ANALYSIS - ABP feature extraction pipeline
%
% See also: batman.pipes

import meegpipe.node.*;
import physioset.event.class_selector;
import pset.selector.sensor_label;

%% Default pipeline options

USE_OGE     = true; 
DO_REPORT   = true;
QUEUE       = 'long.q@somerenserver.herseninstituut.knaw.nl';

nodeList = {};

%% Node: data import
myImporter = physioset.import.physioset('Precision', 'double');
myNode = physioset_import.new('Importer', myImporter);

nodeList = [nodeList {myNode}];

%% Note: ECG annotation using ecgpuwave + HRV feature extraction
mySel = sensor_label('Portapres');
myNode = abp.new('DataSelector', mySel);
nodeList = [nodeList {myNode}];


myPipe = pipeline.new(...
    'Name',             'batman-abp', ...
    'NodeList',         nodeList, ...
    'Save',             false, ...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Queue',            QUEUE, ...
    varargin{:});


end