% main analysis script for pupil diameter measurements

import physioset.event.class_selector;
import somsds.link2rec;
import misc.get_hostname;
import misc.regexpi_dir;
import mperl.join;
import pupillator.*;

USE_OGE   = true;
DO_REPORT = false;
QUEUE     = 'short.q';

subjects  = 1:12;

% Select the relevant data files for the analysis
regex = ['(' join('|', subjects) ')'];
regex = [regex '.+(supine|sitting)_\d.csv$'];

switch lower(get_hostname),
    case {'somerenserver', 'nin389'},
        folder = ['/data1/projects/batman/analysis/pupillator/pd_' ...
            datestr(now, 'yymmdd-HHMMSS')];
        files = link2rec('pupw', 'modality', 'pupillometry', ...
            'file_ext', '.csv', ...
            'cond_regex', '(morning|afternoon)', ...
            'folder', folder, ...
            'subject', subjects);
   
    case 'nin271',
        files = regexpi_dir('D:/data/pupw', regex);
    otherwise
        error('Unknown location of the pupw dataset');
end


% HRV analysis
myPipe = pipes.pd_analysis(...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Queue',            QUEUE);

run(myPipe, files{:});

