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

% Node: Compute ERP for the PVT stimuli. We are not actually interested in
% the ERP but this node will produce a log file with the characteristics of
% all the PVT events (which is what we actually want). By setting the
% duration of the ERP to 0 we tell the node that the ERP figures should not
% be generated. 
evSelector = batman.event_selector; 
thisNode = erp.new(...
    'EventSelector',    evSelector, ...
    'Duration',         0, ...
    'Name',             'pvt-erp');
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