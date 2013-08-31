% splitting
%
% Usage:
% batman.setup
% batman.preproc.splitting;
%
% Splitting the large .mff files that contain 14 blocks into 14
% single-block files.

import batman.get_username;
import batman.pending_files;

%% User parameters

% Subject 6 is special because the ars+ events are missing in that subject.
% Thus subject 6 must be split using stage1b.m
SUBJECTS_ARS = setdiff(1:10, 6);

% Group of subjects that will be split using the PVT events instead of the
% ars+ events
SUBJECTS_PVT = 6;

USE_OGE = true;

DO_REPORT = true;

OUTPUT_DIR = '/data1/projects/batman/analysis/splitting';
if ~strcmp(get_username, 'meegpipe')
    OUTPUT_DIR = [OUTPUT_DIR '_' get_username];
end

% Use long.q to not overload the server for a too long time
% The long.q has a lower load threshold than other queues
QUEUE = 'long.q@somerenserver.herseninstituut.knaw.nl';

PAUSE_PERIOD = 3*60; % Check for new input files every PAUSE_PERIOD seconds

%% Build the pipelines node by node

% We need two separate pipelines, one for those subjets with ars+ events
% and one for those having only PVT markers
nodeList1 = {};
nodeList2 = {};

%% Node: import from .mff file

myImporter = physioset.import.mff('Precision', 'double');
myNode = meegpipe.node.physioset_import.new('Importer', myImporter);

nodeList1 = [nodeList1 {myNode}];
nodeList2 = [nodeList2 {myNode}];

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

nodeList1 = [nodeList1 {thisNode}];

%%  Node: Extract resting state blocks using PVT events

offset      = 7*60;
duration    = 5*60;
mySel       = batman.preproc.pvt_selector;

thisNode = meegpipe.node.split.new(...
    'EventSelector',        mySel, ...
    'Offset',               offset, ...
    'Duration',             duration, ...
    'SplitNamingPolicy',    namingPolicyRS);

nodeList2 = [nodeList2 {thisNode}];

%% The actual pipelines

myPipe1 = meegpipe.node.pipeline.new(...
    'NodeList',         nodeList1, ...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Save',             false, ...
    'Name',             'splitting-ars', ...
    'Queue',            QUEUE);

myPipe2 = meegpipe.node.pipeline.new(...
    'NodeList',         nodeList2, ...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Save',             false, ...
    'Name',             'splitting-pvt', ...
    'Queue',            QUEUE);

%% Select relevant data files and process them with the corresp. pipeline

files1 = somsds.link2rec('batman', 'file_ext', '.mff', ...
    'subject', SUBJECTS_ARS, 'folder', OUTPUT_DIR, '--linknames');

files2 = somsds.link2rec('batman', 'file_ext', '.mff', ...
    'subject', SUBJECTS_PVT, 'folder', OUTPUT_DIR, '--linknames');

% keep waiting for files to be processed continuously
fprintf('(splitting) Continuously checking for input files ...\n\n');
while true
    % Process only those files that have been splitted yet
    % If you want to re-split an already splitted file then you will have to
    % manually delete the corresponding .meegpipe dir in the output directory
    
    pending1 = pending_files(files1);
    
    if ~isempty(pending1),
        run(myPipe1, pending1{:});
    end
    
    pending2 = pending_files(files2);
    
    if ~isempty(pending2),
        run(myPipe2, pending2{:});
    end
    
    if ~isempty(pending1) || ~isempty(pending2),
        fprintf('(splitting) Continuously checking for input files ...\n\n');
    end
    
    pause(PAUSE_PERIOD);
end
