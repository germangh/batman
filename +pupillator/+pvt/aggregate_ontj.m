function aggregate_ontj(inputDir, outputFile)
% aggregate_ontj
%
% Aggregation of PVT features across files for the ontj recording
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
import misc.dir;

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
    outputFile = catfile(BASE_PATH, 'pvt_ontj_features');
end

if isempty(inputDir),
    inputDir = dir(BASE_PATH, 'pvt_ontj_\d\d\d\d\d\d-\d\d\d\d\d\d$');   
    inputDir = sort(inputDir);
    inputDir = catdir(BASE_PATH, inputDir{end});
end

% How to translate the file names into info tags
FILENAME_TRANS = 'ontj_(?<subject>\d+)_pupillometry_';

% List of subjects to be aggregated
SUBJECTS = 1:50;

%% Do the aggregation

regex = ['0+(' join('|', SUBJECTS) ')_pupillometry.+\.csv$'];
files = finddepth_regex_match(inputDir, regex, true);

aggregate2(files, 'pupillator-pvt-ontj.+node-\d\d-block-\d+/features.txt$', ...
    [outputFile '.csv'], FILENAME_TRANS);

aggregate2(files, 'pupillator-pvt-ontj.+node-02-ev_features/features.txt$', ...
    [outputFile '_raw.csv'], FILENAME_TRANS);


end

