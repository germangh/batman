% MAIN_ONTJ - Feature extraction from PVT events

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
subjects  = 1:100;

%% Link (or find the location of) the relevant .csv files
regex = ['(' join('|', subjects) ')'];

switch lower(get_hostname),
    case {'somerenserver', 'nin389'},
        folder = ['/data1/projects/batman/analysis/pupillator/pvt_ontj_' ...           
            datestr(now, 'yymmdd-HHMMSS')];
            %'pvt_ontj_131112-080301'];
        files = link2rec('ontj', 'modality', 'pupillometry', ...
            'file_ext', '.csv', ...
            'folder', folder, ...
            'subject', subjects);
   
    case 'nin271',
        files = regexpi_dir('D:/data/ontj', regex);
    otherwise
        error('Unknown location of the pupw dataset');
end

%% Process all files with the pvt_analysis pipeline
myPipe = pipes.pvt_analysis_ontj(...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Queue',            QUEUE);

run(myPipe, files{:});
