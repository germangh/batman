function files = pending_files(files)

meegpipeDirs = cellfun(@(x) regexprep(x, '\.[^.]+$', '.meegpipe'), files, ...
    'UniformOutput', false);

alreadyDone = cellfun(@(x) exist(x, 'dir')>0, meegpipeDirs);

fileExists = cellfun(@(x) exist(x, 'file')>0, files);

files = files(fileExists & ~alreadyDone);

end