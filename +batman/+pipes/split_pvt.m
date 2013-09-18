function myPipe = split_pvt(varargin)
% split_pvt - Split RS epochs using PVT events
%
% See also: batman.pipes

import meegpipe.node.*;

% Default options
USE_OGE     = true;
DO_REPORT   = true;
QUEUE       = 'long.q@somerenserver.herseninstituut.knaw.nl';


nodeList = {};

%% Node: import from .mff file

myImporter = physioset.import.mff('Precision', 'double');
myNode = meegpipe.node.physioset_import.new('Importer', myImporter);

nodeList = [nodeList {myNode}];


%%  Node: Extract resting state blocks using PVT events

namingPolicyRS = @(d, ev, idx) batman.preproc.naming_policy(d, ev, idx, 'rs');

offset      = 0;
duration    = 5*60;
mySel       = batman.preproc.pvt_selector;

thisNode = meegpipe.node.split.new(...
    'EventSelector',        mySel, ...
    'Offset',               offset, ...
    'Duration',             duration, ...
    'SplitNamingPolicy',    namingPolicyRS);

nodeList = [nodeList {thisNode}];

%% The actual pipeline

myPipe = meegpipe.node.pipeline.new(...
    'NodeList',         nodeList, ...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Save',             false, ...
    'Name',             'split_pvt', ...
    'Queue',            QUEUE);

end