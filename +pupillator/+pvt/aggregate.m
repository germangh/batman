function aggregate(inputDir, outputFile)
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
import mperl.file.spec.catfile;
import mperl.file.spec.catdir;

if nargin < 1, inputDir = []; end
if nargin < 2, outputFile = []; end

%% Aggregation parameters
switch lower(get_hostname),
    case {'somerenserver', 'nin389'},
        BASE_PATH = '/data1/projects/batman/analysis/pupillator';          
    case 'nin271'
        BASE_PATH = 'D:\data\pupw';
    otherwise
        error('Where is the data?');
end

if isempty(outputFile),
    outputFile = catfile(BASE_PATH, 'pvt_features');
end

if isempty(inputDir),
    inputDir = dir(BASE_PATH, 'pvt_\d\d\d\d\d\d-\d\d\d\d\d\d$');   
    inputDir = sort(inputDir);
    inputDir = catdir(BASE_PATH, inputDir{end});
end

% How to translate the file names into info tags
FILENAME_TRANS = ['pupw_(?<subject>\d+)_pupillometry_' ...
    '(?<condition1>[^-]+)-(?<condition2>[^-]+)_(?<meas>\d+)'];

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

