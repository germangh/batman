% stage 1b
%
% Splitting the large .mff files that contain 14 blocks into 14
% single-block files.


%% User parameters

SUBJECTS = 1:100;

USE_OGE = true;

DO_REPORT = false;

OUTPUT_DIR = ['/data1/projects/batman/analysis/stage1b_', ...
    datestr(now, 'yymmdd-HHMMSS')];
CODE_DIR = '/data1/projects/batman/scripts/stage1';

% stage1.m takes care of puting meegpipe in CODE_DIR
addpath(genpath(CODE_DIR));

%% Build the pipeline node by node

nodeList = {};

%%% Node: import from .mff file

myImporter = physioset.import.mff('Precision', 'double');
myNode = meegpipe.node.physioset_import.new('Importer', myImporter);

nodeList = [nodeList {myNode}];

%%% Node: Extract resting state blocks

% These two function handles are used to decode the suffix that will be
% attached to each splitted file from three pieces of information:
%
% 1) The physioset object that results of importing one large mff file
%
% 2) The event object the specifies the onset and duration of the split
%
% 3) The index of event 2) within the array of all split events present in
% the physioset that was imported in 1)
namingPolicyRS = @(d, ev, idx) batman.preproc.naming_policy(d, ev, idx, 'rs');

% In some files, the ars+ event is missing (and also the stm+ events). It
% seem that the most robust strategy to get the onsets of the RS epochs is
% to locate the first DIN4 (photodiode response) event within a block to
% determine the onset of a PVT block. Then we can use the fact that the
% RS epoch appears 7 minutes after the PVT block onset
%
% Correction: this doesn't seem to work either. Damn it! See for instance
%  batman_0001_eeg_all, which apparently has only 9 PVT blocks. What is
%  going on with that file?? In stage1.m we use the ars+ events. Then in
%  stage1b we use the beginning of PVT block events.
offset      = 7*60;
duration    = 5*60;
mySel       = batman.preproc.pvt_selector;

thisNode = meegpipe.node.split.new(...
    'EventSelector',        mySel, ...
    'Offset',               offset, ...
    'Duration',             duration, ...
    'SplitNamingPolicy',    namingPolicyRS);

nodeList = [nodeList {thisNode}];


%%% The actual pipeline

myPipe = meegpipe.node.pipeline.new(...
    'NodeList',         nodeList, ...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Save',             false, ...
    'Name',             'stage1b', ...
    'Queue',            'long.q@somerenserver.herseninstituut.knaw.nl');


%% Select the relevant data files and process them with the pipeline

switch lower(misc.get_hostname),
    
    case 'somerenserver',
        
        files = somsds.link2rec('batman', 'file_ext', '.mff', ...
            'subject', SUBJECTS, 'folder', OUTPUT_DIR);
        
    case 'nin271',
        
        if numel(SUBJECTS) > 1,
            subjList = mperl.join('|', SUBJECTS);
        else
            subjList = num2str(SUBJECTS);
        end
        regex = ['batman_0+(' subjList ')_eeg_all.*\.mff$'];
        files = misc.regexpi_dir('D:/data', regex);
        
    otherwise,
        error('The location of the batman dataset is not known');
        
end

run(myPipe, files{:});

