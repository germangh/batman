classdef block_events_generator < physioset.event.generator
    %  block_events_generator - Generate block events from counter channel
    %
    % See: <a href="matlab:misc.md_help('pupillator.block_events_generator')">misc.md_help(''pupillator.block_events_generator'')</a>
    
    properties
        DiffFilt = [0.1 0 0 0 0 0 0 0 -0.1];
        DiffTh     = 0.05;
        MinDur     = 3000;
        Discard    = 1000;
    end
    
    methods
        %% Consistency checks to be done
        
        %% physioset.event.generator interface
        function evArray = generate(obj, data, rep, varargin)
            import misc.csvread;
            import mperl.file.spec.catfile;
            import misc.unique_filename;
            import plot2svg.plot2svg;
            import inkscape.svg2png;
            import mperl.join;
            import physioset.import.pupillator;
            
              % Read the protocol information
            prot = csvread([pupillator.root_path filesep 'protocol.csv']);
            
            subjCol  = ismember(prot(1,:), 'Subject');
            seqCol   = ismember(prot(1,:), 'Sequence');
            cond1Col = ismember(prot(1,:), 'Condition1');
            cond2Col = ismember(prot(1,:), 'Condition2');
            measCol  = ismember(prot(1,:), 'Measurement');
            sexCol   = ismember(prot(1,:), 'Sex');
            
            dataName = get_name(data);
            
            regex = ['(?<subj>\d\d\d\d).+(?<tod>afternoon|morning).+' ...
                '(?<pos>sitting|supine)'];
            tokens = regexp(dataName, regex, 'names');
            
            
            rowIdx = ...
                ismember(prot(:, subjCol), tokens.subj) & ...
                ismember(prot(:, cond1Col), tokens.tod) & ...
                ismember(prot(:, cond2Col), tokens.pos);
            
            
            seq = prot{rowIdx, seqCol};

            % The counter channel is the last one
            counter = data(end,:);
            
            diffCntr = filter(obj.DiffFilt, 1, counter);
            
            diffCntr(1:obj.Discard) = 0;
            diffCntr(abs(diffCntr) < obj.DiffTh) = 0;
            diffCntr = abs(diffCntr);
            
            blockOnset = [];
            while numel(blockOnset) <= numel(seq) && any(diffCntr > eps)
                [~, thisOnset] = max(diffCntr);
                blockOnset = [blockOnset; thisOnset]; %#ok<AGROW>
                diffCntr(max(1, thisOnset-floor(obj.MinDur/2)):...
                    min(numel(diffCntr), thisOnset + ...
                    floor(obj.MinDur/2))) = 0;
            end
            
            blockOnset = sort(blockOnset, 'ascend');
           
            % Onset of red and blue
            redOnset = blockOnset(counter(blockOnset) > 4.5 & ...
                counter(blockOnset) < 5.5);
            blueOnset = blockOnset(counter(blockOnset) > 5.5);
            
            blockDur = round((blueOnset - redOnset)/2);
            
            % How many dark blocks at the beginning
            [~, darkBegin] = regexp(seq, '^D+');
            darkEnd = regexp(seq, 'D+$');
            darkEnd = numel(seq) - darkEnd + 1;
            
            first = redOnset - blockDur*darkBegin;
            last  = blueOnset + blockDur*(darkEnd+1);
            blockOnset = round(linspace(first, last, numel(seq)+1));
            blockOnset = blockOnset(1:end-1);
            
            outOfRange = blockOnset < 1 | blockOnset > size(data,2);
            if any(outOfRange),
                error('block_events_generator:OutOfRange', ...
                    'Blocks with indices [%s] are out of range', ...
                    join(',', find(outOfRange)));                
            end            
          
            % There are three sub-blocks within each block, of durations 1,
            % 3 and 1 mins.
            oneMin = round(blockDur/5);
            threeMins = blockDur - 2*oneMin;
            relOnsets = zeros(numel(blockOnset), 3);
            relOnsets(:,2) = oneMin;
            relOnsets(:,3) = oneMin+threeMins;
            samplIdx = repmat(blockOnset(:), 1, 3) + relOnsets;
            samplIdx = sort(samplIdx(:));
            samplIdx = [samplIdx; samplIdx(end)+oneMin];
            
       
            [~, samplTime] = get_sampling_time(data, samplIdx);
            evArray = pupillator.block_events(samplIdx, samplTime, seq);
            
            if ~isempty(rep),
               % Generate a simple event generation report
               myGallery = report.gallery.new;
               
               figure('Visible', 'off');
               
               % In minutes
               relSamplTime = get_sampling_time(data)/60;
               
               plot(relSamplTime, counter, 'k-');
               hold on;
               h = stem(relSamplTime(blockOnset), counter(blockOnset), 'r');
               set(h, 'MarkerSize', 3, 'MarkerFaceColo', 'red');
               xlabel('minutes (from recording onset)');
               ylabel('counter');
               
               for i = 1:numel(blockOnset)
                   label = get(evArray(i), 'Type');
                   h = text(relSamplTime(blockOnset(i)), ...
                       counter(blockOnset(i)), [' ' label]);
                   set(h, 'Rotation', 90);
               end
               
               fileName = catfile(get_rootpath(rep), 'counter.svg');
               fileName = unique_filename(fileName);
               caption  = ...
                   'Counter values and locations of the generated events';
               evalc('plot2svg(fileName, gcf);');
               myGallery = add_figure(myGallery, fileName, caption);
               
               svg2png(fileName);
               
               close;
               
               fprintf(rep, myGallery);
               
            end
            
            % Add also some meta-information
            % This should be done in a specific "meta" node
            measDay = str2double(prot{rowIdx, measCol});
            sex     = prot{rowIdx, sexCol};
            set_meta(data, 'Measurement', measDay);
            set_meta(data, 'Sex', sex);
            
            % Add the meta-information also to the blocks, to be able to
            % extract it easily in the feature extraction stage
            for i = 1:numel(evArray), 
               evArray(i) = set_meta(evArray(i), 'Measurement', measDay);
               evArray(i) = set_meta(evArray(i), 'Sex', sex);
            end
                
            
        end
        
        
        %% Constructor
        function obj = block_events_generator(varargin)
            
            import misc.process_arguments;
            
            opt.DiffFilt = [0.1 0 0 0 0 0 0 0 -0.1];
            opt.DiffTh     = 0.05;
            opt.MinDur     = 3000;
            opt.Discard    = 1000;
           
            [~, opt] = process_arguments(opt, varargin);
            
            obj.DiffFilt = opt.DiffFilt;
            obj.DiffTh     = opt.DiffTh;
            obj.MinDur     = opt.MinDur;
            obj.Discard    = opt.Discard;
          
        end
        
        
        
        
        
        
    end
    
end