% MAIN_ONTJ - Pre-processing and feature extraction for PD measurements


import physioset.event.class_selector;
import somsds.link2rec;
import misc.get_hostname;
import misc.regexpi_dir;
import mperl.join;
import pupillator.*;

%% User parameters
USE_OGE   = true;
DO_REPORT = true;
QUEUE     = 'short.q';
SUBJECTS  = 1:50;

%% Link (or find the location of) the relevant .edf files
folder = ['/data1/projects/batman/analysis/pupillator/pd_ontj_' ...
    datestr(now, 'yymmdd-HHMMSS')];
files = link2rec('ontj', 'modality', 'pupillometry', ...
    'file_ext', '.csv', ...
    'folder', folder, ...
    'subject', SUBJECTS);

%% Process all files with the pd_analysis pipeline
myPipe = pipes.pd_analysis_ontj(...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Queue',            QUEUE);

run(myPipe, files{:});

