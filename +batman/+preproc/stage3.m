% stage3.m
%
% Stage description:
%
% - Removal or PWL and MUX-related artifacts
%
% Pre-requisites
%
% - preproc.stage2 has been successfully completed.
% - batman.setup has been run inmediately before running this script
%
% See also: batman

import batman.get_username;

%% Analysis parameters

PIPE_NAME = 'stage3';

USE_OGE = true;

DO_REPORT = true;


INPUT_DIR = '/data1/projects/batman/analysis/stage2_gherrero_130823-120023';

OUTPUT_DIR = ['/data1/projects/batman/analysis/stage3_', get_username '_' ...
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
import misc.copyfile;

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

%%% Node: remove PWL

myNode = bss_regr.pwl('IOReport', report.plotter.io);

nodeList = [nodeList {myNode}];


%%% Node: remove MUX noise

% MUX noise seems to appear only very rarely. Seems the purpose of this
% node is to reject only that type of noise, we set the Max threshold to a
% very large value to try to remove only true MUX-related components.
mySel = cascade(sensor_class('Class', 'EEG'), good_data);
myCrit = spt.criterion.psd_ratio.new(...
    'Band1',    [12 16;49 51;17 19], ...
    'Band2',    [7 10], ...
    'MaxCard',  2, ...
    'Max',      @(x) min(median(x) + 10*mad(x), 100));

myPCA  = spt.pca.new(...
    'Var',          .995, ...
    'MinDimOut',    15, ...
    'MaxDimOut',    35);
myNode = bss_regr.new(...
    'DataSelector',     mySel, ...
    'Criterion',        myCrit, ...
    'PCA',              myPCA, ...
    'BSS',              efica.new, ...
    'Name',             'mux-noise', ...
    'IOReport',         report.plotter.io);

nodeList = [nodeList {myNode}];

% We leave the EOG correction for stage4

%%% The pipeline
myPipe = pipeline.new(...
    'NodeList',         nodeList, ...
    'Save',             true, ...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Name',             PIPE_NAME ...
    );


%% Select the relevant files and start the data processing jobs

% Halt execution until there are no jobs running from stage2. Otherwise
% there will be no files there to link to.
oge.wait_for_grid('stage2');

regex = '_stage2\.pseth?$';
files = finddepth_regex_match(INPUT_DIR, regex);

link2files(files, OUTPUT_DIR);
regex = '_stage2\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

run(myPipe, files{:});

