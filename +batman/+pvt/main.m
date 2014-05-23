% MAIN - PVT feature extraction

import batman.*;

%% Analysis parameters

USE_OGE = true;

DO_REPORT = true;

INPUT_DIR = '/data1/projects/batman/analysis/split_files';

OUTPUT_DIR = ['/data1/projects/batman/analysis/pvt/' datestr(now, 'yymmdd-HHMMSS')];

QUEUE = 'short.q';

%% Import meegpipe stuff
import somsds.link2files;
import misc.regexpi_dir;
import mperl.file.spec.*;
import mperl.file.find.finddepth_regex_match;
import mperl.join;

%% Select the relevant files and start the data processing jobs
regex = '_pvt_\d+\.pseth?$';
files = finddepth_regex_match(INPUT_DIR, regex, false);

link2files(files, OUTPUT_DIR);
regex = '_pvt_\d+\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

myPipe = batman.pipes.pvt_analysis(...
    'GenerateReport',   DO_REPORT, ...
    'OGE',              USE_OGE, ...
    'Queue',            QUEUE);

if ~isempty(files),
    run(myPipe, files{:});
end