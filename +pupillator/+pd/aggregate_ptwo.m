function aggregate_ptwo(inputDir, outputFile)
% AGGREGATE_PTWO - Aggregate PD features for ptwo dataset
%
% aggregate_ontj(inputDir, outputFile)
%
% Where INPUTDIR is the directory where pupillator.pd.main_ptwo stored the PD
% features, and OUTPUTFILE is the full path to the file where the 
% aggregated PD features will be stored.
%
%
% See also: pupillator.pd.main_psvu


import meegpipe.aggregate2;
import mperl.file.find.finddepth_regex_match;
import pupillator.*;
import misc.get_hostname;
import mperl.join;
import misc.dir;
import mperl.file.spec.catfile;
import mperl.file.spec.catdir;
import misc.dir;

if nargin < 1, inputDir = []; end
if nargin < 2, outputFile = []; end

%% Aggregation parameters
BASE_PATH = '/data1/projects/psvu/analysis/pd';

if isempty(outputFile),
    outputFile = catfile(BASE_PATH, 'pd_psvu_features');
end

if isempty(inputDir),
    inputDir = misc.find_latest_dir(BASE_PATH);
end

% How to translate the file names into info tags
FILENAME_TRANS = 'ptwo_(?<subject>\d+)_pupillometry_(?<protocol>brbr|rbrb)';

% List of subjects to be aggregated
SUBJECTS = 1:100;

%% Do the aggregation

regex = ['0+(' join('|', SUBJECTS) ')_pupillometry.+\.csv'];
files = finddepth_regex_match(inputDir, regex, true);

aggregate2(files, 'pupillator-pd-ptwo-.+features.txt$', ...
    [outputFile '.csv'], FILENAME_TRANS);


end
