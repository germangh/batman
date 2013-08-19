% mux_noise_test.m
%
% Trying various things to remove the MUX noise. This pipeline does not do
% any actual processing. It is valuable only for the reports it generates.


meegpipe.initialize;

import meegpipe.node.*;
import somsds.link2files;
import misc.get_hostname;
import misc.regexpi_dir;
import mperl.file.spec.catdir;
import mperl.file.find.finddepth_regex_match;
import mperl.join;
import pset.selector.cascade;
import pset.selector.good_data;
import pset.selector.sensor_class;
import spt.bss.multicombi.multicombi;
import spt.bss.efica.efica;

%% Analysis parameters

SUBJECTS = 7; %1:7

PIPE_NAME = 'mux-noise';

CONDITIONS = {'rs'};

BLOCKS = 1:4; % 1:14

USE_OGE = true;

DO_REPORT = true;

switch lower(get_hostname)
    case 'somerenserver'
        ROOT_DIR = '/data1/projects/batman/analysis';
        INPUT_DIR = catdir(ROOT_DIR, 'stage2_130815-173826');
        
    case 'nin271',
        INPUT_DIR = 'D:\data';
        
    otherwise,
        error('The location of the batman dataset is not known');
        
end

OUTPUT_DIR = catdir(ROOT_DIR, ...
    ['mux_noise_test_' datestr(now, 'yymmdd-HHMMSS')]);


%% Build the cleaning pipeline

nodeList = {};

%%% Node: data import
myImporter = physioset.import.physioset('Precision', 'double');
myNode = physioset_import.new('Importer', myImporter);

nodeList = [nodeList {myNode}];

%%% Node: copy the data

myNode = copy.new;

nodeList = [nodeList {myNode}];


%%% Node: Downsample

myNode = resample.new('OutputRate', 250);
nodeList = [nodeList {myNode}];


%%% Node: 
%%% Our best attempt at identifying the MUX-related noise component
mySel = cascade(sensor_class('Class', 'EEG'), good_data);

% This is a sneaky trick. I found out that the qrs_erp criterion ranks the
% MUX noise component highly. To make it work even better I trick the
% criterion so that it expects to find peaks twice as fast as in a normal
% cardiac component. 
myCrit1 = spt.criterion.qrs_erp.new('SamplingRate', 500);
myPCA  = spt.pca.new(...
    'Var',          .9975, ...
    'MinDimOut',    15, ...
    'MaxDimOut',    35);
myNode = bss_regr.new(...
    'DataSelector',     mySel, ...
    'Criterion',        myCrit1, ...
    'PCA',              myPCA, ...
    'BSS',              efica, ...
    'Name',             'qrs_detect');

nodeList = [nodeList {myNode}];


%%% Node: 
%%% The MUX noise seems to have a peak at 14 Hz and 50 Hz
mySel = cascade(sensor_class('Class', 'EEG'), good_data);
myCrit2 = spt.criterion.psd_ratio.new('Band1', [12 16;49 51;17 19], ...
    'Band2', [7 10]);
myPCA  = spt.pca.new(...
    'Var',          .995, ...
    'MinDimOut',    15, ...
    'MaxDimOut',    35);
myNode = bss_regr.new(...
    'DataSelector',     mySel, ...
    'Criterion',        myCrit2, ...
    'PCA',              myPCA, ...
    'BSS',              efica, ...
    'Name',             'psd_ratio');

nodeList = [nodeList {myNode}];


%%% Node: 
%%% The MUX noise is qualitively similar to PWL noise, so use a custom-made
%%% version of the hilbert.pwl criterion to try to identify them
mySel = cascade(sensor_class('Class', 'EEG'), good_data);
myCrit3 = spt.criterion.thilbert.new(...
    'Filter',   @(sr)filter.bpfilt('fp',[45,55;12 16]/(sr/2)), ...
    'MaxCard',  2);
myPCA  = spt.pca.new(...
    'Var',          .995, ...
    'MinDimOut',    15, ...
    'MaxDimOut',    35);
myNode = bss_regr.new(...
    'DataSelector',     mySel, ...
    'Criterion',        myCrit3, ...
    'PCA',              myPCA, ...
    'BSS',              efica, ...
    'Name',             'hilbert');

nodeList = [nodeList {myNode}];


%%% Node: 
%%% Standard EMG criterion
myNode = bss_regr.emg;
nodeList = [nodeList {myNode}];

%%% Node:
%%% Bonus node. Testing whether it is a good idea to remove a fair amount
%%% of spatially sparse components
mySel = cascade(sensor_class('Class', 'EEG'), good_data);
myCrit4 = spt.criterion.sgini.new;
myPCA  = spt.pca.new(...
    'Var',          .995, ...
    'MinDimOut',    15, ...
    'MaxDimOut',    35);
myNode = bss_regr.new(...
    'DataSelector',     mySel, ...
    'Criterion',        myCrit4, ...
    'PCA',              myPCA, ...
    'BSS',              efica, ...
    'Name',             'hilbert');

nodeList = [nodeList {myNode}];

%%% Node:
%%% A combination of qrs_erp, psd_ratio and thilbert
mySel = cascade(sensor_class('Class', 'EEG'), good_data);

myCritArray = {myCrit1, myCrit2, myCrit3};
    
myCrit5 = spt.criterion.mrank.mrank(...
    'Criteria', myCritArray, 'Weights', [0.33 0.33 0.33]);
    
myPCA  = spt.pca.new(...
    'Var',          .995, ...
    'MinDimOut',    15, ...
    'MaxDimOut',    35);
myNode = bss_regr.new(...
    'DataSelector',     mySel, ...
    'Criterion',        myCrit5, ...
    'PCA',              myPCA, ...
    'BSS',              efica, ...
    'Name',             'qrs-psd-hilbert');

nodeList = [nodeList {myNode}];

%%% The pipeline
myPipe = pipeline.new(...
    'NodeList',         nodeList, ...
    'Save',             true, ...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Name',             PIPE_NAME ...
    );


%% Select the relevant files and start the data processing jobs
switch lower(get_hostname),
    case 'somerenserver',
        regex = '_stage2\.pseth?$';
        files = finddepth_regex_match(INPUT_DIR, regex);
        % link2files works only under Mac OS X and Linux
        link2files(files, OUTPUT_DIR);
        regex = '_stage2\.pseth$';
        files = finddepth_regex_match(OUTPUT_DIR, regex);
        
        
    otherwise,
        error('The location of the batman dataset is not known');
        
end

run(myPipe, files{:});

