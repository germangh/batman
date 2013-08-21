function get_meegpipe(codeDir, url)

if nargin < 1 || isempty(url),
    url = 'git://github.com/germangh/meegpipe';
end

installDir = catdir(codeDir, 'meegpipe');
if exist(installDir, 'dir'),
    rmdir(installDir, 's');
end
mkdir(installDir);
currDir = pwd;
cd(installDir);
system(sprintf('git clone %s', url));
cd(catdir(installDir, 'meegpipe'));
submodule_update([], true);
cd(currDir);

end