% main analysis script
import meegpipe.node.*;
import physioset.import.edfplus;
import physioset.event.class_selector;
import somsds.link2rec;
import misc.get_hostname;
import misc.regexpi_dir;
import mperl.join;

subjects = 1:2;

%% Build the analysis pipeline

myGen = pupillator.block_events_generator;
mySel = {...
    class_selector('Type', '^dark$', 'Name', 'dark'), ...
    class_selector('Type', '^red$', 'Name', 'red'), ...
    class_selector('Type', '^blue$', 'Name', 'blue') ...
    };


myPipe = pipeline.new('NodeList', {...
    physioset_import.new('Importer', edfplus), ...
    ev_gen.new('EventGenerator', myGen), ...
    ecg_annotate.new('EventSelector', mySel, 'VMUrl', '192.87.10.186') ...
    }, 'Save', true, 'OGE', true, 'GenerateReport', true);


%% Process all relevant data files
switch lower(get_hostname),
    case 'somerenserver',
        files = link2rec('pupw', 'file_ext', '.edf');
    case 'outolintulocal',
        regex = ['(' join('|', subjects) ')'];
        regex = [regex '.+.edf$']; 
        files = regexpi_dir('~/Dropbox/suomi-data', regex);
    otherwise
        error('Unknown location of the pupw dataset');
end

run(myPipe, files{:});
