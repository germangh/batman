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

import batman.*;
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

INPUT_DIR = '/data1/projects/batman/analysis/stage4_gherrero_130826-230806';
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

myNode = spectra.new(...
    'Channels2Plot', ...
    {...
    '^EEG 69$',  '^EEG 202$', '^EEG 95$', ... % T3, T4, T5
    '^EEG 124$', '^EEG 149$', '^EEG 137$', ... % O1, O2, Oz
    '^EEG 41$',  '^EEG 214$', '^EEG 47$', ... % F3, F4, Fz
    '.+' ...
    });

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

% Halt execution until there are no jobs running from stage4 of the 
% pre-processing chain. Otherwise there will be no files there to link to.
oge.wait_for_grid('stage4');

regex = '_stage4\.pseth?$';
files = finddepth_regex_match(INPUT_DIR, regex);

link2files(files, OUTPUT_DIR);
regex = '_stage4\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

run(myPipe, files{:});

