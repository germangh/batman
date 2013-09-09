function [ftripStr, condID, condName] = ft_freqstatistics(varargin)
% ft_freqstatistics
% ====
%
% Fieldtrip-based spectral power statistics
%
% ## Usage synopsis:
%
% ````matlab
% import batman.stats.ft_freqstatistics;
% ft_freqstatistics(data, condID, condNames);
% ft_freqstatistics('/path/to/file.mat');
% ft_freqstatistics;
% ````
%
% Where
%
% `data` is a cell array where each cell represents one experimental
% condition and contains a cell array of paths to .pseth files associated to
% that condition.
%
% `condID`  and `condNames` are both cell arrays of strings of the same
% dimensions as `data`. Each cell of these cell arrays contains,
% respectively, the ID and the name of an experimental condition.
%
% ## Notes
%
% * The user may also provide as single input argument the full path to a
% .mat file that contains the cell arrays `data`, `condID` and `condNames`.
%
% * Calling this script without input arguments is equivalent to calling:
%
% ````matlab
% ft_freqstatistics(['/data1/projects/batman/analysis/cleaning/' ...
%       'condition_aggregates.mat']);
% ````
%
%
% See also: batman.preproc.aggregate_physiosets
import misc.process_arguments;

if nargin == 0,
    varargin = {['/data1/projects/batman/analysis/cleaning/' ...
        'condition_aggregates.mat']};
end

if numel(varargin) == 1,
    load(varargin{1});
end

% Remove the dpg=2 conditions
condNames(:,:,3) = [];
data(:,:,3)      = [];

cfg = [];
cfg.method     = 'mtmfft';
cfg.output     = 'pow';
cfg.taper      = 'hanning';
cfg.keeptrials = 'no';

myImporter = physioset.import.physioset;

% Third order interactions
for parcVarItr = 1:3
   parcLevels   = cell(1, 2);
   parcVarLast  = [setdiff(1:3, parcVarItr), parcVarItr];
   thisData     = permute(data, parcVarLast);
   thisCond     = permute(condNames, parcVarLast);
   
   for parcLevelItr = 1:2      
       thisData = data{1,1,1};      
       thisData = import(myImporter, thisData{:});
       thisData = fieldtrip(thisData{:}, 'BadData', 'donothing');
       thisData = cellfun(@(x) ft_freqanalysis(cfg, x), thisData);
       parcLevel{parcLevelItr} = ft_freqanalysis(cfg, thisData{:});
       for i = 1:2
           for j = 1:2
                              
           end
       end
   end    
end



end