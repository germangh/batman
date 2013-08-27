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

OUTPUT_FILE = ['/data1/projects/batman/analysis/rs-stage2_' ...
    get_username '_' datestr(now, 'yymmdd-HHMMSS') '.csv'];

% How to translate the file names into info tags
FILENAME_TRANS = 'batman_(?<subject>\d+)_.+_rs_(?<block>\d+)';


%% Do the aggregation
regex = '_stage4.pseth$';
files = finddepth_regex_match(INPUT_DIR, regex);

[fName, aggrFiles] = aggregate(files, 'features.txt$', OUTPUT_FILE, FILENAME_TRANS);

