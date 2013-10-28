function myPipe = arsq_analysis(varargin)
% arsq_analysis - Extract ARSQ durations
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
myImporter = physioset.import.mff;
myNode = physioset_import.new('Importer', myImporter);

nodeList = [nodeList {myNode}];

%% Note: Extract ARSQ durations

myPipe = pipeline.new(...
    'Name',             'batman-arsq', ...
    'NodeList',         nodeList, ...
    'Save',             true, ...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Queue',            QUEUE, ...
    varargin{:});


end