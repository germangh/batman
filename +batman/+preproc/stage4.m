% stage4.m
%
% Stage description:
%
% - Removal of cardiac artifacts
% - Removal of obvious EOG artifacts using their topography
% - Removal of less obvious EOG and other noise components with low-freq
%   characteristics.
%
% Pre-requisites:
%
% - stage3 have been successfully completed
% - batman.setup has been run just before running this script
%
%
% See also: batman

meegpipe.initialize;

import batman.get_username;
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

%% Analysis parameters

PIPE_NAME = 'stage4';

SUBJECTS = 1:20;

BLOCKS = 1:14;

USE_OGE = true;

DO_REPORT = true;

INPUT_DIR = '/data1/projects/batman/analysis/stage3_gherrero_130823-175358';
OUTPUT_DIR = ['/data1/projects/batman/analysis/stage4_', get_username '_' ...
    datestr(now, 'yymmdd-HHMMSS')];

QUEUE = 'short.q@somerenserver.herseninstituut.knaw.nl';


%% Build the cleaning pipeline

nodeList = {};

%%% Node: data import
myImporter = physioset.import.physioset('Precision', 'double');
myNode = physioset_import.new('Importer', myImporter);

nodeList = [nodeList {myNode}];

%%% Node: copy the data

myNode = copy.new;

nodeList = [nodeList {myNode}];

%%% Node: Reject obvious EOG components using their topography
myNode = bss_regr.eog_egi256_hcgsn1('MinCard', 2, 'MaxCard', 5);
nodeList = [nodeList {myNode}];


%%% Node: ECG
myNode = bss_regr.ecg;
nodeList = [nodeList {myNode}];


%%% Node: Reject less obvious EOG components and other noise components. For
% this we use a combination of spectral ratios and fractal dimensions.
myCrit = spt.criterion.mrank.eog(...
    'MaxCard', 5, ...
    'MinCard', 1, ...
    'Max',     0.9, ...
    'Percentile', 90);
myNode = bss_regr.eog('Criterion', myCrit, 'Name', 'low-freq-noise');
nodeList = [nodeList {myNode}];

%%% Node: interpolate bad channels
myNode = chan_interp.new;
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
<<<<<<< HEAD
regex = ['0+(' join('|', SUBJECTS) ').+rs_(' join('|', BLOCKS), ')_stage3\.pseth?$'];
=======
oge.wait_for_grid('stage3');

regex = '_stage3\.pseth?$';
>>>>>>> 20c75589998bd13bb95a3792e58fd0fb17311270
files = finddepth_regex_match(INPUT_DIR, regex);

link2files(files, OUTPUT_DIR);
regex = '_stage3\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

run(myPipe, files{:});

