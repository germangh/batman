% split_files.m - Split files into subsets
%
%
%
% Author: German Gomez-Herrero <g@germangh.com>

clear all;

import meegpipe.node.*;
import physioset.import.mff;
import somsds.link2rec;
import misc.get_hostname;
import misc.regexpi_dir;

%% User parameters

% List of subjects that need to be splitted

SUBJECTS = 7;

% Should OGE be used, if available?
USE_OGE = false;

% Generate comprehensive HTML reports?
DO_REPORT = false;

% The directory where the results will be produced
switch lower(get_hostname),
    
    case 'somerenserver',
        OUTPUT_DIR = ['batman-split_files-' datestr(now, 'ddmmyyHHMMSS')];
        
    otherwise,
        error('The location of the batman dataset is not known');
        
end

%% Build the splitting pipeline

% Select the events that mark the beginning of the RSQ
mySel = physioset.event.class_selector('Type', 'ars+');

% The splitted files should contain the condition (RS or PVT) and block
% number as a suffix
namingPolicyRS = @(data, ev, idx) ['rs_' num2str(idx)];
namingPolicyPVT = @(data, ev, idx) ['pvt_' num2str(idx)];

% The offset and the duration of the RS condition
offset = -5*60;
duration = 5*60;

rsNode = split.new('EventSelector', mySel, 'Offset', offset, ...
    'Duration', duration, 'SplitNamingPolicy', namingPolicyRS);

% The offset and the duration of the PVT condition
offset = -10*60;
duration = 5*60;

pvtNode = split.new('EventSelector', mySel, 'Offset', offset, ...
    'Duration', duration, 'SplitNamingPolicy', namingPolicyRS);

myPipe = pipeline.new('NodeList', ...
    { ...
    physioset_import.new('Importer', mff), ...
    center.new, ...
    detrend.new, ...
    resample.new('OutputRate', 500), ...
    rsNode, ...
    pvtNode ...
    }, ...
    'OGE', USE_OGE, 'GenerateReport', DO_REPORT);


%% Process all the relevant data files
switch lower(get_hostname),
    case 'somerenserver',
        files = link2rec('batman', 'file_ext', '.mff', ...
            'subject', SUBJECTS, 'folder', OUTPUT_DIR);
        
    otherwise,
        error('The location of the batman dataset is not known');
        
end

run(myPipe, files{:});

