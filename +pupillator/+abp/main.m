% MAIN - HRV feature extraction for the pupillator study


import physioset.event.class_selector;
import somsds.link2rec;
import misc.get_hostname;
import misc.regexpi_dir;
import mperl.join;
import pupillator.*;

%% User configuration

% Should the processing be done in parallel (on the grid)?
USE_OGE   = true;

% Should full HTML reports be generated?
DO_REPORT = true;

% What grid engine queue should the jobs be sent to?
% 
% VERY IMPORTANT: The execution host MUST have the HRV toolkit installed.
% At this point, the only node in somerengrid that fulfils this requirement
% is somerenserver. Thus, use only @somerenserver.herseninstituut.knaw.nl
% queues.
QUEUE     = 'all.q@somerenserver.herseninstituut.knaw.nl';

% The list of subjects that should be considered for the feat. extraction
SUBJECTS  = 1:12;

% The lists of conditions that should be considered
cond1     = {'morning', 'afternoon'};
cond2     = {'supine', 'sitting'};


%% Link (or find the location of) the relevant .edf files
regexSubj  = ['(' join('|', SUBJECTS) ')'];
regexCond1 = ['(' join('|', cond1) ')'];
regexCond2 = ['(' join('|', cond2) ')'];
regex = [regexSubj '_physiology_' regexCond1 '-' regexCond2 '.+.edf$'];

switch lower(get_hostname),
    
    case {'somerenserver', 'nin389'},        
        folder = ['/data1/projects/batman/analysis/pupillator/abp_' ...
            datestr(now, 'yymmdd-HHMMSS')];
        files = link2rec('pupw', 'file_ext', '.edf', ...
            'cond_regex', '(morning|afternoon)', ...
            'folder', folder, ...
            'subject', SUBJECTS);
    
    case 'nin271',
        files = regexpi_dir('D:/data/pupw', regex);
    otherwise
        error('Where is the pupw dataset in host %s?', get_hostname);
        
end


%% Process all files with the hrv_analysis pipeline
myPipe = pipes.abp_analysis(...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Queue',            QUEUE);

run(myPipe, files{:});

