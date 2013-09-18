% main analysis script

import physioset.event.class_selector;
import somsds.link2rec;
import misc.get_hostname;
import misc.regexpi_dir;
import mperl.join;
import pupillator.*;

% You cannot use OGE because multiple simultaneous calls to the ecgpuwave
% VM screws everything up... I should investigate this issue at some point
USE_OGE = false;
DO_REPORT = true;

subjects = 1:12;

% Select the relevant data files for the analysis
regex = ['(' join('|', subjects) ')'];
regex = [regex '.+.edf$'];

switch lower(get_hostname),
    case 'somerenserver',
        folder = ['/data1/projects/batman/analysis/pupillator/hrv_' ...
            datestr(now, 'yymmdd-HHMMSS')];
        files = link2rec('pupw', 'file_ext', '.edf', ...
            'cond_regex', '(morning|afternoon)', ...
            'folder', folder, ...
            'subject', subjects);
    case 'outolintulocal',        
        files = regexpi_dir('~/Dropbox/suomi-data', regex);
    case 'nin271',
        files = regexpi_dir('D:/data/pupw', regex);
    otherwise
        error('Unknown location of the pupw dataset');
end

myPipe = pipes.hrv_analysis(...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT);

run(myPipe, files{:});