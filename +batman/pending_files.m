function files = pending_files(files)

meegpipeDirs = cellfun(@(x) regexprep(x, '\.[^.]+$', '.meegpipe'), files, ...
    'UniformOutput', false);

alreadyDone = cellfun(@(x) exist(x, 'dir')>0, meegpipeDirs);

fileExists = cellfun(@(x) exist(x, 'file')>0, files);

inQueue = false(size(files));
for i = 1:numel(files)
   jobName = fileparts(files{i});
   [~, resp] = system(['qstat -j ' jobName]);
   inQueue = ~isempty(strfind(resp, 'jobs do not exist'));
end


files = files(fileExists & ~alreadyDone & ~inQueue);

end