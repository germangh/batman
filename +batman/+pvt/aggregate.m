% pvt_aggregate
%
% Aggregation of PVT features across subjects and experimental blocks
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
        INPUT_DIR = '/data1/projects/batman/analysis/pvt_130919-170945';
        
        OUTPUT_FILE = ...
            ['/data1/projects/batman/analysis/pvt_features_' ...
            datestr(now, 'yymmdd-HHMMSS') ...
            ];
        

    otherwise
        error('Where is the data?');
end

% How to translate the file names into info tags
FILENAME_TRANS = @(fName) batman.fname2condition(fName);

% List of subjects to be aggregated
SUBJECTS = 1:12;

% List of blocks to be aggregated
BLOCKS = 1:14;

%% Do the aggregation

regex = ['0+(' join('|', SUBJECTS) ')_.+_(' join('|', BLOCKS) ...
    ').pseth$'];
files = finddepth_regex_match(INPUT_DIR, regex, true);

if isempty(files),
    error('I found no files matching the provided regex');
end

aggregate(files, 'features.txt$', [OUTPUT_FILE '.csv'], FILENAME_TRANS);

