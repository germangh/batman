% hrv_aggregate
%
% Aggregation of HRV features across subjects and experimental blocks
%
%
% See also: pupillator

import meegpipe.aggregate2;
import mperl.file.find.finddepth_regex_match;
import pupillator.*;
import misc.get_hostname;
import mperl.join;

%% Aggregation parameters

switch lower(get_hostname),
    
    case 'somerenserver',
        INPUT_DIR = '/data1/projects/batman/analysis/pupillator/hrv_131029-124134';
        
        OUTPUT_FILE = ...
            '/data1/projects/batman/analysis/pupillator/hrv_features';
        
    case 'nin271'
        INPUT_DIR = 'D:\data\pupw';
         OUTPUT_FILE = 'D:\data\pupw\hrv_features';
        
    otherwise
        error('Where is the data?');
end

% How to translate the file names into info tags
FILENAME_TRANS = 'pupw_(?<subject>\d+)_physiology_(?<condition1>[^-]+)-(?<condition2>[^-]+)_(?<meas>\d+)';

% List of subjects to be aggregated
SUBJECTS = 1:12;

% List of blocks to be aggregated
BLOCKS = 1:2;

%% Do the aggregation

regex = ['0+(' join('|', SUBJECTS) ').+_(' join('|', BLOCKS) ...
    ').edf$'];
files = finddepth_regex_match(INPUT_DIR, regex, true);


aggregate2(files, 'features.txt$', [OUTPUT_FILE '.csv'], FILENAME_TRANS);

