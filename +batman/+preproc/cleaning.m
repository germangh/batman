% Cleans the splitted data files
%
% Performs all the pre-processing steps, except the splitting which is done
% by batman.preproc.splitting
%
% Usage:
% batman.setup
% batman.preproc.cleaning
%
%
% See also: batman

import batman.get_username;
import batman.pending_files;

%% User parameters
SUBJECTS = 1:100;

INPUT_DIR = '/data1/projects/batman/analysis/splitting';
OUTPUT_DIR = '/data1/projects/batman/analysis/cleaning';

% Pipeline options
USE_OGE = true;
DO_REPORT = true;
QUEUE = 'long.q@somerenserver.herseninstituut.knaw.nl';

%% Import meegpipe stuff
import somsds.link2files;
import misc.regexpi_dir;
import mperl.file.spec.*;
import mperl.file.find.finddepth_regex_match;
import mperl.join;

%% Select the relevant files and start the data processing jobs
oge.wait_for_grid('split_rs');

regex = '_\d+\.pseth?$';
files = finddepth_regex_match(INPUT_DIR, regex);

link2files(files, OUTPUT_DIR);
regex = '_\d+\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

myPipe = batman.pipes.cleaning(...
    'GenerateReport',   DO_REPORT, ...
    'OGE',              USE_OGE, ...
    'Queue',            QUEUE);
pending = pending_files(myPipe, files);

if ~isempty(pending),
    run(myPipe, pending{:});
end