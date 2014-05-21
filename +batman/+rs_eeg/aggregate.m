function aggregate(inputDir, outputFile)
% AGGREGATE - Aggregate resting state EEG features across files
%
% aggregate(inputDir, outputFile)
%
%
% See also: pupillator

import mperl.file.find.finddepth_regex_match;
import mperl.join;
import mperl.file.spec.catfile;
import mperl.file.spec.catdir;
import misc.dir;

if nargin < 1, inputDir = []; end
if nargin < 2, outputFile = []; end

%% Aggregation parameters
BASE_PATH = '/data1/projects/batman/analysis/spectral_analysis';

if isempty(outputFile),
    outputFile = catfile(BASE_PATH, 'rs_features');
end

if isempty(inputDir),
    inputDir = misc.find_latest_dir(BASE_PATH);  
end

% How to translate the file names into info tags
FILENAME_TRANS = @(fName) batman.split_files.fname2meta(fName);

%% Do the aggregation
bands = {'alpha', 'beta1', 'beta2', 'theta'};
for bandItr = 1:numel(bands)
    regex = 'batman_0+\d+_eeg_all_.+_\d+_.+pseth$';
    files = finddepth_regex_match(inputDir, regex, false, false);
    
    meegpipe.aggregate2(files, [bands{bandItr} '.txt$'], ...
        [outputFile '_' bands{bandItr} '.csv'], FILENAME_TRANS);
end
