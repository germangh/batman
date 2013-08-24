% setup.m
%
% Update meegpipe 
%
%

UPDATE_MEEGPIPE = true;

CODE_DIR = '/data1/projects/batman/scripts/meegpipe';

if UPDATE_MEEGPIPE,
    batman.get_meegpipe(CODE_DIR);
else
    addpath(genpath(CODE_DIR)); %#ok<UNRCH>
end

%% Copy custom meegpipe configuration
% IMPORTANT: Since we are downloading the latest version of meegpipe
% everytime, any change that you may have made to the contents of the code
% directory will be lost (e.g. any modification of +meegpipe/meegpipe.ini
% will be lost). If you want to modify the configuration of meegpipe then
% you should instead modify +meg_mikex/meegpipe.ini. If you are performing
% the analysis on the somerengrid then the default meegpipe configuration
% is fine so this step is not really necessary.

eval('import mperl.file.spec.catfile');

% catdir is part of meegpipe
userConfig = catfile(batman.root_path, 'meegpipe.ini');
if exist(userConfig, 'file')
    copyfile(userConfig, CODE_DIR);
end