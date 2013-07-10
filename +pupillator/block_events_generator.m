classdef block_events_generator < physioset.event.generat
    %  block_events_generator - Generate block events from counter channel
    %
    % See: <a href="matlab:misc.md_help('pupillator.block_events_generator')">misc.md_help(''pupillator.block_events_generator'')</a>

    properties
        DiffFilter = [0.1 0 0 0 0 0 0 0 -0.1];
        DiffTh     = 0.05;
        MinDur     = 3000;
        Discard    = 1000;
        NbBlocks   = 5;
    end






end