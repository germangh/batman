function aggregate(inputDir, outputFile)
% AGGREGATE - Aggregate PD features across subjects/conditions
%
% aggregate(inputDir, outputFile)
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
    case 'nin271'
        BASE_PATH = 'D:\data\pupw';
    otherwise
        BASE_PATH = '/data1/projects/batman/analysis/pupillator';
end

if isempty(outputFile),
    outputFile = catfile(BASE_PATH, 'pd_features');
end

if isempty(inputDir),
    inputDir = dir(BASE_PATH, 'pd_\d\d\d\d\d\d-\d\d\d\d\d\d$');   
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

%% Do the aggregation

% First we find the list of files that were processed with the hrv_analysis
% pipeline. This is necessary to determine the location of the relevant
% .meegpipe directories (within which the features.txt files are located).
regex = ['0+(' join('|', SUBJECTS) ')_pupillometry.+_(' join('|', BLOCKS) ...
    ').csv$'];
files = finddepth_regex_match(inputDir, regex, true);

outputFileBak = [outputFile '_backup_' datestr(now, 'yymmddHHMMSS') '.csv'];
outputFile = [outputFile, '.csv'];

if exist(outputFile, 'file'),
    copyfile(outputFile, outputFileBak);
end

aggregate2(files, 'pupillator-pd-.+features.txt$', outputFile, FILENAME_TRANS);


end
