% rs
%
% Extraction of power ratio features from RS epochs
%
%
% See also: batman

import batman.*;


%% Analysis parameters

USE_OGE = true;

DO_REPORT = true;

INPUT_DIR = '/data1/projects/batman/analysis/cleaning';
if ~strcmp(get_username, 'meegpipe')
    INPUT_DIR = [INPUT_DIR '_' get_username];
end

OUTPUT_DIR = '/data1/projects/batman/analysis/rs';

if ~strcmp(get_username, 'meegpipe')
    OUTPUT_DIR = [OUTPUT_DIR '_' get_username];
end

QUEUE = 'short.q@somerenserver.herseninstituut.knaw.nl';

PAUSE_PERIOD = 3*60; % Check for new input files every PAUSE_PERIOD seconds

%% Importing bits and pieces from meegpipe
import meegpipe.node.*;
import somsds.link2files;
import misc.get_hostname;
import misc.regexpi_dir;
import mperl.file.spec.catdir;
import mperl.file.find.finddepth_regex_match;
import mperl.join;

%% Build the analysis pipeline

% We actually have three different pipelines here. One for absolute (Cz)
% reference, one for average reference, and one for linked mastoids ref.

nodeList        = {};
nodeListAvg     = {};
nodeListLinked  = {};


%% Node: data import
myImporter = physioset.import.physioset('Precision', 'double');
myNode = physioset_import.new('Importer', myImporter);

nodeList        = [nodeList {myNode}];
nodeListAvg     = [nodeListAvg {clone(myNode)}];
nodeListLinked  = [nodeListLinked {clone(myNode)}];

%% Node: copy the data (if we are planning to re-reference it later) 

myNode = copy.new;

% If we don't re-reference we are not modifying the data so no need to copy
nodeListAvg     = [nodeListAvg {clone(myNode)}];
nodeListLinked  = [nodeListLinked {clone(myNode)}];

%% Node: average ref (remove if you want to use original ref)
myNodeAvg    = reref.avg; 
myNodeLinked = reref.linked('EEG 190', 'EEG 94');
nodeListAvg     = [nodeListAvg {clone(myNodeAvg)}];
nodeListLinked  = [nodeListLinked {clone(myNodeLinked)}];

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

nodeList        = [nodeList {myNode}];
nodeListAvg     = [nodeListAvg {clone(myNode)}];
nodeListLinked  = [nodeListLinked {clone(myNode)}];

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

nodeList        = [nodeList {myNode}];
nodeListAvg     = [nodeListAvg {clone(myNode)}];
nodeListLinked  = [nodeListLinked {clone(myNode)}];

%% The pipelines
myPipe = pipeline.new(...
    'NodeList',         nodeList, ...
    'Save',             false, ...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Name',             'spectra-absref' ...
    );

myPipeAvg = pipeline.new(...
    'NodeList',         nodeListAvg, ...
    'Save',             false, ...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Name',             'spectra-avgref' ...
    );

myPipeLinked = pipeline.new(...
    'NodeList',         nodeListLinked, ...
    'Save',             false, ...
    'OGE',              USE_OGE, ...
    'GenerateReport',   DO_REPORT, ...
    'Name',             'spectra-linkedref' ...
    );


%% Wait for files and start the data processing jobs

while true
     
    fprintf('(features-rs) Checked for new input files on %s ...\n\n', ...
        datestr(now));
    
    regex = '_\d+\.pseth?$';
    files = finddepth_regex_match(INPUT_DIR, regex);
    
    link2files(files, OUTPUT_DIR);
    regex = '_\d+\.pseth$';
    files = finddepth_regex_match(OUTPUT_DIR, regex);
    
    pending = pending_files(myPipe, files);
    
    if ~isempty(pending),
        run(myPipe, pending{:});
    end
    
    pendingAvg = pending_files(myPipeAvg, files);
    
    if ~isempty(pendingAvg),
        run(myPipeAvg, pendingAvg{:});
    end
    
    pendingLinked = pending_files(myPipeLinked, files);
    
    if ~isempty(pendingLinked),
        run(myPipeLinked, pendingLinked{:});
    end
    
    pause(PAUSE_PERIOD);
    
end
