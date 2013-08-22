% stage2.m
%
% Basic pre-processing

import batman.get_username;

%% User parameters

SUBJECTS = 1:100;

USE_OGE = true;

DO_REPORT = false;

INPUT_DIR = '/data1/projects/batman/analysis/stage1_130822-002116';

OUTPUT_DIR = ['/data1/projects/batman/analysis/stage2_', get_username '_' ...
    datestr(now, 'yymmdd-HHMMSS')];
CODE_DIR = '/data1/projects/batman/scripts/stage2';

%% Download the latest version of meegpipe
% Be aware that this will cause the LATEST version of meegpipe to be
% downloaded and installed everytime you run this script. This may not be a
% good idea if you are planning to analyze your data files in multiple runs
% of stage2 over different batches of data files. In the latter case you
% should comment this line after the first run of stage2 so that the stage2
% processing is always performed using the same version of meegpipe. It is
% OK though to use different versions of meegpipe in different processing
% stages (e.g. stage3 may use a newer version than stage2). 
batman.get_meegpipe(CODE_DIR);

%% Importing some pieces of meegpipe

% This import directives are used only for convenience so that we don't
% need to type the fully qualified names of certain meegpipe components
% that we use later. Note that we need to use eval because the import
% directives need to be executed at runtime (since we are downloading and 
% adding meegpipe to the path during runtime as well). 

eval('import meegpipe.node.*');
eval('import somsds.link2files');
eval('import misc.regexpi_dir');
eval('import mperl.file.spec.*');
eval('import mperl.file.find.finddepth_regex_match');
eval('import mperl.join');
eval('import pset.selector.sensor_class');
eval('import pset.selector.good_data');
eval('import pset.selector.cascade');
eval('import spt.bss.*');

%% Copy custom meegpipe configuration
% IMPORTANT: Since we are downloading the latest version of meegpipe
% everytime, any change that you may have made to the contents of the code
% directory will be lost (e.g. any modification of +meegpipe/meegpipe.ini
% will be lost). If you want to modify the configuration of meegpipe then
% you should instead modify +meg_mikex/meegpipe.ini. If you are performing
% the analysis on the somerengrid then the default meegpipe configuration
% is fine so this step is not really necessary.

% This must come after downloading and importing the various meegpipe
% components because function catdir is part of meegpipe
userConfig = catfile(batman.root_path, 'meegpipe.ini');
if exist(userConfig, 'file')
    copyfile(userConfig, CODE_DIR);
end


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

% Setting the "right" parameters of the filter involves quite a bit of
% trial and error. These values seemed OK to me but we should check
% carefully the reports to be sure that nothing went terribly wrong. In
% particular you should ensure that the LASIP filter is not removing
% valuable signal. It is OK if some residual noise is left after the LASIP
% filter so better to be conservative here.
myScales =  [20, 29, 42, 60, 87, 100, 126, 140, 182, 215, 264, 310, 382];

myFilter = filter.lasip(...
    'Decimation',       12, ...
    'GetNoise',         true, ... % Retrieve the filtering residuals
    'Gamma',            15, ...
    'Scales',           myScales, ...
    'WindowType',       {'Gaussian'}, ...
    'VarTh',            0.1);

% This object especifies which subset of data should be processed by the
% node. In this case we want to process only the EEG data, and ignore any
% other modalities.
mySelector = pset.selector.sensor_class('Class', 'EEG');

myNode = tfilter.new(...
    'Filter',           myFilter, ...
    'Name',             'lasip', ...
    'DataSelector',     mySelector, ...
    'ShowDiffReport',   true ...
    );

nodeList = [nodeList {myNode}];


%%% Node: Reject bad channels
% This will MARK as bad those channels whose variance is above maxVal or
% below minVal (both thresholds are expressed in logarithmic scale, i.e. in
% dBs). It is important that this node rejects ALL channels that are
% obviously bad, especially those with large variance. Otherwise, bad
% channels with large variance may lead to suboptimal separation of noise
% components in later stages of the processing chain. 
minVal = @(x) median(x) - 20;
maxVal = @(x) median(x) + 15;
myCrit = bad_channels.criterion.var.new('Min', minVal, 'Max', maxVal);
myNode = bad_channels.new('Criterion', myCrit);
nodeList = [nodeList {myNode}];

%%% Node (optional): bad channels rejection using cross-correlation
% This node will mark as bad those channels that have abnormally low
% cross-correlation with the neaghboring channels. This node can be used in
% addition to the bad channels rejection node that we used above.

% This version of the xcorr criterion will reject those channels whose
% average cross-correlation (in logarithmic scale, i.e. dBs) with its
% 10 nearest neighbor channels is 10 dBs below the median cross-correlation
% between its 10 nearest neighbors.

% We comment this node becase it may not be necessary...
% myCrit = bad_channels.criterion.xcorr.new(...
%     'NN',   10, ... 
%     'Min',  @(corrVal) median(corrVal) - 10 ...
%     );
% myNode = bad_channels.new('Criterion', myCrit);
% nodeList = [nodeList {myNode}];


%%% Node: Reject bad samples
myNode = bad_samples.new(...
    'MADs',         5, ...
    'WindowLength', @(fs) fs/4, ...
    'MinDuration',  @(fs) round(fs/4));
nodeList = [nodeList {myNode}];


%%% Node: Band-pass filter between 0.5 and 70 Hz

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

% This regular expression matches all files that end in an underscore
% followed by one or more digits, followed by the string '.pseth' or
% '.pset'.
regex = '_\d+\.pseth?$';
files = finddepth_regex_match(INPUT_DIR, regex);

link2files(files, OUTPUT_DIR);
regex = '_\d+\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

if isempty(files),
    error('Files from stage1 could not be found');
end

run(myPipe, files{:});

