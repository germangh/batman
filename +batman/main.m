% Main analysis script for the BATMAN recordings
%
% The analysis consists of the following stages:
%
% 1) Data import: .mff files are imported in meegpipe
%
% 2) Basic pre-processing: detrending, filtering, downsampling, etc
%
% 3) Removal of powerline noise using BSS
%
% 4) Removal of 2Hz noise produced by the Braintronics multiplexer
%
%
% Author: German Gomez-Herrero <g@germangh.com>

clear all;

import meegpipe.node.*;
import physioset.import.mff;
import somsds.link2rec;
import misc.get_hostname;
import misc.regexpi_dir;

%% Analysis parameters

% List of subjects that will be analyzed
SUBJECTS = 7;

% Should OGE be used, if available?
USE_OGE = false;

% Generate comprehensive HTML reports?
DO_REPORT = false;

% The directory where the results will be produced
OUTPUT_DIR = ['batman-main_' datestr(now, 'yymmdd-HHMMSS')];


%% Build the analysis pipeline

myFilter = @(sr) filter.bpfilt('fp', [0.5 130]/(sr/2));

myPipe = pipeline.new('NodeList', ...
    { ...
    physioset_import.new('Importer', mff), ...
    center.new, ...
    detrend.new, ...
    resample.new('OutputRate', 500), ...
    tfilter.new('Filter', myFilter) ...
    }, ...
    'Save', true, 'OGE', USE_OGE, 'GenerateReport', DO_REPORT);
    


%% Process all relevant data files
switch lower(get_hostname),
    case 'somerenserver',
        files = link2rec('batman', 'file_ext', '.mff', ...
            'subject', SUBJECTS, 'folder', OUTPUT_DIR);
        
    otherwise,
        error('The location of the batman dataset is not known');
        
end
        
run(myPipe, files{:});
  