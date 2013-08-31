function files = pending_files(pipe, files)

if isempty(files),
    files = {};
    return;
end

meegpipeDirs = cellfun(@(x) regexprep(x, '\.[^.]+$', '.meegpipe'), files, ...
    'UniformOutput', false);

alreadyDone = cellfun(@(x) exist(x, 'dir')>0, meegpipeDirs);

fileExists = cellfun(@(x) exist(x, 'file')>0, files);

inQueue = false(size(files));
pipeName = get_name(pipe);

for i = 1:numel(files)
   [~, name] = fileparts(files{i});
   if ~isempty(pipeName),
       jobName = [pipeName '-' name];
   else
       jobName = name;
   end
   [~, resp] = system(['qstat -j ' jobName]);
   inQueue = isempty(strfind(resp, 'jobs do not exist'));
end


files = files(fileExists & ~alreadyDone & ~inQueue);

end