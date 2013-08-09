% split_files.m - Split files into subsets
%
%
%
% Author: German Gomez-Herrero <g@germangh.com>

%clear all;

import meegpipe.node.*;
import physioset.import.mff;
import somsds.link2rec;
import misc.get_hostname;
import misc.regexpi_dir;
import mperl.join;

%% User parameters

% List of subjects that need to be splitted

SUBJECTS = 1:7;

% Should OGE be used, if available?
USE_OGE = true;

% Generate comprehensive HTML reports?
DO_REPORT = false;

% The directory where the results will be produced
switch lower(get_hostname),

    case 'somerenserver',
        OUTPUT_DIR = ...
            ['/data1/projects/batman/analysis/batman-split_files_' ...
            datestr(now, 'yymmdd-HHMMSS')];
        
    otherwise,
        % do nothing
        
end

%% Build the splitting pipeline

% The splitted files should contain the condition (RS or PVT) and block
% number as a suffix
namingPolicyRS = @(d, ev, idx) batman.naming_policy(d, ev, idx, 'rs');
namingPolicyPVT = @(d, ev, idx) batman.naming_policy(d, ev, idx, 'pvt');

% In some files, the ars+ event is missing (and also the stm+ events). To
% get the RS epochs in these cases we use the first DIN4 event within a
% block to determine the onset of a PVT block. We then use the fact that
% the RS epoch appears 7 minutes after the PVT block onset
offset = 7*60;
duration = 5*60;
mySel = batman.pvt_selector;
rsNode = split.new('EventSelector', mySel, 'Offset', offset, ...
    'Duration', duration, 'SplitNamingPolicy', namingPolicyRS);

% Build a node for extracting the PVT blocks
offset = -10;   % 10 seconds before the first PVT in the block
duration = 7*60; % 7 minutes of PVT (at most)
mySel = batman.pvt_selector;
pvtNode = split.new('EventSelector', mySel, 'Offset', offset, ...
    'Duration', duration, 'SplitNamingPolicy', namingPolicyPVT);

myFilter = @(sr) filter.bpfilt('fp', [0.5 130]/(sr/2));

myPipe = pipeline.new('NodeList', ...
    { ...
    physioset_import.new('Importer', mff), ...       
    rsNode, ...
    pvtNode ...
    }, ...
    'OGE', USE_OGE, 'GenerateReport', DO_REPORT, 'Save', false);


%% Process all the relevant data files
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

