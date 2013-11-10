function aggregate(inputDir, outputFile)
% AGGREGATE - Aggregate TEMP features across subjects/conditions
%
% aggregate(inputDir, outputFile)
%
% Where INPUTDIR is the directory where pupillator.temp.main stored the 
% features, and OUTPUTFILE is the full path to the file where the 
% aggregated TEMP features will be stored.
%
%
% See also: pupillator.temp.main

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
    outputFile = catfile(BASE_PATH, 'temp_features');
end

if isempty(inputDir),
    inputDir = dir(BASE_PATH, 'temp_\d\d\d\d\d\d-\d\d\d\d\d\d$');   
    inputDir = sort(inputDir);
    inputDir = catdir(BASE_PATH, inputDir{end});
end

% How to translate the file names into info tags
FILENAME_TRANS = ['pupw_(?<subject>\d+)_physiology_(?<condition1>[^-]+)' ...
    '-(?<condition2>[^-]+)_(?<meas>\d+)'];

% List of subjects to be aggregated
SUBJECTS = 1:12;

% List of blocks to be aggregated
BLOCKS = 1:2;

%% Do the aggregation

% First we find the list of files that were processed with the hrv_analysis
% pipeline. This is necessary to determine the location of the relevant
% .meegpipe directories (within which the features.txt files are located).
regex = ['0+(' join('|', SUBJECTS) ').+_(' join('|', BLOCKS) ...
    ').edf$'];
files = finddepth_regex_match(inputDir, regex, true);

aggregate2(files, 'features.txt$', [outputFile '.csv'], FILENAME_TRANS);

end