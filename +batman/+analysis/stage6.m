% stage6.m
%
% Stage description:
%
% - Aggregation of spectral features across subjects and experimental
%   blocks
%
%
% Pre-requisites:
%
% - stage4 has been successfully completed
% - batman.setup has been run just before running this script
%
%
% See also: batman

import meegpipe.aggregate;

%% Aggregation parameters

INPUT_DIR = '/data1/projects/batman/analysis/stage5_gherrero_130823-175358';

OUTPUT_FILE = ['/data1/projects/batman/analysis/stage6_' ...
    get_username '_' datestr(now, 'yymmdd-HHMMSS') '.csv'];

% How to translate the file names into info tags
FILENAME_TRANS = 'batman_(?<subject>\d+)_.+_rs_(?<block>\d+)';



%% Do the aggregation
regex = 'node-02-spectra[\/]features.txt$';
files = finddepth_regex_match(INPUT_DIR, regex);

[fName, aggrFiles] = aggregate(files, '', OUTPUT_FILE, FILENAME_TRANS);

