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

meegpipe.initialize;

%% User parameters
SUBJECTS = 1:100;

INPUT_DIR = '/data1/projects/batman/analysis/splitting';
OUTPUT_DIR = ['/data1/projects/batman/analysis/cleaning_' ...
    datestr(now, 'yymmdd-HHMMSS')];

% The names and config hash codes of the splitting pipes that were used to
% split the files that are to be the input of this stage of the analysis. 
SPLIT_PIPES = {...
    'split_rs_ars-d44fd2', ...
    'split_rs_pvt-72218c' ...
    };

% Pipeline options
USE_OGE     = true;
DO_REPORT   = true;
QUEUE       = 'long.q@somerenserver.herseninstituut.knaw.nl';

%% Import meegpipe stuff
import somsds.link2files;
import misc.regexpi_dir;
import mperl.file.spec.*;
import mperl.file.find.finddepth_regex_match;
import mperl.join;

%% Select the relevant files and start the data processing jobs
oge.wait_for_grid('split_rs');

regex = ['(' join('|', SPLIT_PIPES) ')_.+_\d+\.pseth?$'];
files = finddepth_regex_match(INPUT_DIR, regex, false);

link2files(files, OUTPUT_DIR);
regex = '_\d+\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

myPipe = batman.pipes.cleaning(...
    'GenerateReport',   DO_REPORT, ...
    'OGE',              USE_OGE, ...
    'Queue',            QUEUE);

if ~isempty(files),
    run(myPipe, files{:});
end