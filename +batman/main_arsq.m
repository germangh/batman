% main analysis script for pupil diameter measurements

import physioset.event.class_selector;
import physioset.event.latency_selector;
import somsds.link2rec;
import misc.get_hostname;
import misc.regexpi_dir;
import mperl.join;
import batman.*;

USE_OGE   = true;
DO_REPORT = true;

subjects  = 1:12;

% Select the relevant data files for the analysis
regex = ['(' join('|', subjects) ')'];
regex = [regex '.+(supine|sitting)_\d.edf$'];

switch lower(get_hostname),
    case 'somerenserver',
        folder = '/data1/projects/batman/analysis/arsq';
        files = link2rec('batman', 'modality', 'eeg', ...
            'file_ext', '.mff', ...           
            'folder', folder, ...
            'subject', subjects);
   
    case 'nin271',
        files = regexpi_dir('D:/data/pupw', regex);
    otherwise
        error('Unknown location of the pupw dataset');
end

myImporter = physioset.import.mff('ReadDataValues', false);
mySelOnset = physioset.event.class_selector('Type', '^ars\+$');
mySelOffset = physioset.event.class_selector('Type', '^ars-$');

for i = 1:numel(files)
    evArray = import(myImporter, files{i});
    arsqOnsets = get_sample(select(mySelOnset, evArray));
    arsqOffsets = get_sample(select(mySelOffset, evArray));
    for j = 1:numel(arsqOnsets)
        myLatSel = latency_selector(1000,[arsqOnsets(j) arsqOffsets(j)]/1000);
        thisEv = select(myLatSel, evArray);
    end
    
end