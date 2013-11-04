% MAIN - Obtain temp values in correlative 1-min windows
%


import misc.get_hostname;
import misc.dir;
import somsds.link2files;
import misc.regexpi_dir;
import mperl.file.spec.*;
import mperl.file.find.finddepth_regex_match;
import mperl.join;

%% User-defined parameters

switch lower(get_hostname),
    
    case {'somerenserver', 'nin389'},
        INPUT_DIR = '/data1/projects/batman/analysis/splitting';
        OUTPUT_DIR = ['/data1/projects/batman/analysis/temp_' ...
            datestr(now, 'yymmdd-HHMMSS')];
        
    case 'outolintulan'
        INPUT_DIR = '/Volumes/DATA/datasets/batman';
        OUTPUT_DIR = '/Volumes/DATA/datasets/batman/temp';
        
    otherwise
        
        error('No idea where the data is in host %s', get_hostname);
        
end

% Pipeline options
USE_OGE     = true;
DO_REPORT   = true;
QUEUE       = 'short.q';

%% Select the relevant files and start the data processing jobs
regex = 'split_files-.+_\d+\.pseth?$';
files = finddepth_regex_match(INPUT_DIR, regex, false);

link2files(files, OUTPUT_DIR);
regex = '_\d+\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

%% Process all files with the temp feature extraction pipeline
myPipe = batman.pipes.temp_in_epochs(...
    'GenerateReport',   DO_REPORT, ...
    'Parallelize',      USE_OGE, ...
    'Queue',            QUEUE);


run(myPipe, files{:});
