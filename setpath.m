function cfg = setpath()
% This script will initiate your session
% You must modify it manually for your own machine!

% Initiate data structure holding data
cfg = struct();

cfg.paths.task = pwd; % task dir
cfg.paths.parent = fileparts(cfg.paths.task); % parent dir
addpath(genpath(cfg.paths.task))

% get user name
user = getenv('USER');
if isempty(user)
  user = getenv('UserName');
end

% Add a case with my user, make a directory similiar to joaop
% Remember to ask joaop specifically and add the info here

switch user
    case 'Bruno Miranda'          % Tower computer

        cfg.paths.remote.study = 'Z:\Exp_2-optimized_video_rating'; % LAN
        cfg.paths.local.study  = 'C:\Exp_2_optimized-video_rating'; % Local
        
        try
            cd(cfg.paths.remote.study); 
            cfg.paths.study = cfg.paths.remote.study;
        catch
            cfg.paths.study = cfg.paths.local.study;            
        end

        % define paths for output data
        cfg.paths.sourcedata  = fullfile(cfg.paths.study,'sourcedata'); 
        cfg.paths.bids        = fullfile(cfg.paths.study,'bids'); 
        cfg.paths.results     = fullfile(cfg.paths.study,'results');
        cfg.paths.derivatives = fullfile(cfg.paths.study,'derivatives'); 

        subfolders = {'sourcedata', 'bids', 'results', 'derivatives'};
        for i = 1:numel(subfolders)
            cfg.paths.remote.(subfolders{i}) = fullfile(cfg.paths.remote.study, subfolders{i});
            cfg.paths.local.(subfolders{i}) = fullfile(cfg.paths.local.study, subfolders{i});            
            cfg.paths.(subfolders{i}) = fullfile(cfg.paths.study, subfolders{i});
        end
        
   
        % add to path
        addpath('C:\toolbox\Psychtoolbox')
        addpath('C:\toolbox\fieldtrip-20241025')
        addpath('C:\toolbox\eeglab2024.2')


    case 'NGR_FMUL'          % VR-accelerated computer


        cfg.paths.remote.study = 'Z:\Exp_2-optimized_video_rating'; % LAN
        cfg.paths.local.study  = 'C:\Exp_2_optimized-video_rating'; % Local
        
        try
            cd(cfg.paths.remote.study); 
            cfg.paths.study = cfg.paths.remote.study;
        catch
            cfg.paths.study = cfg.paths.local.study;            
        end

        % define paths for output data
        cfg.paths.sourcedata  = fullfile(cfg.paths.study,'sourcedata'); 
        cfg.paths.bidsroot    = fullfile(cfg.paths.study,'bids'); 
        cfg.paths.results     = fullfile(cfg.paths.study,'results');
        cfg.paths.derivatives = fullfile(cfg.paths.study,'derivatives'); 
    
        % add to path
        addpath('C:\toolbox\Psychtoolbox')
        addpath('C:\toolbox\fieldtrip-20241025')
        addpath('C:\toolbox\eeglab2024.2')

    case 'joaop'          % Personal computer

        cfg.paths.remote.study = 'Z:\Exp_2-optimized_video_rating'; % LAN
        cfg.paths.local.study  = 'C:\Exp_2_optimized-video_rating'; % Local
        
        try
            cd(cfg.paths.remote.study); 
            cfg.paths.study = cfg.paths.remote.study;
        catch
            cfg.paths.study = cfg.paths.local.study;            
        end

        % define paths for output data
        cfg.paths.sourcedata  = fullfile(cfg.paths.study,'sourcedata'); 
        cfg.paths.bidsroot    = fullfile(cfg.paths.study,'bids'); 
        cfg.paths.results     = fullfile(cfg.paths.study,'results');
        cfg.paths.derivatives = fullfile(cfg.paths.study,'derivatives'); 
    
        % add to path
        addpath('C:\toolbox\Psychtoolbox')
        addpath('C:\toolbox\fieldtrip-20241025')
        addpath('C:\toolbox\eeglab2024.2')

    case 'Administrator' % MSI computer

        cfg.paths.remote.study = 'Z:\Exp_2-optimized_video_rating'; % LAN
        cfg.paths.local.study  = 'C:\Exp_2_optimized-video_rating'; % Local
        
        try
            cd(cfg.paths.remote.study); 
            cfg.paths.study = cfg.paths.remote.study;
        catch
            cfg.paths.study = cfg.paths.local.study;            
        end

        % define paths for output data
        cfg.paths.sourcedata  = fullfile(cfg.paths.study,'sourcedata'); 
        cfg.paths.bidsroot    = fullfile(cfg.paths.study,'bids'); 
        cfg.paths.results     = fullfile(cfg.paths.study,'results');
        cfg.paths.derivatives = fullfile(cfg.paths.study,'derivatives'); 
    
        % add to path
        addpath('C:\toolbox\Psychtoolbox')
        addpath('C:\toolbox\fieldtrip-20241025')
        addpath('C:\toolbox\eeglab2024.2')
    
    otherwise
        error('The directories for the input and output data could not be found');
end

cd(cfg.paths.task);