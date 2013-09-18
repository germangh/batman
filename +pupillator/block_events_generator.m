classdef block_events_generator < physioset.event.generator
    %  block_events_generator - Generate block events from counter channel
    %
    % See: <a href="matlab:misc.md_help('pupillator.block_events_generator')">misc.md_help(''pupillator.block_events_generator'')</a>
    
    properties
        DiffFilt = [0.1 0 0 0 0 0 0 0 -0.1];
        DiffTh     = 0.05;
        MinDur     = 3000;
        Discard    = 1000;
        NbBlocks   = 7;
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
            
            % The counter channel is the last one
            counter = data(end,:);
            
            diffCntr = filter(obj.DiffFilt, 1, counter);
            
            diffCntr(1:obj.Discard) = 0;
            diffCntr(abs(diffCntr) < obj.DiffTh) = 0;
            diffCntr = abs(diffCntr);
            
            blockOnset = [];
            while numel(blockOnset) <= obj.NbBlocks && any(diffCntr > eps)
                [~, thisOnset] = max(diffCntr);
                blockOnset = [blockOnset; thisOnset]; %#ok<AGROW>
                diffCntr(max(1, thisOnset-floor(obj.MinDur/2)):...
                    min(numel(diffCntr), thisOnset + ...
                    floor(obj.MinDur/2))) = 0;
            end
            
            blockOnset = sort(blockOnset, 'ascend');
            
            % Split the first and the last epochs into two blocks (pupw specific)
            blockOnset = [blockOnset(1); ...
                blockOnset(1)+ceil(diff(blockOnset(1:2))/2); ...
                blockOnset(2:end-1);...
                blockOnset(end-1)+ceil(diff(blockOnset(end-1:end))/2); ...
                blockOnset(end)];
            
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
            
            blockOnset = blockOnset(1:obj.NbBlocks);
            [~, samplTime] = get_sampling_time(data, blockOnset);
            evArray = physioset.event.event(blockOnset);
       
            for i = 1:obj.NbBlocks
                
                switch seq(i)
                    case 'D'
                        if i < numel(seq) && strcmp(seq(i+1), 'R'),
                            type = 'pre-red';    
                        elseif i > 1 && ismember(seq(i-1), {'R','B'}),
                            if strcmp(seq(i-1), 'R'),
                                type = 'post-red';
                            else
                                type = 'post-blue';
                            end
                        else
                            type = 'dark';
                        end
                    case 'R'
                        type = 'red';
                    case 'B'
                        type = 'blue';
                    otherwise,
                        error('Unknown sequence code %s', seq(i));
                end
                evArray(i) = set_type(evArray(i), type);
                evArray(i).Value = i;
                evArray(i) = set_duration(evArray(i), 5*60*data.SamplingRate);
                evArray(i) = set(evArray(i), 'Time', samplTime(i));
                
            end
            
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
            set_meta(data, 'Measurement', str2double(prot{rowIdx, measCol}));
            set_meta(data, 'Sex', prot{rowIdx, sexCol});
            
        end
        
        
        %% Constructor
        function obj = block_events_generator(varargin)
            
            import misc.process_arguments;
            
            opt.DiffFilt = [0.1 0 0 0 0 0 0 0 -0.1];
            opt.DiffTh     = 0.05;
            opt.MinDur     = 3000;
            opt.Discard    = 1000;
            opt.NbBlocks   = 7;
            
            [~, opt] = process_arguments(opt, varargin);
            
            obj.DiffFilt = opt.DiffFilt;
            obj.DiffTh     = opt.DiffTh;
            obj.MinDur     = opt.MinDur;
            obj.Discard    = opt.Discard;
            obj.NbBlocks   = opt.NbBlocks;
            
        end
        
        
        
        
        
        
    end
    
end