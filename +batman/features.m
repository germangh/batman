% features - Extracting features from the splitted and clean data files
%
%
% Author: German Gomez-Herrero <g@germangh.com>

meegpipe.initialize;

import meegpipe.node.*;
import somsds.link2dir;
import misc.get_hostname;
import misc.regexpi_dir;
import mperl.file.spec.catdir;
import mperl.file.find.finddepth_regex_match;
import mperl.join;
import misc.agg

%% Analysis parameters

% List of subjects that will be analyzed
SUBJECTS = 7;

CONDITIONS = {'rs'};

BLOCKS = 2;

% Should OGE be used, if available?
USE_OGE = false;

% Generate comprehensive HTML reports?
DO_REPORT = true;

% The location of the splitted data files
switch lower(get_hostname)
    case 'somerenserver'
        ROOT_DIR = '/data1/projects/batman/analysis';
        INPUT_DIR = catdir(ROOT_DIR, 'batman-cleaning');
        
    case 'nin271',
        INPUT_DIR = 'D:\data';
        
    otherwise,
        error('The location of the batman dataset is not known');
        
end

% The directory where the results will be produced
OUTPUT_DIR = catdir(ROOT_DIR, ...
    ['batman-features_' datestr(now, 'yymmdd-HHMMSS')]);

%% Buildl the cleaning pipeline

myPipe = pipeline.new('NodeList', ...
    { ...
    physioset_import.new('Importer', physioset.import.physioset), ...
    spectra.new ...
    }, ...
    'Save', false, 'OGE', USE_OGE, 'GenerateReport', DO_REPORT, ...
    'Name', 'batman-features-pipeline');

%% Process all the relevant data files

switch lower(get_hostname)
    
    case 'somerenserver',
        % Create a new directory to store the analysis results
        link2dir(INPUT_DIR, OUTPUT_DIR);

        regex = batman.files_regex(SUBJECTS, CONDITIONS, BLOCKS, ...
            'cleaning', '\.pseth');
        
        files = finddepth_regex_match(OUTPUT_DIR, regex);
        
    otherwise,
        error('The location of the batman dataset is not known');
        
end

run(myPipe, files{:});

if ~USE_OGE,
    
end
    