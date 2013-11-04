% MAIN - Extraction of HRV features


import somsds.link2files;
import misc.regexpi_dir;
import mperl.file.spec.*;
import mperl.file.find.finddepth_regex_match;
import mperl.join;
import misc.get_hostname;

switch lower(get_hostname),
    
    case {'somerenserver', 'nin389'},
        INPUT_DIR = '/data1/projects/batman/analysis/splitting';
        OUTPUT_DIR = ['/data1/projects/batman/analysis/hrv_' ...
            datestr(now, 'yymmdd-HHMMSS')];
        
    case 'nin271',
        INPUT_DIR = 'D:/data/batman/splitting';
        OUTPUT_DIR = ['D:/data/batman/hrv_' datestr(now, 'yymmdd-HHMMSS')];
        
    case 'outolintulan'
        INPUT_DIR = '/Volumes/DATA/datasets/batman';
        OUTPUT_DIR = '/Volumes/DATA/datasets/batman/hrv';
        
    otherwise
        
        error('No idea where the data is in host %s', get_hostname);
        
end

% Pipeline options
USE_OGE     = true;
DO_REPORT   = true;

% IMPORTANT: Use only somerenserver queues! The HRV toolkit is only
% installed in that node.
QUEUE       = 'short.q@somerenserver.herseninstituut.knaw.nl';

%% Select the relevant files and start the data processing jobs
regex = 'split_files-.+_\d+\.pseth?$';
files = finddepth_regex_match(INPUT_DIR, regex, false);

link2files(files, OUTPUT_DIR);
regex = '_\d+\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

%% Process all files with the HRV feature extraction pipeline
myPipe = batman.pipes.hrv_analysis(...
    'GenerateReport',   DO_REPORT, ...
    'Parallelize',      USE_OGE, ...
    'Queue',            QUEUE);


run(myPipe, files{:});
