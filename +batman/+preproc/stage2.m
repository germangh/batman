% stage2.m
%
% Basic pre-processing

import batman.get_username;

%% Necessary if you are planning to update meegpipe
clear all;
clear classes;

%% User parameters

SUBJECTS = 1:100;

USE_OGE = true;

DO_REPORT = true;

INPUT_DIR = {...
    '/data1/projects/batman/analysis/stage1b_gherrero_130822-133350', ...
    '/data1/projects/batman/analysis/stage1_gherrero_130822-133023'};

OUTPUT_DIR = ['/data1/projects/batman/analysis/stage2_', get_username '_' ...
    datestr(now, 'yymmdd-HHMMSS')];

QUEUE = 'short.q@somerenserver.herseninstituut.knaw.nl';

%% Importing some bits and pieces of meegpipe
import meegpipe.node.*;
import somsds.link2files;
import misc.regexpi_dir;
import mperl.file.spec.*;
import mperl.file.find.finddepth_regex_match;
import mperl.join;
import pset.selector.sensor_class;
import pset.selector.good_data;
import pset.selector.cascade;
import spt.bss.*;

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

% We set minVal to something much smaller than the median because of the
% large number of high-variance channels (due to pervasive PWL artifacts)
% that drive the median variance towards a larger-than-usual value.
minVal = @(x) median(x) - 40;
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
    'Parallelize',       USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Name',             'stage2', ...
    'Queue',            QUEUE ...
    );


%% Select the relevant files and start the data processing jobs

% This regular expression matches all files that end in an underscore
% followed by one or more digits, followed by the string '.pseth' or
% '.pset'.
if ischar(INPUT_DIR),
    INPUT_DIR = {INPUT_DIR};
end
allFiles = {};
for i = 1:numel(INPUT_DIR)
    regex = '_\d+\.pseth?$';
    files = finddepth_regex_match(INPUT_DIR{i}, regex);
    allFiles = [allFiles;files(:)]; %#ok<AGROW>
end

link2files(allFiles, OUTPUT_DIR);
regex = '_\d+\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

if isempty(files),
    error('Files from stage1 could not be found');
end

run(myPipe, files{:});

