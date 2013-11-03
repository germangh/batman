function pvt_aggregate(inputDir, outputFile)
% pvt_aggregate
%
% Aggregation of PVT features across files
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
    
    case {'somerenserver', 'nin389'},
        INPUT_DIR = '/data1/projects/batman/analysis/pupillator/pvt_131102-150507';
        
        OUTPUT_FILE = ...
            '/data1/projects/batman/analysis/pupillator/pvt_features';
        
    case 'nin271'
        INPUT_DIR = 'D:\data\pupw';
        OUTPUT_FILE = 'D:\data\pupw\pvt_features';
        
    otherwise
        error('Where is the data?');
end

if nargin < 1 || isempty(inputDir),
    inputDir = INPUT_DIR;
end

if nargin < 2 || isempty(outputFile),
    outputFile = OUTPUT_FILE;
end
    

% How to translate the file names into info tags
FILENAME_TRANS = 'pupw_(?<subject>\d+)_pupillometry_(?<condition1>[^-]+)-(?<condition2>[^-]+)_(?<meas>\d+)';

% List of subjects to be aggregated
SUBJECTS = 1:12;

% List of blocks to be aggregated
BLOCKS = 1:2;

% The hash code of the pipeline that was used to process the PD files
PIPE_HASH = get_id(pupillator.pipes.pvt_analysis);

%% Do the aggregation

regex = ['0+(' join('|', SUBJECTS) ')_pupillometry.+_(' join('|', BLOCKS) ...
    ').csv$'];
files = finddepth_regex_match(inputDir, regex, true);

aggregate2(files, ['pupillator-pvt-' PIPE_HASH '.+features.txt$'], [outputFile '.csv'], FILENAME_TRANS);


end

