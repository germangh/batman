% rs
%
% Extraction of power ratio features from RS epochs
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

PIPE_NAME = 'rs-features';

USE_OGE = true;

DO_REPORT = true;

% For now:
INPUT_DIR = ['/data1/projects/batman/analysis/stage2_4_' get_username];
%INPUT_DIR = ['/data1/projects/batman/analysis/cleaning_' get_username];

OUTPUT_DIR = ['/data1/projects/batman/analysis/rs_features_' get_username];

QUEUE = 'short.q@somerenserver.herseninstituut.knaw.nl';


%% Build the analysis pipeline

nodeList = {};

%% Node: data import
myImporter = physioset.import.physioset('Precision', 'double');
myNode = physioset_import.new('Importer', myImporter);

nodeList = [nodeList {myNode}];

% We don't need to copy the data because we are not going to modify it.

%% Node: get the spectral features (power ratios)
myNode = spectra.new(...
    'Channels2Plot', ...
    {...
    '^EEG 69$',  '^EEG 202$', '^EEG 95$', ... % T3, T4, T5
    '^EEG 124$', '^EEG 149$', '^EEG 137$', ... % O1, O2, Oz
    '^EEG 41$',  '^EEG 214$', '^EEG 47$', ... % F3, F4, Fz
    '.+' ...
    }, 'Name', 'power-ratios' ...
    );

nodeList = [nodeList {myNode}];

%% Node: get the spectral features (raw power values, not ratios)

% The default spectral features: power ratios in various classical EEG
% bands
myROIs = spectra.eeg_bands;

% We modify the default spectral features so that they become raw power
% values instead of power ratios
bandNames = keys(myROIs);
for bandItr = 1:numel(bandNames)
    % The current feature specfication: {targetBand;refBand}
    this = myROIs(bandNames{bandItr});
    % Make the refBand empty, which means: return raw power in targetBand
    this{2} = [];
    myROIs(bandNames{bandItr}) = this;
end

myNode = spectra.new(...
    'Channels2Plot', ...
    {...
    '^EEG 69$',  '^EEG 202$', '^EEG 95$', ... % T3, T4, T5
    '^EEG 124$', '^EEG 149$', '^EEG 137$', ... % O1, O2, Oz
    '^EEG 41$',  '^EEG 214$', '^EEG 47$', ... % F3, F4, Fz
    '.+' ...
    }, ...
    'ROI', myROIs, 'Name', 'raw-power' ...
    );

nodeList = [nodeList {myNode}];


%% The pipeline
myPipe = pipeline.new(...
    'NodeList',         nodeList, ...
    'Save',             false, ...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Name',             PIPE_NAME ...
    );


%% Select the relevant files and start the data processing jobs

% Halt execution until the cleaning jobs finish
% oge.wait_for_grid('cleaning'); % 

%regex = '_cleaning\.pseth?$';
regex = '_stage2-4.pseth?$';
files = finddepth_regex_match(INPUT_DIR, regex);

link2files(files, OUTPUT_DIR);
%regex = '_cleaning\.pseth$';
regex = '_stage2-4.pseth$';
files = finddepth_regex_match(OUTPUT_DIR, regex);

run(myPipe, files{:});

