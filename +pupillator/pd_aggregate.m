% pd_aggregate
%
% Aggregation of PD features across subjects
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
        INPUT_DIR = '/data1/projects/batman/analysis/pupillator/pd_131029-123855';
        
        OUTPUT_FILE = ...
            '/data1/projects/batman/analysis/pupillator/pd_features';
        
    case 'nin271'
        INPUT_DIR = 'D:\data\pupw';
        OUTPUT_FILE = 'D:\data\pupw\pd_features';
        
    otherwise
        error('Where is the data?');
end

% How to translate the file names into info tags
FILENAME_TRANS = 'pupw_(?<subject>\d+)_pupillometry_(?<condition1>[^-]+)-(?<condition2>[^-]+)_(?<meas>\d+)';

% List of subjects to be aggregated
SUBJECTS = 1:12;

% List of blocks to be aggregated
BLOCKS = 1:2;

% The hash code of the pipeline that was used to process the PD files
PIPE_HASH = get_id(pupillator.pipes.pd_analysis);

%% Do the aggregation

regex = ['0+(' join('|', SUBJECTS) ')_pupillometry.+_(' join('|', BLOCKS) ...
    ').csv$'];
files = finddepth_regex_match(INPUT_DIR, regex, true);


aggregate2(files, ['pupillator-pd-' PIPE_HASH '.+features.txt$'], [OUTPUT_FILE '.csv'], FILENAME_TRANS);

