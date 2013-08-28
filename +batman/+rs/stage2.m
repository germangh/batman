% stage2.m
%
% Stage description:
%
% - Aggregation of spectral features across subjects and experimental
%   blocks
%
%
% Pre-requisites:
%
% - rs.stage1 has been successfully completed
% - batman.setup has been run just before running this script
%
%
% See also: batman

import meegpipe.aggregate;
import mperl.file.find.finddepth_regex_match;
import batman.*;

%% Aggregation parameters

INPUT_DIR = '/data1/projects/batman/analysis/rs-stage1_gherrero_130827-102715';

OUTPUT_FILE = {...
    ['/data1/projects/batman/analysis/rs-stage2_power_ratios' ...
    get_username '_' datestr(now, 'yymmdd-HHMMSS') '.csv'], ...
    ['/data1/projects/batman/analysis/rs-stage2_raw_power' ...
    get_username '_' datestr(now, 'yymmdd-HHMMSS') '.csv'] ...;
    };

% How to translate the file names into info tags
FILENAME_TRANS = 'batman_(?<subject>\d+)_.+_rs_(?<block>\d+)';


%% Do the aggregation

% Match the input files to batman.rs.stage1
regex = '_stage4.pseth$';
files = finddepth_regex_match(INPUT_DIR, regex);

% First aggregate the features produced by node 2, which computed power
% ratios in various classical EEG bands
[fName, aggrFiles] = aggregate(files, ...
    'node-02-spectra.+features.txt$', OUTPUT_FILE{1}, FILENAME_TRANS);

% Now aggregate the features produced by node 3, which computed raw power
% values in various classical EEG bands
[fName, aggrFiles] = aggregate(files, ...
    'node-03-spectra.+features.txt$', OUTPUT_FILE{2}, FILENAME_TRANS);


