% stage 1
%
% Splitting the large .mff files that contain 14 blocks into 14
% single-block files. 

import meegpipe.node.*;
import physioset.import.mff;
import somsds.link2rec;
import misc.get_hostname;
import misc.regexpi_dir;
import mperl.join;

%% User parameters

SUBJECTS = 1:7;

USE_OGE = true;

DO_REPORT = false;

switch lower(get_hostname),

    case 'somerenserver',
        OUTPUT_DIR = ...
            ['/data1/projects/batman/analysis/stage1_' ...
            datestr(now, 'yymmdd-HHMMSS')];
        
    otherwise,
        % do nothing
        
end

%% Build the pipeline node by node

nodeList = {};

%%% Node: import from .mff file

myImporter = mff('Precision', 'double');
myNode = physioset_import.new('Importer', mff);

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
namingPolicyRS = @(d, ev, idx) batman.naming_policy(d, ev, idx, 'rs');
namingPolicyPVT = @(d, ev, idx) batman.naming_policy(d, ev, idx, 'pvt');

% In some files, the ars+ event is missing (and also the stm+ events). It 
% seem that the most robust strategy to get the onsets of the RS epochs is
% to locate the first DIN4 (photodiode response) event within a block to
% determine the onset of a PVT block. Then we can use the fact that the
% RS epoch appears 7 minutes after the PVT block onset
offset      = 7*60;
duration    = 5*60;
mySel       = batman.pvt_selector;

thisNode = split.new(...
    'EventSelector',        mySel, ...
    'Offset',               offset, ...
    'Duration',             duration, ...
    'SplitNamingPolicy',    namingPolicyRS);

nodeList = [nodeList {thisNode}];

%%% Node: Extract PVT blocks

% offset      = -10;      % 10 seconds before the first PVT in the block
% duration    = 7*60;     % 7 minutes of PVT (at most)
% mySel       = batman.pvt_selector;
% 
% thisNode     = split.new(...
%     'EventSelector',        mySel, ...
%     'Offset',               offset, ...
%     'Duration',             duration, ...
%     'SplitNamingPolicy',    namingPolicyPVT);
% 
% nodeList = [nodeList {thisNode}];


%%% The actual pipeline

myPipe = pipeline.new(...
    'NodeList',         nodeList, ...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Save',             false, ...
    'Name',             'stage1', ...
    'Queue',            'long.q@somerenserver.herseninstituut.knaw.nl');


%% Select the relevant data files and process them with the pipeline

switch lower(get_hostname),
    
    case 'somerenserver',
        
        files = link2rec('batman', 'file_ext', '.mff', ...
            'subject', SUBJECTS, 'folder', OUTPUT_DIR);
        
    case 'nin271',
        
        if numel(SUBJECTS) > 1, 
            subjList = join('|', SUBJECTS);
        else
            subjList = num2str(SUBJECTS);
        end
        regex = ['batman_0+(' subjList ')_eeg_all.*\.mff$'];
        files = regexpi_dir('D:/data', regex);
        
    otherwise,
        error('The location of the batman dataset is not known');
        
end

run(myPipe, files{:});

