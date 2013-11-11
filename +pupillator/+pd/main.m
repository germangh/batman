% MAIN - Pre-processing and feature extraction for PD measurements

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
SUBJECTS  = 1:12;

%% Link (or find the location of) the relevant .edf files
regex = ['(' join('|', SUBJECTS) ')'];
regex = [regex '.+(supine|sitting)_\d.csv$'];

switch lower(get_hostname),
    case {'somerenserver', 'nin389'},
        folder = ['/data1/projects/batman/analysis/pupillator/pd_' ...
            datestr(now, 'yymmdd-HHMMSS')];
        files = link2rec('pupw', 'modality', 'pupillometry', ...
            'file_ext', '.csv', ...
            'cond_regex', '(morning|afternoon)', ...
            'folder', folder, ...
            'subject', SUBJECTS);
   
    case 'nin271',
        files = regexpi_dir('D:/data/pupw', regex);
    otherwise
        error('Unknown location of the pupw dataset');
end

%% Process all files with the pd_analysis pipeline
myPipe = pipes.pd_analysis(...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Queue',            QUEUE);

run(myPipe, files{:});

