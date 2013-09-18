% hrv_aggregate
%
% Aggregation of HRV features across subjects and experimental blocks
%
%
% See also: pupillator

import meegpipe.aggregate;
import mperl.file.find.finddepth_regex_match;
import pupillator.*;
import misc.get_hostname;
import mperl.join;

%% Aggregation parameters

switch lower(get_hostname),
    
    case 'somerenserver',
        INPUT_DIR = '/data1/projects/batman/analysis/hrv_130918-210541';
        
        OUTPUT_FILE = ...
            ['/data1/projects/batman/analysis/hrv_features_' ...
            datestr(now, 'yymmdd-HHMMSS') ...
            ];
        

    otherwise
        error('Where is the data?');
end

% How to translate the file names into info tags
FILENAME_TRANS = 'batman_(?<subject>\d+)_.+_(?<block>\d+)_cleaning';

% List of subjects to be aggregated
SUBJECTS = 1:12;

% List of blocks to be aggregated
BLOCKS = 1:14;

%% Do the aggregation

regex = ['0+(' join('|', SUBJECTS) ')_.+_(' join('|', BLOCKS) ...
    ')_cleaning.pseth$'];
files = finddepth_regex_match(INPUT_DIR, regex, true);

if isempty(files),
    error('I found no files matching the provided regex');
end

aggregate(files, 'features.txt$', [OUTPUT_FILE '.csv'], FILENAME_TRANS);

