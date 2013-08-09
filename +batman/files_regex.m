function regex = files_regex(subject, condition, block, lastProc, fExt)

import mperl.join;

if nargin < 5, fExt = ''; end

if nargin < 4, lastProc = ''; end

if nargin < 3, block = []; end

if nargin < 2 || isempty(condition),
    condition = {'rs', 'pvt'};
end

if nargin < 1 || isempty(subject),
    subject = 1:15;
end

if numel(subject) > 1,
    subjList = join('|', subject);
else
    subjList = num2str(subject);
end

if numel(condition) > 1,
    condList = join('|', condition);
else
    condList = condition{1};
end

if numel(block) > 1,
    blockList = join('|', block);
elseif ~isempty(block)
    blockList = num2str(block);
end

regex = ['batman_0+(' subjList ')_.+_(' condList ')'];

if ~isempty(block),
    regex = [regex '_(' blockList  ')'];
end

if ~isempty(lastProc),
    regex = [regex '.+' lastProc];
end

if ~isempty(fExt),
    regex = [regex '.*' fExt '$'];
end


end