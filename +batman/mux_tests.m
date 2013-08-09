% mux_tests - Process MUX test files with a simple pipeline

meegpipe.initialize;

import meegpipe.node.*;
import somsds.link2rec;
import misc.get_hostname;
import misc.regexpi_dir;
import mperl.file.spec.catdir;
import mperl.file.find.finddepth_regex_match;
import mperl.join;

%% Analysis parameters

SUBJECTS = 9999;

% Should OGE be used, if available?
USE_OGE = false;

% Generate comprehensive HTML reports?
DO_REPORT = true;

% The directory where the results will be produced
if USE_OGE, oge = '-oge'; else oge = ''; end
OUTPUT_DIR = catdir(['/data1/projects/batman/analysis/batman-tmux-tests' ...
    oge '_' datestr(now, 'yymmdd-HHMMSS')]);

%% Build the pipeline

eegSel = pset.selector.sensor_class('Class', 'EEG');

% Bad channel selection
myCrit = bad_channels.criterion.var.new('Percentile', [1 99]);
badChans1 = bad_channels.new('Criterion', myCrit);

% Removing high-amplitude weird stuff using LASIP
lasipFilter = filter.lasip('Decimation', 12, 'GetNoise', true, 'Gamma', 15, ...
    'Scales', [20, 29, 42, 60, 87, 100, 126, 140, 182, 215, 264, 310, 382], ...
    'WindowType', {'Gaussian'}, ...
    'ExpandBoundary', 0, 'VarTh', 0.1);

lasipNode = tfilter.new(...
    'Filter',           lasipFilter, ...
    'Name',             'lasip', ...
    'DataSelector',     eegSel, ...
    'ShowDiffReport',   true ...  
    );

myPipe = pipeline.new('NodeList', ...
    { ...
    physioset_import.new('Importer', physioset.import.mff), ...
    lasipNode, ...
    badChans1, ...
    bad_samples.new, ...
    batman.node.bss_regr_spiky_noise(NaN, 'Criterion', spt.criterion.dummy.new) ...
    }, ...
    'Save', true, 'OGE', USE_OGE, 'GenerateReport', DO_REPORT, ...
    'Name', 'batman-muxt-pipeline');

%% Process all the relevant data files
switch lower(get_hostname),
    case 'somerenserver',
        files = link2rec('batman_mux_tests', 'file_ext', '.mff', ...
            'subject', SUBJECTS, 'folder', OUTPUT_DIR);
        
   
    otherwise,
        error('The location of the batman dataset is not known');
        
end

run(myPipe, files{:});

    