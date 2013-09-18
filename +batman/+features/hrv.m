% hrv
%
% Extraction of heart rate variability (HRV) features using the HRV toolkit
% available at: http://physionet.org/tutorials/hrv-toolkit/
%
% See also: batman

import batman.*;

%% Analysis parameters

USE_OGE = true;

DO_REPORT = true;

INPUT_DIR = '/data1/projects/batman/analysis/cleaning';

OUTPUT_DIR = ['/data1/projects/batman/analysis/hrv_' ...
    datestr(now, 'yymmdd-HHMMSS')];

QUEUE = 'short.q@somerenserver.herseninstituut.knaw.nl';

%% Import meegpipe stuff
import somsds.link2files;
import misc.regexpi_dir;
import mperl.file.spec.*;
import mperl.file.find.finddepth_regex_match;
import mperl.join;

%% Select the relevant files and start the data processing jobs
oge.wait_for_grid('cleaning');

regex = '-979af1_.+_\d+_cleaning\.pseth?$';
files = finddepth_regex_match(INPUT_DIR, regex, false);

link2files(files, OUTPUT_DIR);
regex = '_\d+_cleaning\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

myPipe = batman.pipes.hrv_analysis(...
    'GenerateReport',   DO_REPORT, ...
    'OGE',              USE_OGE, ...
    'Queue',            QUEUE);
pending = pending_files(myPipe, files);

if ~isempty(pending),
    run(myPipe, pending{:});
end