% stage4.m
%
% Playing around with various criteria for removing ocular artifacts

% close all;
% clear all;
% clear classes;

import batman.get_username;

%% Analysis parameters

PIPE_NAME = 'stage4';

USE_OGE = true;

DO_REPORT = true;

INPUT_DIR = '/data1/projects/batman/analysis/stage3_gherrero_130823-175358';
OUTPUT_DIR = ['/data1/projects/batman/analysis/stage4_', get_username '_' ...
    datestr(now, 'yymmdd-HHMMSS')];

QUEUE = 'short.q@somerenserver.herseninstituut.knaw.nl';


%% Importing some pieces of meegpipe

% This import directives are used only for convenience so that we don't
% need to type the fully qualified names of certain meegpipe components
% that we use later. 

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

%%% Node: copy the data

myNode = copy.new;

nodeList = [nodeList {myNode}];


%%% Node: ECG
myNode = bss_regr.ecg;
nodeList = [nodeList {myNode}];

%%% Node: Reject obvious EOG components using their topography
myCrit = spt.criterion.topo_ratio.new(...
    'SensorsDen',  {'EEG 124', 'EEG 149', 'EEG 137', 'EEG 69', 'EEG 202', ...
    'EEG 95', 'EEG 178'}, ...
    'SensorsNum',  {'EEG 54', 'EEG 46', 'EEG 10', 'EEG 1'}, ...
    'MaxCard',  2, ...
    'MinCard',  5, ...
    'Max',      100);
myNode = bss_regr.eog('Criterion', myCrit, 'Name', 'eog-topo');
nodeList = [nodeList {myNode}];


% Node: Reject less obvious EOG components and other noise components. For
% this we use a combination of spectral ratios and fractal dimensions.
myCrit = spt.criterion.mrank.eog(...
    'MaxCard', 4, ...
    'MinCard', 1, ...
    'Max',     0.9, ...
    'Percentile', 90);
myNode = bss_regr.eog('Criterion', myCrit, 'Name', 'low-freq-noise');
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
regex = '_stage3\.pseth?$';
files = finddepth_regex_match(INPUT_DIR, regex);

link2files(files, OUTPUT_DIR);
regex = '_stage3\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

run(myPipe, files{:});

