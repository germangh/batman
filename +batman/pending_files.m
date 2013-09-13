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

% List of files (symbolic links) which are newer than the corresponding 
% .meegpipe dir. This indicates that a user has manually deleted the link
% and by that he wants us to re-process that file. This is usually because
% the user has modified the runtime configuration (.ini files) within the
% .meegpipe directory.

% Is the link newer than the .meegpipe dir?
newFile = false(size(files));
for i = 1:numel(files)    
    dirList = dir(meegpipeDirs{i});
    if isempty(dirList), continue; end
    
    if ~exist(files{i}, 'file'), continue; end
    
    [stat, ~] = system('stat');
    if ispc || stat > 1,
        tmp = dir(files{i});
        if isempty(tmp), continue; end
        dateFile = tmp.datenum;
    else
        cmd = sprintf('stat %s', files{i});
        [~, res] = system(cmd);
        tmp = regexp(res, 'Modify:\s+(?<date>[^.]+)', 'names');
        dateFile = datenum(tmp.date);
    end
    newFile(i) = dirList(1).datenum < dateFile;
end

files = files(...
    (fileExists & ~alreadyDone & ~inQueue) | ... % A new file
    (newFile & alreadyDone & ~inQueue) ...      % User has modified .ini files 
    );

end