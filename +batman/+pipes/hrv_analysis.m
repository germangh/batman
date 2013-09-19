function myPipe = hrv_analysis(varargin)
% hrv_analysis - HRV feature extraction pipeline
%
% See also: batman.pipes

import meegpipe.node.*;
import physioset.event.class_selector;

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
myNode = ecg_annotate.new(...
    'VMUrl',            '192.87.10.186');
nodeList = [nodeList {myNode}];


myPipe = pipeline.new(...
    'Name',             'batman-hrv', ...
    'NodeList',         nodeList, ...
    'Save',             true, ...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Queue',            QUEUE, ...
    varargin{:});


end