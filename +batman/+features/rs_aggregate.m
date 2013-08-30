% rs_aggregate
%bat
% Aggregation of spectral features across subjects and experimental blocks
%
%
% See also: batman

import meegpipe.aggregate;
import mperl.file.find.finddepth_regex_match;
import batman.*;
import mperl.join;

%% Aggregation parameters

INPUT_DIR = ['/data1/projects/batman/analysis/rs_features_' get_username];

OUTPUT_FILE = {...
    ['/data1/projects/batman/analysis/rs_features_power_ratios_' ...
    get_username '.csv'], ...
    ['/data1/projects/batman/analysis/rs-features_raw_power_' ...
    get_username '.csv'] ...
    };

% How to translate the file names into info tags
FILENAME_TRANS = 'batman_(?<subject>\d+)_.+_rs_(?<block>\d+)';

% List of subjects to be aggregated
SUBJECTS = 1:10;

% List of blocks to be aggregated
BLOCKS = 1:14;

%% Do the aggregation

% Match the list of files that were the input to the feature extraction
% pipeline. Consider only those files that match our SUBJECTS and BLOCKS
% Change this later to _cleaning.pseth
regex = ['0+(' join('|', SUBJECTS) ').+rs_(' join('|', BLOCKS) ')_stage2-4.pseth$'];
files = finddepth_regex_match(INPUT_DIR, regex);

% First aggregate the features produced by node 2, which computed power
% ratios in various classical EEG bands
aggregate(files, 'node-02-power-ratios.+features.txt$', OUTPUT_FILE{1}, ...
    FILENAME_TRANS);

% Now aggregate the features produced by node 3, which computed raw power
% values in various classical EEG bands
aggregate(files, 'node-03-raw-power.+features.txt$', OUTPUT_FILE{2}, ...
    FILENAME_TRANS);

