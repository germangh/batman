% MAIN - Feature extraction from PVT events

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
subjects  = 1:12;

%% Link (or find the location of) the relevant .csv files
regex = ['(' join('|', subjects) ')'];
regex = [regex '.+(supine|sitting)_\d.csv$'];

switch lower(get_hostname),
    case 'nin271',
        files = regexpi_dir('D:/data/pupw', regex);
    otherwise
          folder = ['/data1/projects/batman/analysis/pupillator/pvt_' ...
            datestr(now, 'yymmdd-HHMMSS')];
        files = link2rec('pupw', 'modality', 'pupillometry', ...
            'file_ext', '.csv', ...
            'cond_regex', '(morning|afternoon)', ...
            'folder', folder, ...
            'subject', subjects);
end

%% Process all files with the pvt_analysis pipeline
myPipe = pipes.pvt_analysis(...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Queue',            QUEUE);

run(myPipe, files{:});
