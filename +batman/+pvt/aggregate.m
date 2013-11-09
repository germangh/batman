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
switch lower(get_hostname),
    case {'somerenserver', 'nin389'},
        BASE_PATH = '/data1/projects/batman/analysis';          
    case 'nin271'
        BASE_PATH = 'D:\data\batman';
    otherwise
        error('Where is the data?');
end

if isempty(outputFile),
    outputFile = catfile(BASE_PATH, 'pvt_features');
end

if isempty(inputDir),
    inputDir = dir(BASE_PATH, 'pvt_\d\d\d\d\d\d-\d\d\d\d\d\d$');   
    inputDir = sort(inputDir);
    inputDir = catdir(BASE_PATH, inputDir{end});
end

% How to translate the file names into info tags
FILENAME_TRANS = @(fName) batman.fname2condition(fName);

%% Do the aggregation
regex = 'batman_0+\d+_eeg_all_.+_\d+\.pseth$';
files = dir(inputDir, regex);
files = catfile(inputDir, files);

aggregate2(files, 'batman-pvt-.+features.txt$', ...
    [outputFile '.csv'], FILENAME_TRANS);

