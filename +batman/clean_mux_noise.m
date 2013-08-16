% clean_mux_noise.m
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
    ['clean-mux-noise_' datestr(now, 'yymmdd-HHMMSS')]);


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


% %%% Node: 
% %%% Use the Gini index to rank components according to their sparseness
% mySel = cascade(sensor_class('Class', 'EEG'), good_data);
% myCrit = spt.criterion.tgini.new;
% myPCA  = spt.pca.new(...
%     'Var',          .9975, ...
%     'MinDimOut',    15, ...
%     'MaxDimOut',    35);
% myNode = bss_regr.new(...
%     'DataSelector',     mySel, ...
%     'Criterion',        myCrit, ...
%     'PCA',              myPCA, ...
%     'BSS',              efica, ...
%     'Name',             'tgini');
% 
% nodeList = [nodeList {myNode}];
% 
% 
% %%% Node: 
% %%% Use the spatial Gini index to rank components according to their 
% %%% spatial sparseness. The MUX noise components seem to be spatially
% %%% sparse.
% mySel = cascade(sensor_class('Class', 'EEG'), good_data);
% myCrit = spt.criterion.sgini.new;
% myPCA  = spt.pca.new(...
%     'Var',          .9975, ...
%     'MinDimOut',    15, ...
%     'MaxDimOut',    35);
% myNode = bss_regr.new(...
%     'DataSelector',     mySel, ...
%     'Criterion',        myCrit, ...
%     'PCA',              myPCA, ...
%     'BSS',              efica, ...
%     'Name',             'sgini');
% 
% nodeList = [nodeList {myNode}];


%%% Node: 
%%% Use the fractal dimension to rank components according to their
%%% temporal sparseness
mySel = cascade(sensor_class('Class', 'EEG'), good_data);
myCrit = spt.criterion.tfd.new;
myPCA  = spt.pca.new(...
    'Var',          .9975, ...
    'MinDimOut',    15, ...
    'MaxDimOut',    35);
myNode = bss_regr.new(...
    'DataSelector',     mySel, ...
    'Criterion',        myCrit, ...
    'PCA',              myPCA, ...
    'BSS',              efica, ...
    'Name',             'tfd');

nodeList = [nodeList {myNode}];


%%% Node: 
%%% The MUX noise seems to have a peak at 14 Hz and 50 Hz
mySel = cascade(sensor_class('Class', 'EEG'), good_data);
myCrit = spt.criterion.psd_ratio.new('Band1', [12 16;49 51;17 19], ...
    'Band2', [7 10]);
myPCA  = spt.pca.new(...
    'Var',          .995, ...
    'MinDimOut',    15, ...
    'MaxDimOut',    35);
myNode = bss_regr.new(...
    'DataSelector',     mySel, ...
    'Criterion',        myCrit, ...
    'PCA',              myPCA, ...
    'BSS',              efica, ...
    'Name',             'psd_ratio');

nodeList = [nodeList {myNode}];

%%%

% %%% Node: 
% %%% Standard EOG criterion
% mySel = cascade(sensor_class('Class', 'EEG'), good_data);
% myCrit = spt.criterion.mrank.eog;
% myPCA  = spt.pca.new(...
%     'Var',          .995, ...
%     'MinDimOut',    15, ...
%     'MaxDimOut',    35);
% myNode = bss_regr.new(...
%     'DataSelector',     mySel, ...
%     'Criterion',        myCrit, ...
%     'PCA',              myPCA, ...
%     'BSS',              efica, ...
%     'Name',             'eog');
% 
% nodeList = [nodeList {myNode}];

%%% Node: 
%%% Standard PWL criterion
mySel = cascade(sensor_class('Class', 'EEG'), good_data);
myCrit = spt.criterion.thilbert.pwl;
myPCA  = spt.pca.new(...
    'Var',          .995, ...
    'MinDimOut',    15, ...
    'MaxDimOut',    35);
myNode = bss_regr.new(...
    'DataSelector',     mySel, ...
    'Criterion',        myCrit, ...
    'PCA',              myPCA, ...
    'BSS',              efica, ...
    'Name',             'pwl');

nodeList = [nodeList {myNode}];


%%% Node: 
%%% Standard EMG criterion
mySel = cascade(sensor_class('Class', 'EEG'), good_data);
myDrit   =  spt.criterion.psd_ratio.emg; 
myPCA  = spt.pca.new(...
    'Var',          .995, ...
    'MinDimOut',    15, ...
    'MaxDimOut',    35);
myNode = bss_regr.new(...
    'DataSelector',     mySel, ...
    'Criterion',        myCrit, ...
    'PCA',              myPCA, ...
    'BSS',              efica, ...
    'Name',             'ecg');

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

