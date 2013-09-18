function myPipe = split_rs_ars(varargin)
% split_rs_ars - Split RS epochs using ars+ events
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

%% Node: Extract resting state blocks using ars+ events

namingPolicyRS = @(d, ev, idx) batman.preproc.naming_policy(d, ev, idx, 'rs');

offset      = 0;
duration    = 5*60;
mySel       = physioset.event.class_selector('Type', 'ars\+');

thisNode = meegpipe.node.split.new(...
    'EventSelector',        mySel, ...
    'Offset',               offset, ...
    'Duration',             duration, ...
    'SplitNamingPolicy',    namingPolicyRS);

nodeList = [nodeList {thisNode}];


%% The actual pipelines

myPipe = meegpipe.node.pipeline.new(...
    'NodeList',         nodeList, ...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Save',             false, ...
    'Name',             'split_rs_ars', ...
    'Queue',            QUEUE, ...
    varargin{:});

end