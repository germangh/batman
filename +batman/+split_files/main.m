% MAIN - Split raw data files into single sub-block files
%

import misc.get_hostname;
import somsds.link2rec;
import misc.dir;

addpath(genpath('/data1/toolbox/eeglab'));
meegpipe.initialize;

%% Splitting parameters
SUBJECTS = 7;%1:10;

OUTPUT_DIR = '/data1/projects/batman/analysis/splitting';

% Pipeline options
USE_OGE     = true;
DO_REPORT   = true;
QUEUE       = 'long.q@somerenserver.herseninstituut.knaw.nl';


%% Select the relevant data files
files = link2rec('batman', 'file_ext', '.mff', 'subject', SUBJECTS, ...
    'folder', OUTPUT_DIR);


if isempty(files),
    error('Could not find any input data file');
end

%% Process all files with the splitting pipeline
myPipe = batman.pipes.split_files(...
    'GenerateReport',   DO_REPORT, ...
    'Parallelize',      USE_OGE, ...
    'Queue',            QUEUE);


run(myPipe, files{:});
