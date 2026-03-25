function cfg = settings_main()
% function containing settings for running the main task

% Init pc-specific paths and variables via setpath
cfg = setpath();

% Testing
cfg.debug = false;
if cfg.debug
    Screen('Preference','Verbosity', 1);
    Screen('Preference','Warnings', 1);
    Screen('Preference', 'SkipSyncTests', 1);
    VBLSyncTest(630) % save figures
else
    Screen('Preference', 'SkipSyncTests', 0);
end

% Training
cfg.training = false;
if cfg.training
    warning('Running in training mode')
    a = input('Press k to continue...\n','s');
    if ~strcmpi(a,'k')
        clearvars
        return
    end
end

% Paths
cfg.paths.allstim_path  = fullfile(cfg.paths.local.sourcedata, 'supp', 'allStimuli');
cfg.paths.stim_path     = fullfile(cfg.paths.local.sourcedata, 'supp', 'stimuli');
cfg.paths.logs_path     = fullfile(cfg.paths.sourcedata, 'supp', 'logfiles');
cfg.paths.event_path    = fullfile(cfg.paths.sourcedata, 'supp', 'events');
cfg.paths.sequence_path = fullfile(cfg.paths.sourcedata, 'supp', 'sequences');
cfg.paths.data_path     = fullfile(cfg.paths.sourcedata, 'data');

% SAM mannekins path
cfg.paths.rating_images = cfg.paths.allstim_path; 

cfg.rating.sam.valence = fullfile(cfg.paths.rating_images, 'valence.png');
cfg.rating.sam.arousal = fullfile(cfg.paths.rating_images, 'arousal.png');

%Building the questions
cfg.rating.items = cell(17,1);

cfg.rating.items{1}  = struct('type','mcq','name','familiar',  'question','Are you familiar with the food item?', ...
                              'options',{{'Yes','No'}});
cfg.rating.items{2}  = struct('type','mcq','name','eaten',     'question','Have you ever eaten the food item?', ...
                              'options',{{'Yes','No'}});
cfg.rating.items{3}  = struct('type','mcq','name','calory',    'question','Do you consider the food item high or low-calory?', ...
                              'options',{{'High-calory','Low-calory'}});
cfg.rating.items{4}  = struct('type','mcq','name','processed', 'question','Do you consider the food item processed or unprocessed/natural?', ...
                              'options',{{'Processed','Natural'}});
cfg.rating.items{5}  = struct('type','mcq','name','colour',    'question','In terms of colour, do you consider the food item to be ...', ...
                              'options',{{'Predominantly red','Predominantly green/blue','Particularly colourful','Particularly colourless','None of the above'}});

cfg.rating.items{6}  = struct('type','vas','name','arousal_video',   'question','How arousing was the video?', ...
                              'anchors',{{'Not at all','Very'}}, 'image','arousal');
cfg.rating.items{7}  = struct('type','vas','name','arousal_sound',   'question','How arousing was the sound?', ...
                              'anchors',{{'Not at all','Very'}});
cfg.rating.items{8}  = struct('type','vas','name','pleasant_video',  'question','How pleasant was the video?', ...
                              'anchors',{{'Not at all','Very'}}, 'image','valence');
cfg.rating.items{9}  = struct('type','vas','name','pleasant_sound',  'question','How pleasant was the sound?', ...
                              'anchors',{{'Not at all','Very'}});

cfg.rating.items{10} = struct('type','vas','name','fulfillment', 'question','How much fulfillment/satisfaction did this video cause?', ...
                              'anchors',{{'Very unsatisfied','Very satisfied'}});
cfg.rating.items{11} = struct('type','vas','name','fear',        'question','How much fear did this video cause?', ...
                              'anchors',{{'Very fearful','Very fearless'}});
cfg.rating.items{12} = struct('type','vas','name','guilt',       'question','How much guilt did this video cause?', ...
                              'anchors',{{'Very guilty','Very unguilty'}});
cfg.rating.items{13} = struct('type','vas','name','shame',       'question','How much shame did this video cause?', ...
                              'anchors',{{'Very ashamed','Very unashamed'}});
cfg.rating.items{14} = struct('type','vas','name','anger',       'question','How much anger did this video cause?', ...
                              'anchors',{{'Very angry','Very peaceful'}});
cfg.rating.items{15} = struct('type','vas','name','disgust',     'question','How much disgust did this video cause?', ...
                              'anchors',{{'Very disgusted','Very delighted'}});
cfg.rating.items{16} = struct('type','vas','name','health',      'question','How healthy do you think the item is?', ...
                              'anchors',{{'Very unhealthy','Very healthy'}});
cfg.rating.items{17} = struct('type','vas','name','want_eat',    'question','How much would you like to eat the food item you saw?', ...
                              'anchors',{{'Not at all','Extremely'}});

% Setup Information
cfg.info.matlab = matlabRelease();
cfg.info.ptb.version = Screen('Version');
cfg.info.ptb.machine = Screen('Computer');

cfg.info.lan = true;
cfg.info.lsl = false;
cfg.info.parallel_port = true;
cfg.info.network.ipv4.network = '10.10.10.xxx';
cfg.info.network.ipv4.eeg = '10.10.10.42';
cfg.info.network.ipv4.eyetracker = '10.10.10.70';
cfg.info.network.ipv4.machine = '10.10.10.31';
cfg.info.network.ipv4.subnet = '255.255.255.0';

%% PARAMETERS - SETUP & INITIALISATION

AssertOpenGL(); % gives warning if running in PC with non-OpenGL based PTB

% Formatting options
cfg.format.stimSize         = 2/3; % proportion of full screen 
cfg.format.fontSizeText     = 40;
cfg.format.fontSizeFixation = 120;
cfg.format.font             = 'Arial';
cfg.format.backgroundColor  = [255 255 255]; % grey is 150!
cfg.format.foregroundColor  = [0 0 0]; % black
cfg.format.textColor        = 0;  % Text color: choose a number from 0 (black) to 255 (white)

% initialise system for key query - changed 'UnifyKeyNames' to 'KeyNames' due to
% the keyboard usage
KbName('UnifyKeyNames')
cfg.keys.keyDELETE = KbName('delete'); 
cfg.keys.keySPACE  = KbName('space');
cfg.keys.keyESCAPE = KbName('escape');
cfg.keys.keyZ = KbName('z'); % 1
cfg.keys.keyX = KbName('x'); % 2
cfg.keys.keyC = KbName('c'); % 3
cfg.keys.keyV = KbName('v'); % 4
cfg.keys.keyB = KbName('b'); % 5
cfg.keys.keyN = KbName('n'); % 6
cfg.keys.keyM = KbName('m'); % 7

% instructions definition
cfg.text.taskname          = 'videorating';
cfg.text.getready_en       = 'The experiment will start shortly... Keep your eyes fixed on the cross';
cfg.text.getready_pt       = 'A experiência come�ar� em breve... Mantenha o olhar fixo na cruz';
cfg.text.starting_en       = 'Starting in';
cfg.text.starting_pt       = 'Come�a em';
cfg.text.baselineClosed_en = 'Baseline with eyes closed will start shortly';
cfg.text.baselineClosed_pt = 'O per�odo de relaxamento com olhos fechados come�ar� em breve';
cfg.text.baselineOpen_en   = 'Baseline with eyes open will start shortly';
cfg.text.baselineOpen_pt   = 'O período de relaxamento com olhos abertos come�ar� em breve';

%% SCREEN SETUP
% TIP: create a virtual screen to use MATLAB while the task is running
cfg.screen.number   = 1; % 1 for primary, 2 for secondary, ...
cfg.screen.pointers = Screen('Windows');
screens             = Screen('Screens');
if cfg.screen.number > max(screens)
    % if you are using a duplicated display on windows, for example
    cfg.screen.number = max(screens);
end
% Ensure resources
Priority(MaxPriority(cfg.screen.number));

% Get screen resolution
if cfg.screen.number > 0 % find out if there is more than one screen
    dual = get(0,'MonitorPositions');
    resolution = [0,0,dual(cfg.screen.number,3),dual(cfg.screen.number,4)];
elseif cfg.screen.number == 0 % if not, get the normal screen's resolution
    resolution = get(0,'ScreenSize');
end
cfg.screen.resolx = resolution(3);
cfg.screen.resoly = resolution(4);
cfg.screen.centerX = cfg.screen.resolx / 2; % x center
cfg.screen.centerY = cfg.screen.resoly / 2; % y center

% Define new dimensions for the video, 1.5x1.5 times smaller
newWidth  = cfg.screen.resolx * cfg.format.stimSize;
newHeight = cfg.screen.resoly * cfg.format.stimSize;
% Calculate the position to center the smaller video on the screen
cfg.screen.stim = [...
    (cfg.screen.resolx - newWidth) / 2, ...
    (cfg.screen.resoly - newHeight) / 2, ...
    (cfg.screen.resolx + newWidth) / 2, ...
    (cfg.screen.resoly + newHeight) / 2];

% cleanup unused variables
clear screens resolution dual newHeight newWidth

% user input - participant information
% get user input for usage or not of eyelink
prompt={'Input participant ID',...
    'Task language','Number of runs'};
dlg_title='Input';
% Fot this experiment participant_id will be SRxxx (scenario rating)
cfg.input = inputdlg(prompt,dlg_title,1,{'SR','en','1'});
% get time of experiment
cfg.task.dateOfExp = datetime('now');

% Task Language
if strcmpi(cfg.input{2},'pt')
    cfg.task.languageSuffix = '_pt';
elseif strcmpi(cfg.input{2},'en')
    cfg.task.languageSuffix = '_en';
end

% Filenames
cfg.text.elFileName        = ['sub-',cfg.input{1},'_task-', cfg.text.taskname,'_run-',cfg.input{3},'_eye'];
cfg.text.logFileName       = ['sub-',cfg.input{1},'_task-', cfg.text.taskname,'_run-',cfg.input{3},'_log'];
cfg.text.eegFileName       = ['sub-',cfg.input{1},'_task-', cfg.text.taskname,'_run-',cfg.input{3},'_eeg'];
cfg.text.eventFileName     = ['sub-',cfg.input{1},'_task-', cfg.text.taskname,'_run-',cfg.input{3},'_event'];
cfg.text.flipFileName      = ['sub-',cfg.input{1},'_task-', cfg.text.taskname,'_run-',cfg.input{3},'_flips'];
cfg.text.eventSequence     = ['sub-',cfg.input{1},'_task-', cfg.text.taskname,'_run-',cfg.input{3},'_seq'];

% Task parameters
cfg.task.description          = '';
cfg.task.numberOfStates       = 10;
cfg.task.numberOfRuns         = 1;
cfg.task.stimsPerRun          = 1;
cfg.task.eyes_closed_duration = 30; % in secs
cfg.task.eyes_open_duration   = 30; % in secs
cfg.task.preparation_duration = 5;  % in secs

% BIDS and HED info
cfg.BIDS.modalities = {'eeg','eyetrack'};
cfg.BIDS.eeg.provider = 'EGI';
cfg.BIDS.eyetrack.provider = 'EyeLink';
cfg.BIDS.sub = '';
cfg.BIDS.run = '';
cfg.BIDS.ses = '';
cfg.BIDS.desc = '';
cfg.BIDS.task = '';
cfg.HED.events = {};

% select sequence to use
if str2double(cfg.input{3}) == 1
    cfg.BIDS.run = 1;
    generate_sequences(cfg);  % Generate new stimuli sequence
    sequence1 = load('sequences\sequence1.mat');
    % save information from chosen sequence in the 'data' structure
    cfg.sequences.files = sequence1.sequenceFiles1;
    save(fullfile(cfg.paths.sequence_path, cfg.text.eventSequence), 'sequence1')
elseif str2double(cfg.input{3}) == 2
    cfg.BIDS.run = 2;
    sequence2 = load('sequences\sequence2.mat');
    % save information from chosen sequence in the 'data' structure
    cfg.sequences.files = sequence2.sequenceFiles2;
    save(fullfile(cfg.paths.sequence_path, cfg.text.eventSequence), 'sequence2')
else
    warning('Selected sequence does not exist');
end

% get subject id folder to store result files
cfg.BIDS.sub = ['sub-',cfg.input{1}];
if ~isfolder(fullfile(cfg.paths.data_path, cfg.BIDS.sub))
    mkdir(fullfile(cfg.paths.data_path, cfg.BIDS.sub));
end

% cleanup unused variables
clear prompt dlg_title num_lines ppid scriptName ii

% Settings for export options
cfg.export.exportXlsx = true;
cfg.export.exportTsv  = true;

% Initialise EEG -> Open NetStationAcquisition and start recording
NetStation('Connect', cfg.info.network.ipv4.eeg)
disp('Connection with NetStation successfull!');

% Using parallel port for EEG markers
if cfg.info.parallel_port
    exists_mex = which("io64");
    if isempty(exists_mex)
        error("Executable not found in the path. Ensure you downloaded it and added it to path.")
        cfg.info.parallel_port = false;
    end
end
        
% -------------------------------------------------------------------------
%                       Initialise Eyelink +  Screen
% -------------------------------------------------------------------------
try 
    Eyelink('SetAddress', cfg.info.network.ipv4.eyetracker);
catch ME
    fprintf(2,'Error:\n%s\n',ME.message)   
end

% Init eyelink
edfFileName = [cfg.input{1} '_' cfg.input{3}]; % cannot have more than 8 chars
[cfg.screen.pointer, cfg.screen.rect, cfg.el] = elInitiate(cfg, edfFileName);    

% % Open experiment graphics on the specified screen
% [cfg.screen.pointer, rect] = Screen('Openwindow',cfg.screen.number,cfg.format.backgroundColor,[],[],2);
% Screen('TextSize', cfg.screen.pointer,cfg.format.fontSizeText);
% Screen('TextFont', cfg.screen.pointer,cfg.format.font);
% Screen('TextStyle', cfg.screen.pointer, 1);
% Screen('Flip', cfg.screen.pointer); 
% % Return width and height of the graphics window/screen in pixels
% [width, height] = Screen('WindowSize', cfg.screen.pointer);

% Get existing pointers
cfg.info.pointer = Screen('GetWindowInfo', cfg.screen.pointer);

% -------------------------------------------------------------------------
%                             Training mode
% -------------------------------------------------------------------------

if cfg.training % overwrite previous parameters
    cfg.paths.stim_path = fullfile(cfg.paths.local.sourcedata, 'supp', 'stimuliTraining');
    cfg.sequences.files = {dir(fullfile(cfg.paths.stim_path,'*.mp4')).name};
    cfg.task.stimsPerRun = numel(cfg.sequences.files);
    cfg.task.eyes_closed_duration = 5; % in secs
    cfg.task.eyes_open_duration   = 5; % in secs   
    cfg.export.exportXlsx = false;
    cfg.export.exportTsv  = false;    
end


% -------------------------------------------------------------------------
%                             Videos
% -------------------------------------------------------------------------

% Stimulus
cfg.stim.isVideo = true;
cfg.stim.preloaded = false;
if cfg.stim.isVideo
    % another recommendation is to process them all with ffmpeg
    % cache videos to improve performance
    % Videos standardized with ffmpeg
    % foreach ($f in Get-ChildItem *.avi) {
    % ffmpeg -i $f.FullName -an -pix_fmt yuv420p -c:v libx264 -profile:v high -preset fast -crf 17 -r 30 -movflags +faststart ($f.BaseName + ".mp4")
    % }
    disp('Preloading videos...')
    cfg.stim.moviePntrs = zeros(numel(cfg.sequences.files),1);

    for t = 1:numel(cfg.sequences.files)
        file = fullfile(cfg.paths.stim_path, cfg.sequences.files{t});
        cfg.stim.moviePntrs(t) = Screen('OpenMovie', cfg.screen.pointer, file, 0, inf, 2);
        Screen('SetMovieTimeIndex', cfg.stim.moviePntrs(t), 0);
    end
    cfg.stim.preloaded = true;
end

% Save cfg to .mat and .json (optional)

end



