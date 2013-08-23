% stage3.m
%
% Removing artifacts

import batman.get_username;

%% Analysis parameters

PIPE_NAME = 'stage3';

USE_OGE = true;

DO_REPORT = true;


INPUT_DIR = '/data1/projects/batman/analysis/stage2_gherrero_130822-235627';
OUTPUT_DIR = ['/data1/projects/batman/analysis/stage3_', get_username '_' ...
    datestr(now, 'yymmdd-HHMMSS')];
CODE_DIR = '/data1/projects/batman/scripts/stage3';

QUEUE = 'short.q@somerenserver.herseninstituut.knaw.nl';

UPDATE_MEEGPIPE = true;

%% Download the latest version of meegpipe
% Be aware that this will cause the LATEST version of meegpipe to be
% downloaded and installed everytime you run this script. This is not a
% good idea if you are planning to analyze your data files in multiple runs
% of stage2 over different batches of data files. In the latter case you
% should comment this line after the first run of stage2 so that the stage2
% processing is always performed using the same version of meegpipe. It is
% OK though to use different versions of meegpipe in different processing
% stages (e.g. stage3 may use a newer version than stage2). 
%
% If you are planning to manually modify the default behavior of some of
% the nodes (e.g. the set of rejected channels in the bad_channels node), 
% then you MUST comment the line after modifying the corresponding .ini 
% file(s) and before you re-run this script. 

if UPDATE_MEEGPIPE,
    batman.get_meegpipe(CODE_DIR);
else
    addpath(genpath(CODE_DIR)); %#ok<UNRCH>
end

%% Importing some pieces of meegpipe

% This import directives are used only for convenience so that we don't
% need to type the fully qualified names of certain meegpipe components
% that we use later. Note that we need to use eval because the import
% directives need to be executed at runtime (since we are downloading and 
% adding meegpipe to the path during runtime as well). 

eval('import meegpipe.node.*');
eval('import somsds.link2files');
eval('import misc.regexpi_dir');
eval('import mperl.file.spec.*');
eval('import mperl.file.find.finddepth_regex_match');
eval('import mperl.join');
eval('import pset.selector.sensor_class');
eval('import pset.selector.good_data');
eval('import pset.selector.cascade');
eval('import spt.bss.*');

%% Copy custom meegpipe configuration
% IMPORTANT: Since we are downloading the latest version of meegpipe
% everytime, any change that you may have made to the contents of the code
% directory will be lost (e.g. any modification of +meegpipe/meegpipe.ini
% will be lost). If you want to modify the configuration of meegpipe then
% you should instead modify +meg_mikex/meegpipe.ini. If you are performing
% the analysis on the somerengrid then the default meegpipe configuration
% is fine so this step is not really necessary.

% This must come after downloading and importing the various meegpipe
% components because function catdir is part of meegpipe
userConfig = catfile(batman.root_path, 'meegpipe.ini');
if exist(userConfig, 'file')
    copyfile(userConfig, CODE_DIR);
end

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
mySel = cascade(sensor_class('Class', 'EEG'), good_data);
myCrit = spt.criterion.psd_ratio.new(...
    'Band1',    [12 16;49 51;17 19], ...
    'Band2',    [7 10], ...
    'MaxCard',  2, ...
    'Max',      @(x) min(median(x) + 4*mad(x), 50));

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


%%% Node: EOG

myNode = bss_regr.eog('IOReport', report.plotter.io);
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
regex = '_stage2\.pseth?$';
files = finddepth_regex_match(INPUT_DIR, regex);

link2files(files, OUTPUT_DIR);
regex = '_stage2\.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

run(myPipe, files{:});

