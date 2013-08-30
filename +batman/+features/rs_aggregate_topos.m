% aggregate_topos
%
% Aggregate topographies for specific features
%
%
% See also: batman

import meegpipe.aggregate;
import mperl.file.find.finddepth_regex_match;
import batman.*;
import mperl.join;
import mperl.file.spec.catfile;

%% Aggregation parameters

INPUT_DIR = ['/data1/projects/batman/analysis/rs_features_' get_username];

OUTPUT_DIR = '/data1/projects/batman/analysis';

% List of subjects to be aggregated
SUBJECTS = 1:10;

% List of features to aggregate (into separate files)
FEATURES = {'alpha', 'gamma', 'beta', 'delta', 'theta'};

% List of blocks to be aggregated
BLOCKS = 1:14;

%% Do the aggregation (separately for each feature)

% Match the list of files that were the input to the feature extraction
% pipeline. Consider only those files that match our SUBJECTS and BLOCKS
% Change this later to _cleaning.pseth
regex = ['0+(' join('|', SUBJECTS) ').+rs_(' join('|', BLOCKS) ')_stage2-4.pseth$'];
files = finddepth_regex_match(INPUT_DIR, regex);

for featItr = 1:numel(FEATURES)
    
    % First aggregate the features produced by node 2, which computed power
    % ratios in various classical EEG bands
    aggregate(files, ['node-02-power-ratios.+' FEATURES{featItr} '.txt$'], ...
        catfile(OUTPUT_DIR, ...
        ['rs_features_power_ratios_topos_' FEATURES{featItr} '.csv']));
    
    % Now aggregate the features produced by node 3, which computed raw power
    % values in various classical EEG bands
    aggregate(files, ['node-03-raw-power.+' FEATURES{featItr} '.txt$'], ...
        catfile(OUTPUT_DIR, ...
        ['rs_features_raw_power_topos_' FEATURES{featItr} '.csv']));
    
    
end