function aggregate(inputDir, outputFile)
% aggregate
%
% Aggregation of PVT features across files
%
%
% See also: pupillator

import meegpipe.aggregate2;
import mperl.file.find.finddepth_regex_match;
import pupillator.*;
import mperl.join;
import mperl.file.spec.catfile;
import mperl.file.spec.catdir;
import misc.dir;

if nargin < 1, inputDir = []; end
if nargin < 2, outputFile = []; end

%% Aggregation parameters
BASE_PATH = '/data1/projects/batman/analysis/pupillator/pvt';

if isempty(outputFile),
    outputFile = catfile(BASE_PATH, 'pvt_features');
end

if isempty(inputDir),
    inputDir = misc.find_latest_dir(BASE_PATH);
end

% How to translate the file names into info tags
FILENAME_TRANS = ['pupw_(?<subject>\d+)_pupillometry_' ...
    '(?<condition1>[^-]+)-(?<condition2>[^-]+)_(?<meas>\d+)'];

% List of subjects to be aggregated
SUBJECTS = 1:12;

% List of blocks to be aggregated
BLOCKS = 1:2;

%% Do the aggregation
regex = ['0+(' join('|', SUBJECTS) ')_pupillometry.+_(' join('|', BLOCKS) ...
    ').csv$'];
files = finddepth_regex_match(inputDir, regex, true);

aggregate2(files, 'pupillator-pvt-.+features.txt$', [outputFile '.csv'], FILENAME_TRANS);


end

