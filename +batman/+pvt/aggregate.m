function aggregate(inputDir, outputFile)
% pvt_aggregate
%
% Aggregation of PVT features across subjects and experimental blocks
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
BASE_PATH = '/data1/projects/batman/analysis/pvt';


if isempty(outputFile),
    outputFile = catfile(BASE_PATH, 'pvt_features');
end

if isempty(inputDir),
    inputDir = misc.find_latest_dir(BASE_PATH);   
end

% How to translate the file names into info tags
FILENAME_TRANS = @(fName) batman.split_files.fname2meta(fName);


%% Discover missing/broken jobs and inform the user
failedJobs = misc.find_failed_jobs(inputDir);
if ~isempty(failedJobs),
    warning('There are incomplete or failed meegpipe jobs. See list below.');
    fprintf(mperl.join('\n', failedJobs));
end

%% Do the aggregation
regex = 'batman_0+\d+_eeg_all_.+_\d+\.pseth$';
files = dir(inputDir, regex);
files = catfile(inputDir, files);

aggregate2(files, 'batman-pvt-.+features.txt$', ...
    [outputFile '.csv'], FILENAME_TRANS);

