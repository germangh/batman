% setup.m
%
% Install meegpipe

clear all;
clear classes;


CODE_DIR = '/data1/projects/batman/scripts/meegpipe';

if ~exist(CODE_DIR, 'dir') || numel(dir(CODE_DIR)) < 3,
    batman.get_meegpipe(CODE_DIR);
else
    addpath(genpath(CODE_DIR));
end

%% Copy custom meegpipe configuration

% This configuration file is used e.g. to specify the locations of
% Fieldtrip and EEGLAB in this system

% catdir is part of meegpipe
userConfig = mperl.file.spec.catfile(batman.root_path, 'meegpipe.ini');
if exist(userConfig, 'file')
    copyfile(userConfig, CODE_DIR);
end