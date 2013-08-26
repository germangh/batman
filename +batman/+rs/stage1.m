% stage1.m
%
% Stage description:
%
% - Extraction of power ratio features for various EEG bands
%
% Pre-requisites:
%
% - The data has been succesfully pre-processed
% - batman.setup has been run just before running this script
%
%
% See also: batman

meegpipe.initialize;

import meegpipe.node.*;
import somsds.link2files;
import misc.get_hostname;
import misc.regexpi_dir;
import mperl.file.spec.catdir;
import mperl.file.find.finddepth_regex_match;
import mperl.join;

%% Analysis parameters

PIPE_NAME = 'rs-stage1';

USE_OGE = true;

DO_REPORT = true;

INPUT_DIR = '/data1/projects/batman/analysis/stage4_gherrero_130826-163240';
OUTPUT_DIR = ['/data1/projects/batman/analysis/' PIPE_NAME '_', ...
    get_username '_' datestr(now, 'yymmdd-HHMMSS')];

QUEUE = 'short.q@somerenserver.herseninstituut.knaw.nl';


%% Build the analysis pipeline

nodeList = {};

%%% Node: data import
myImporter = physioset.import.physioset('Precision', 'double');
myNode = physioset_import.new('Importer', myImporter);

nodeList = [nodeList {myNode}];

% note that we do not need to use a copy node since in this stage we are
% not modifying the data. We are simply reading it and extracting features.

%%% Node: get the spectral features

myNode = spectra.new;

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
regex = '_stage4\.pseth?$';
files = finddepth_regex_match(INPUT_DIR, regex);

link2files(files, OUTPUT_DIR);
regex = '_stage4\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

run(myPipe, files{:});

