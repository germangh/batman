% stage2.m
%
% Basic pre-processing


meegpipe.initialize;

import meegpipe.node.*;
import somsds.link2files;
import misc.get_hostname;
import misc.regexpi_dir;
import mperl.file.spec.catdir;
import mperl.file.find.finddepth_regex_match;
import mperl.join;
import pset.selector.good_data;
import pset.selector.sensor_class;
import pset.selector.cascade;

%% Analysis parameters

SUBJECTS = 6;%1:7;

CONDITIONS = {'rs'};

BLOCKS = 1:5;%1:14;

USE_OGE = true;

DO_REPORT = true;

switch lower(get_hostname)
    case 'somerenserver'
        ROOT_DIR = '/data1/projects/batman/analysis';
        INPUT_DIR = catdir(ROOT_DIR, 'stage1_130815-160848');
        
    case 'nin271',
        INPUT_DIR = 'D:\data';
        
    otherwise,
        error('The location of the batman dataset is not known');
        
end

OUTPUT_DIR = catdir(ROOT_DIR, ['stage2_' datestr(now, 'yymmdd-HHMMSS')]);


%% Build the cleaning pipeline

nodeList = {};

%%% Node: data import
myImporter = physioset.import.physioset('Precision', 'double');
myNode = physioset_import.new('Importer', myImporter);

nodeList = [nodeList {myNode}];

%%% Node: copy the physioset

myNode = copy.new;
nodeList = [nodeList {myNode}];

%%% Node: remove large signal fluctuations using a LASIP filter

% setting the "right" parameters of the filter involves quite a bit of
% trial and error...
myScales =  [20, 29, 42, 60, 87, 100, 126, 140, 182, 215, 264, 310, 382];

myFilter = filter.lasip(...
    'Decimation',       12, ...
    'GetNoise',         true, ... % Retrieve the filtering residuals
    'Gamma',            15, ...
    'Scales',           myScales, ...
    'WindowType',       {'Gaussian'}, ...
    'VarTh',            0.1);

mySelector = pset.selector.sensor_class('Class', 'EEG');

myNode = tfilter.new(...
    'Filter',           myFilter, ...
    'Name',             'lasip', ...
    'DataSelector',     mySelector, ...
    'ShowDiffReport',   true ...
    );

nodeList = [nodeList {myNode}];


%%% Node: Reject bad channels
minVal = @(x) median(x) - 20;
maxVal = @(x) median(x) + 15;
myCrit = bad_channels.criterion.var.new('Min', minVal, 'Max', maxVal);
myNode = bad_channels.new('Criterion', myCrit);
nodeList = [nodeList {myNode}];


%%% Node: Reject bad samples
myNode = bad_samples.new(...
    'MADs',         5, ...
    'WindowLength', @(fs) fs/4, ...
    'MinDuration',  @(fs) round(fs/4));
nodeList = [nodeList {myNode}];


%%% Node: Band-pass filter

myFilter    = @(sr) filter.bpfilt('fp', [0.5 70]/(sr/2));

mySelector  = cascade(...
    sensor_class('Class', 'EEG'), ...
    good_data ...
    );

myNode  = tfilter.new(...
    'Filter',       myFilter, ...
    'DataSelector', mySelector, ...
    'IOReport',     report.plotter.io);

nodeList = [nodeList {myNode}];

%%% The pipeline
myPipe = pipeline.new(...
    'NodeList',         nodeList, ...
    'Save',             true, ...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Name',             'stage2' ...
    );


%% Select the relevant files and start the data processing jobs
switch lower(get_hostname),
    case 'somerenserver',
        regex = '_\d+\.pseth?$';
        files = finddepth_regex_match(INPUT_DIR, regex);
        % link2files works only under Mac OS X and Linux
        link2files(files, OUTPUT_DIR);
        regex = '_\d+\.pseth$';
        files = finddepth_regex_match(OUTPUT_DIR, regex);
        
    otherwise,
        error('The location of the batman dataset is not known');
        
end

if isempty(files),
    error('Files from stage1 could not be found');
end
run(myPipe, files{:});

