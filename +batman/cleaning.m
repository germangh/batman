% Cleaning the already splitted data files
%
%
% Author: German Gomez-Herrero <g@germangh.com>

%clear all;

meegpipe.initialize;

import meegpipe.node.*;
import somsds.link2dir;
import misc.get_hostname;
import misc.regexpi_dir;
import mperl.file.spec.catdir;
import mperl.file.find.finddepth_regex_match;
import mperl.join;

%% Analysis parameters

% List of subjects that will be analyzed
SUBJECTS = 7;

CONDITIONS = {'rs'};

BLOCKS = 2;

% Should OGE be used, if available?
USE_OGE = false;

% Generate comprehensive HTML reports?
DO_REPORT = false;

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
OUTPUT_DIR = catdir(ROOT_DIR, ...
    ['batman-cleaning_' datestr(now, 'yymmdd-HHMMSS')]);


%% Build the cleaning pipeline

% Selects only EEG data
eegSel = pset.selector.sensor_class('Class', 'EEG');

% Bad channel selection
myCrit = bad_channels.criterion.var.new;
badChans1 = bad_channels.new('Criterion', myCrit);

myCrit = bad_channels.criterion.xcorr.new('Percentile', [1 99]);
badChans2 = bad_channels.new('Criterion', myCrit);

% Removing high-amplitude weird stuff using LASIP
lasipFilter = filter.lasip('Decimation', 12, 'GetNoise', true, 'Gamma', 15, ...
    'Scales', [20, 29, 42, 60, 87, 100, 126, 140, 182, 215, 264, 310, 382], ...
    'WindowType', {'Gaussian'}, ...
    'ExpandBoundary', 0, 'VarTh', 0.1);

lasipNode = tfilter.new(...
    'Filter',       lasipFilter, ...
    'Name',         'lasip', ...
    'DataSelector', eegSel);

% A rather standard band-pass filtering node
myFilter = @(sr) filter.bpfilt('fp', [0.5 60]/(sr/2));
bpFiltNode = tfilter.new('Filter', myFilter, 'DataSelector', eegSel);

myPipe = pipeline.new('NodeList', ...
    { ...
    physioset_import.new('Importer', physioset.import.physioset), ...
    lasipNode, ...
    badChans1, ...
    badChans2, ...
    bpfiltNode, ...
    bss_regr.pwl, ...
    batman.node.bss_regr_2hz(NaN, 'Var', 99.9), ...
    bss_regr.ecg(NaN, 'Var', 99.9), ...
    bss_regr.eog(NaN, 'Var', 99.5), ...
    batman.node.bss_regr_spiky_noise(NaN, 'Var', 99.9), ...
    }, ...
    'Save', true, 'OGE', USE_OGE, 'GenerateReport', DO_REPORT, ...
    'Name', 'batman-main-pipeline');

%% Process all relevant data files
switch lower(get_hostname),
    case 'somerenserver',
        % Create a new directory to store the analysis results
        link2dir(INPUT_DIR, OUTPUT_DIR);
        
        % Match the splitted files
        if numel(SUBJECTS) > 1, 
            subjList = join('|', SUBJECTS);
        else
            subjList = num2str(SUBJECTS);
        end
        
        if numel(CONDITIONS) > 1,
            condList = join('|', CONDITIONS);
        else
            condList = CONDITIONS{1};
        end
        
        if numel(BLOCKS) > 1,
           blockList = join('|', BLOCKS);
        else
           blockList = num2str(BLOCKS); 
        end
        
        regex = ['batman_0+(' subjList ')_.+_(' condList ')_(' ...
            blockList ')\.pseth$'];
        files = finddepth_regex_match(OUTPUT_DIR, regex);
        
    case 'nin271',
        files = finddepth_regex_match(INPUT_DIR, ...
            '_(rs|pvt)_\d+\.pseth$');
        
    otherwise,
        error('The location of the batman dataset is not known');
        
end

run(myPipe, files{:});
