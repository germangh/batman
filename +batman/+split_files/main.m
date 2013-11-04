% MAIN - Split raw data files into single sub-block files
%

close all;
clear all;
clear classes;

import misc.get_hostname;
import somsds.link2rec;
import misc.dir;

%% Splitting parameters

SUBJECTS = 1:10;


switch lower(get_hostname),
    
    case {'somerenserver', 'nin389'}
        OUTPUT_DIR = '/data1/projects/batman/analysis/splitting';
        
    case 'outolintulan'
        OUTPUT_DIR = '/Volumes/DATA/datasets/batman';
        
    case 'nin271',
        OUTPUT_DIR = 'D:/data/batman/splitting';
        
    otherwise
        
        error('No idea where the data is in host %s', get_hostname);
        
end

% Pipeline options
USE_OGE     = true;
DO_REPORT   = true;
QUEUE       = 'long.q@somerenserver.herseninstituut.knaw.nl';


%% Select the relevant data files

switch lower(get_hostname),
    case {'somerenserver', 'nin389'}
        files = link2rec('batman', 'file_ext', '.mff', 'subject', SUBJECTS, ...
            'folder', OUTPUT_DIR);
        
    case 'nin271',
        files = dir('D:/data/batman/raw', '\.mff$', false, false, true);
        
    case 'outolintulan'
        files = dir(OUTPUT_DIR, '\.mff$', false, false, true);
        
end

if isempty(files),
    error('Could not find any input data file');
end

%% Process all files with the splitting pipeline
myPipe = batman.pipes.split_files(...
    'GenerateReport',   DO_REPORT, ...
    'Parallelize',      USE_OGE, ...
    'Queue',            QUEUE);


run(myPipe, files{:});
