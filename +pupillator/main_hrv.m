% main analysis script for PVT response times

import physioset.event.class_selector;
import somsds.link2rec;
import misc.get_hostname;
import misc.regexpi_dir;
import mperl.join;
import pupillator.*;

USE_OGE   = true;
DO_REPORT = true;
QUEUE     = 'short.q@somerenserver.herseninstituut.knaw.nl';

subjects  = 1:12;
cond1     = {'morning', 'afternoon'};
cond2     = {'supine', 'sitting'};

% Select the relevant data files for the analysis
regexSubj  = ['(' join('|', subjects) ')'];
regexCond1 = ['(' join('|', cond1) ')'];
regexCond2 = ['(' join('|', cond2) ')'];
regex = [regexSubj '_physiology_' regexCond1 '-' regexCond2 '.+.edf$'];

switch lower(get_hostname),
    case {'somerenserver', 'nin389'},
        folder = ['/data1/projects/batman/analysis/pupillator/hrv_' ...
            datestr(now, 'yymmdd-HHMMSS')];
        files = link2rec('pupw', 'file_ext', '.edf', ...
            'cond_regex', '(morning|afternoon)', ...
            'folder', folder, ...
            'subject', subjects);
    
    case 'nin271',
        files = regexpi_dir('D:/data/pupw', regex);
    otherwise
        error('Unknown location of the pupw dataset');
end


% HRV analysis
myPipe = pipes.hrv_analysis(...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Queue',            QUEUE);

run(myPipe, files{:});

