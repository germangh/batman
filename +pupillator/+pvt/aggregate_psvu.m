function aggregate_psvu(inputDir, outputFile)
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
BASE_PATH = '/data1/projects/psvu/analysis/pvt';


if isempty(outputFile),
    outputFile = catfile(BASE_PATH, 'pvt_psvu_features');
end

if isempty(inputDir),
    inputDir = misc.find_latest_dir(BASE_PATH);
end

% How to translate the file names into info tags
FILENAME_TRANS = 'psvu_(?<subject>\d+)_pupillometry_session(?<session>\d+)';

% List of subjects to be aggregated
SUBJECTS = 1:100;

%% Do the aggregation

regex = ['0+(' join('|', SUBJECTS) ')_pupillometry.+\.csv$'];
files = finddepth_regex_match(inputDir, regex, true);

aggregate2(files, 'pupillator-pvt-psvu.+node-\d\d-block-\d+/features.txt$', ...
    [outputFile '.csv'], FILENAME_TRANS);

aggregate2(files, 'pupillator-pvt-psvu.+node-02-ev_features/features.txt$', ...
    [outputFile '_raw.csv'], FILENAME_TRANS);


end

