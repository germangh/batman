function myPipe = pvt(varargin)
% pvt - PVT analysis pipeline

import meegpipe.node.*;
import misc.process_arguments;
import misc.split_arguments;

% Default pipeline parameters, can be overriden by varargin
PIPE_NAME = 'pvt';
USE_OGE   = true;
DO_REPORT = true;
QUEUE     = 'short.q@somerenserver.herseninstituut.knaw.nl';

nodeList = {};

% Node: Merge data files from stage2
myImporter = physioset.import.physioset;
thisNode = physioset_import.new('Importer', myImporter);
nodeList = [nodeList {thisNode}];

% Node: Extract event features
evSelector = batman.event_selector; 
featList = {'Time', 'Sample', 'cel', 'obs', 'rsp', 'rtim', 'trl'};
thisNode = ev_features.new(...
    'EventSelector',    evSelector, ...
    'Features',         featList);
nodeList = [nodeList {thisNode}];


% The actual pipeline
myPipe = pipeline.new(...
    'NodeList',         nodeList, ...
    'Save',             true,  ...
    'GenerateReport',   DO_REPORT, ...
    'Name',             PIPE_NAME, ...
    'OGE',              USE_OGE, ...
    'Queue',            QUEUE, ...
    varargin{:});


end