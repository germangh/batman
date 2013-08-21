function get_meegpipe(codeDir, url)

if nargin < 2 || isempty(url),
    url = 'git://github.com/germangh/meegpipe';
end

if ismember(codeDir(end), {'/','\'}),
    codeDir(end) = [];
end
installDir = [codeDir filesep 'meegpipe'];
if exist(installDir, 'dir'),
    warning('off', 'MATLAB:RMDIR:RemovedFromPath');
    rmdir(installDir, 's');
    warning('on', 'MATLAB:RMDIR:RemovedFromPath');
end
mkdir(installDir);
currDir = pwd;
cd(installDir);
system(sprintf('git clone %s', url));
cd([installDir filesep 'meegpipe']);
submodule_update([], true);
cd(currDir);

end