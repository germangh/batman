function aggregate(inputDir, outputFile)
% AGGREGATE - Aggregate HRV features across subjects/blocks
%
% aggregate(inputDir, outputFile)
%
% Where INPUTDIR is the directory where pupillator.hrv.main stored the HRV
% features, and OUTPUTFILE is the full path to the file where the 
% aggregated HRV features will be stored.
%
%
% See also: pupillator.hrv.main

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
BASE_PATH = '/data1/projects/batman/analysis/hrv';


if isempty(outputFile),
    outputFile = catfile(BASE_PATH, 'hrv_features');
end

if isempty(inputDir),
    inputDir = misc.find_latest_dir(BASE_PATH);   
end

% How to translate the file names into info tags
FILENAME_TRANS = @(fName) batman.split_files.fname2meta(fName);

%% Do the aggregation
regex = 'batman_0+\d+_eeg_all_.+_\d+\.pseth$';
files = dir(inputDir, regex);
files = catfile(inputDir, files);

aggregate2(files, 'batman-hrv-.+features.txt$', ...
    [outputFile '.csv'], FILENAME_TRANS);

end
