% MAIN_PSVU - Extraction of PVT event features from the psvu recordings


%% Analysis parameters

% Should the analysis run in the background as parallel open grid engine jobs?
USE_OGE = true;

% Should full HTML reports be generated?
DO_REPORT = true;

% The OGE queue where the jobs will be submitted (if using OGE)
QUEUE = 'short.q';

% The list of subjects that should be analyzed. It is OK to use here more
% subjects IDs than the number of actual subjects in your dataset. 
SUBJECTS = 1:100;

% The directory where the analysis results will be stored
OUTPUT_DIR = ['/data1/projects/psvu/analysis/pvt/' datestr(now, 'yymmdd-HHMMSS')];

mkdir(OUTPUT_DIR);

%% Create symbolic links

% We assume that you are working at somerengrid and that the relevant data
% files have been imported into the somsds data management system

% The command below is just a wrapper over the script somsds_link2rec which
% is available from the OS command line. 
files = somsds.link2rec('psvu', ...         % The recording ID
    'modality', 'pupillometry', ...  % The data modality of the requested files
    'folder',   OUTPUT_DIR,     ...  % Where should be the links generated?
    'subject',  SUBJECTS);

% Notice that in the command above we generate the links to the relevant
% pupillometry files within OUTPUT_DIR. This is because meegpipe always
% generates the results of processing file /path/to/a/file.csv under
% directory /path/to/a. That is, you must make sure that the files (or
% links to the files) that you want to analyzed are placed in the directory
% where you want the analysis results to be stored.

%% Process all pupillometry files using the pvt_analysis_psvu pipeline

% Type edit pupillator.pipes.pvt_analysis_psvu for details on the pipeline
% definition
myPipe = pupillator.pipes.pvt_analysis_psvu(...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Queue',            QUEUE, ...
    'MaxPVT',           990, ... % Reaction times above this will be ignored
    'MinPVT',           100, ... % Reaction times below this will be ignored
    'Lapse',            355);    % Reaction times above this are lapses
run(myPipe, files{:});
    
    
