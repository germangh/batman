function [status, MEh] = test1()
% TEST1 - Tests basic node functionality

import mperl.file.spec.*;
import pupillator.nodes.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;

MEh     = [];

DATA_URL = ['http://kasku.org/data/meegpipe/' ...
    'pupw_0001_pupillometry_afternoon-sitting_1.csv'];

initialize(5);

%% Create a new session
try
    
    name = 'create new session';
    warning('off', 'session:NewSession');
    session.instance;
    warning('on', 'session:NewSession');
    hashStr = DataHash(randn(1,100));
    session.subsession(hashStr(1:5));
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
end


%% default constructor
try
    
    name = 'constructor';
    pd_preproc.new; 
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor with config options
try
    
    name = 'construct pd_preproc node with custom XCal';
    myNode = pd_preproc.new('XCal', 0);
    ok(get_config(myNode, 'XCal') == 0, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data
try
    
    name = 'process sample data';
    
    % random data with sinusolidal trend
    folder = session.instance.Folder;    
    file = catfile(folder, 'sample.csv');
    urlwrite(DATA_URL, file);    
    warning('off', 'sensors:InvalidLabel');
    data = import(physioset.import.pupillator, file);
    warning('on', 'sensors:InvalidLabel');
    
    myNode = pd_preproc.new;
    run(myNode, data);
    
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end



%% Cleanup
try
    
    name = 'cleanup';
    clear data dataCopy;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();