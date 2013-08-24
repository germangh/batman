% stage4.m
%
% Getting spectral features
%
% 

meegpipe.initialize;

import meegpipe.node.*;
import somsds.link2files;
import misc.get_hostname;
import misc.regexpi_dir;
import mperl.file.spec.catdir;
import mperl.file.find.finddepth_regex_match;
import mperl.join;

%% Analysis parameters

SUBJECTS = 1:7;

PIPE_NAME = 'stage4';

CONDITIONS = {'rs'};

BLOCKS = 1:14;

USE_OGE = true;

DO_REPORT = true;

switch lower(get_hostname)
    case 'somerenserver'
        ROOT_DIR = '/data1/projects/batman/analysis';
        INPUT_DIR = catdir(ROOT_DIR, 'stage3');
        
    case 'nin271',
        INPUT_DIR = 'D:\data';
        
    otherwise,
        error('The location of the batman dataset is not known');
        
end

OUTPUT_DIR = catdir(ROOT_DIR, ['stage4_' datestr(now, 'yymmdd-HHMMSS')]);


%% Build the cleaning pipeline

nodeList = {};

%%% Node: data import
myImporter = physioset.import.physioset('Precision', 'double');
myNode = physioset_import.new('Importer', myImporter);

nodeList = [nodeList {myNode}];

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
switch lower(get_hostname),
    case 'somerenserver',
        regex = '_stage3\.pseth?$';
        files = finddepth_regex_match(INPUT_DIR, regex);
        % link2files works only under Mac OS X and Linux
        link2files(files, OUTPUT_DIR);
        regex = '_stage3\.pseth$';
        files = finddepth_regex_match(OUTPUT_DIR, regex);
        
        
    otherwise,
        error('The location of the batman dataset is not known');
        
end

run(myPipe, files{:});

