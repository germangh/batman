function aggregate_ontj(inputDir, outputFile)
% AGGREGATE_ONTJ - Aggregate PD features for ontj dataset
%
% aggregate_ontj(inputDir, outputFile)
%
% Where INPUTDIR is the directory where pupillator.pd.main stored the PD
% features, and OUTPUTFILE is the full path to the file where the 
% aggregated PD features will be stored.
%
%
% See also: pupillator.pd.main


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
switch lower(get_hostname),
    case {'somerenserver', 'nin389'},
        BASE_PATH = '/data1/projects/batman/analysis/pupillator';          
    case 'nin271'
        BASE_PATH = 'D:\data\pupw';
    otherwise
        error('Where is the data?');
end

if isempty(outputFile),
    outputFile = catfile(BASE_PATH, 'pd_ontj_features');
end

if isempty(inputDir),
    inputDir = dir(BASE_PATH, 'pd_ontj_\d\d\d\d\d\d-\d\d\d\d\d\d$');   
    inputDir = sort(inputDir);
    inputDir = catdir(BASE_PATH, inputDir{end});
end

% How to translate the file names into info tags
FILENAME_TRANS = 'ontj_(?<subject>\d+)_pupillometry_.+';

% List of subjects to be aggregated
SUBJECTS = 1:50;

%% Do the aggregation

% First we find the list of files that were processed with the hrv_analysis
% pipeline. This is necessary to determine the location of the relevant
% .meegpipe directories (within which the features.txt files are located).
regex = ['0+(' join('|', SUBJECTS) ')_pupillometry.+\.csv'];
files = finddepth_regex_match(inputDir, regex, true);

aggregate2(files, 'pupillator-pd-ontj-.+features.txt$', ...
    [outputFile '.csv'], FILENAME_TRANS);


end
