% MAIN - Extraction of ABP features


import somsds.link2files;
import misc.regexpi_dir;
import mperl.file.spec.*;
import mperl.file.find.finddepth_regex_match;
import mperl.join;
import misc.get_hostname;

INPUT_DIR = misc.find_latest_dir('/data1/projects/batman/analysis/cleaning');
OUTPUT_DIR = ['/data1/projects/batman/analysis/abp/' ...
    datestr(now, 'yymmdd-HHMMSS')];

% Pipeline options
USE_OGE     = true;
DO_REPORT   = true;
QUEUE       = 'short.q@somerenserver.herseninstituut.knaw.nl';

%% Select the relevant files and start the data processing jobs
regex = 'split_files-.+_\d+\.pseth?$';
files = finddepth_regex_match(INPUT_DIR, regex, false);

link2files(files, OUTPUT_DIR);
regex = '_\d+\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

%% Process all files with the HRV feature extraction pipeline
myPipe = batman.pipes.abp_analysis(...
    'GenerateReport',   DO_REPORT, ...
    'Parallelize',      USE_OGE, ...
    'Queue',            QUEUE);

run(myPipe, files{:});
