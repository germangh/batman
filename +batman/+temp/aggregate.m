function aggregate(inputDir, outputFile)
% AGGREGATE - Aggregate temperature features across subjects/blocks
%
% aggregate(inputDir, outputFile)
%
% Where INPUTDIR is the directory where pupillator.temp.main stored the 
% temperature features, and OUTPUTFILE is the full path to the file where
% the aggregated HRV features will be stored.
%
%
% See also: pupillator.temp.main

import meegpipe.aggregate2;
import misc.dir;
import misc.get_hostname;
import mperl.join;
import mperl.file.spec.catfile;
import mperl.file.spec.catdir;

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
    outputFile = catfile(BASE_PATH, 'temp_features');
end

if isempty(inputDir),
    inputDir = dir(BASE_PATH, 'temp_\d\d\d\d\d\d-\d\d\d\d\d\d$');   
    inputDir = sort(inputDir);
    inputDir = catdir(BASE_PATH, inputDir{end});
end

% How to translate the file names into info tags
FILENAME_TRANS = @(fName) batman.split_files.fname2meta(fName);

% The hash code of the pipeline that was used to generate the temp features
PIPE_HASH = '121556';%get_id(batman.pipes.temp_in_epochs);

%% Do the aggregation

regex = 'batman_0+\d+_eeg_all_.+_\d+\.pseth$';
files = dir(inputDir, regex);
files = catfile(inputDir, files);

aggregate2(files, ['temp_in_epochs-' PIPE_HASH '.+features.txt$'], ...
    [outputFile '.csv'], FILENAME_TRANS);

