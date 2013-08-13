% cleaning - Cleaning the already splitted data files
%
%
% Author: German Gomez-Herrero <g@germangh.com>

%clear all;

meegpipe.initialize;

import meegpipe.node.*;
import somsds.link2files;
import misc.get_hostname;
import misc.regexpi_dir;
import mperl.file.spec.catdir;
import mperl.file.find.finddepth_regex_match;
import mperl.join;

%% Analysis parameters

% List of subjects that will be analyzed
SUBJECTS = 1:7;

CONDITIONS = {'rs'};

BLOCKS = 1:14;

% Should OGE be used, if available?
USE_OGE = false;

% Generate comprehensive HTML reports?
DO_REPORT = true;

% The location of the splitted data files
switch lower(get_hostname)
    case 'somerenserver'
        ROOT_DIR = '/data1/projects/batman/analysis';
        INPUT_DIR = catdir(ROOT_DIR, 'batman-split_files');
        
    case 'nin271',
        INPUT_DIR = 'D:\data';
        
    otherwise,
        error('The location of the batman dataset is not known');
        
end

% The directory where the results will be produced
if USE_OGE,
    tmp = '-oge';
else
    tmp = '';
end
OUTPUT_DIR = catdir(ROOT_DIR, ...
    ['batman-cleaning' tmp '_' datestr(now, 'yymmdd-HHMMSS')]);


%% Build the cleaning pipeline

eegSel = pset.selector.sensor_class('Class', 'EEG');

% Bad channel selection
myCrit = bad_channels.criterion.var.new('Percentile', [1 99]);
badChans1 = bad_channels.new('Criterion', myCrit);

% Not used anymore:
% myCrit = bad_channels.criterion.xcorr.new('Percentile', [1 99]);
% badChans2 = bad_channels.new('Criterion', myCrit);

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

% A rather standard band-pass filtering node
myFilter = @(sr) filter.bpfilt('fp', [0.5 70]/(sr/2));
bpFiltNode = tfilter.new('Filter', myFilter, 'DataSelector', eegSel, ...
    'IOReport', report.plotter.io);

myPipe = pipeline.new('NodeList', ...
    { ...
    physioset_import.new('Importer', physioset.import.physioset), ...
    lasipNode, ...
    badChans1, ...
    bad_samples.new, ...
    bss_regr.pwl(NaN, 'IOReport', report.plotter.io), ...    
    bss_regr.eog(NaN, 'Var', 99.5, 'IOReport', report.plotter.io), ...
    batman.node.bss_regr_spiky_noise(NaN, 'Var', 99.9, 'IOReport', report.plotter.io), ...
    resample.new('OutputRate', 250), ...    
    bpFiltNode ...
    }, ...
    'Save', true, 'OGE', USE_OGE, 'GenerateReport', DO_REPORT, ...
    'Name', 'batman-cleaning-pipeline');

%% Process all relevant data files
switch lower(get_hostname),
    case 'somerenserver',
        % Create a new directory to store the analysis results        
        regex = batman.files_regex(SUBJECTS, CONDITIONS, BLOCKS, '', ...
            '\.pset.?');
        files = finddepth_regex_match(INPUT_DIR, regex);
        link2files(files, OUTPUT_DIR);
        regex = batman.files_regex(SUBJECTS, CONDITIONS, BLOCKS, '', ...
            '\.pseth');
        files = finddepth_regex_match(OUTPUT_DIR, regex);
        
    case 'nin271',
        files = finddepth_regex_match(INPUT_DIR, ...
            '_(rs|pvt)_\d+\.pseth$');
        
    otherwise,
        error('The location of the batman dataset is not known');
        
end

run(myPipe, files{:});
