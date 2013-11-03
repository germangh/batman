% aggregate
%
% Aggregation of Temp features across subjects
%
% See also: batman.temp

import meegpipe.aggregate2;
import misc.dir;
import misc.get_hostname;
import mperl.join;
import mperl.file.spec.catfile;

%% Aggregation parameters

switch lower(get_hostname),
    
    case {'somerenserver', 'nin389'},
        INPUT_DIR = '/data1/projects/batman/analysis/temp_131103-155813';
        
        OUTPUT_FILE = ...
            '/data1/projects/batman/analysis/temp_features';
        
    case 'outolintulan'
        INPUT_DIR = '/Volumes/DATA/datasets/batman/temp';
        OUTPUT_FILE = '/Volumes/DATA/datasets/batman/temp_features';
        
    case 'nin271'
        INPUT_DIR = 'D:\data\pupw';
        OUTPUT_FILE = 'D:\data\pupw\pd_features';
        
    otherwise
        error('Where is the data?');
end

% How to translate the file names into info tags
FILENAME_TRANS = @(fName) batman.split_files.fname2meta(fName);

% The hash code of the pipeline that was used to generate the temp features
PIPE_HASH = '121556';%get_id(batman.pipes.temp_in_epochs);

%% Do the aggregation

regex = 'batman_0+\d+_eeg_all_.+_\d+\.pseth$';
files = dir(INPUT_DIR, regex);
files = catfile(INPUT_DIR, files);

aggregate2(files, ['temp_in_epochs-' PIPE_HASH '.+features.txt$'], ...
    [OUTPUT_FILE '.csv'], FILENAME_TRANS);

