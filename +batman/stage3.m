% stage3.m
%
% Removing artifacts


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

PIPE_NAME = 'stage3';

CONDITIONS = {'rs'};

BLOCKS = 1:14;

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

OUTPUT_DIR = catdir(ROOT_DIR, ['stage3_' datestr(now, 'yymmdd-HHMMSS')]);


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


%%% Node: remove EOG

myNode = bss_regr.eog(NaN, 'IOReport', report.plotter.io, 'MinPCs', 15);
nodeList = [nodeList {myNode}];


%%% Node: remove PWL

myNode = bss_regr.pwl(NaN, 'IOReport', report.plotter.io, 'MinPCs', 15);

nodeList = [nodeList {myNode}];


%%% Node: remove ECG

myNode = bss_regr.ecg(NaN, 'IOReport', report.plotter.io, 'MinPCs', 15);

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

