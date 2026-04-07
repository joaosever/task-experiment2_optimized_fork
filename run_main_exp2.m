function run_main_exp2()
% Main script for running Emotional Cities' experiment 2
% Hit 'o' after doing the eyetracker calibration
% Hit 'esc' on the training script to start the task
% Hit 'x' to terminate the task
% -------------------------------------------------------------------------

% Clean workspace
clearvars; close all; clc; 

% Ensure function stops in case of error
dbstop if error

% Error utility
% Only works if placed inside a function
cleanupObj = onCleanup(@() taskCleanup());

% Load all the settings from the file
cfg = settings_main(); 

%Prepare port for bitalino
%s = serialport("COM1",115200);

% Prelim
HideCursor();

% -------------------------------------------------------------------------
% IMPORTANT!!!!!!!!!!
% If you accidentally started run 1 instead of run 2:
% 1) load the randomized trail sequence present in the sequences folder
% 2) uncomment and run the following line of code!!!
% load('.\task-experiment2_optimized\sequences\ranseq-20250721_154554.mat')
% cfg.sequences.files = sequenceFilesComplete(30+1:end);       

% -------------------------------------------------------------------------
%                       Set flag variables for While Loop
% -------------------------------------------------------------------------
% Number of trials/videos based on available videos
n                 = cfg.task.stimsPerRun; 
trial_            = 1;
event_            = 1;

% -------------------------------------------------------------------------
%                       Set variables for Log File
% -------------------------------------------------------------------------

% Reaction times and choices for valence and arousal
rt_valence        = zeros(1,n); 
rt_arousal        = zeros(1,n);

n = cfg.task.stimsPerRun;
Q = cfg.rating.items;
nQ = numel(Q);

resp.choiceIdx  = nan(n, nQ);      % MCQ index; VAS stays NaN
resp.choiceText = strings(n, nQ);  % MCQ label; VAS stays ""
resp.vasValue   = nan(n, nQ);      % VAS value -100..100; MCQ stays NaN
resp.rt         = nan(n, nQ);      % seconds
stim              = cell(1,n);

nInit = numel(cfg.init.items);     %Logs of the physiological and meta physiological states
initResp.values = nan(1, nInit);
initResp.rt     = nan(1, nInit);

% -------------------------------------------------------------------------
%                       Set variables for event files
% -------------------------------------------------------------------------

% Parallel port event description:
% DIN99 - parallel_port(99) -> Empathic sync
% DIN98 - parallel_port(98) -> Eyes closed baseline
% DIN97 - parallel_port(97) -> Eyes open baseline
% DIN1  - parallel_port(1)  -> Beginning of Task Message
% DIN2  - parallel_port(2)  -> Fixation Cross
% DIN3  - parallel_port(3)  -> Image
% DIN4  - parallel_port(4)  -> Video
% DIN5  - parallel_port(5)  -> Valence
% DIN6  - parallel_port(6)  -> Arousal
% DIN7  - parallel_port(7)  -> Blank Screen
% DIN29 - parallel_port(29) -> Physiological and Meta state onset
% DIN30 - parallel_port(30) -> Questionnaire item onset (generic)
% DIN31 - parallel_port(31) -> Questionnaire item response (generic)
  
% Actually send those markers in the code (this is the real change),
% =========================================================================
% The same schema is used for NetStation events sent over IP/TCP

% numEvents       = 3 + 7*n;           % Equal to number of sent DINs
% eventOnsets     = zeros(1, numEvents); % Time of event onset in seconds
% eventDurations  = zeros(1, numEvents); % Duration of event in seconds
% eventTypes      = cell(1, numEvents);  % Type of event, e.g., 'DI99', 'DI98'
% eventValues     = zeros(1, numEvents); % Numeric value to encode the event, optional
% eventSamples    = zeros(1, numEvents); % Sample number at which event occurs, optional
% eventTime       = cell(1, numEvents);  % Universal time given by datetime('now')

numEvents = 10000;

ev.numEvents      = numEvents;
ev.onsets         = zeros(1, numEvents);
ev.durations      = zeros(1, numEvents);
ev.types          = cell(1, numEvents);
ev.values         = zeros(1, numEvents);
ev.samples        = zeros(1, numEvents);
ev.time           = cell(1, numEvents);

% -------------------------------------------------------------------------
%                       Set variables for task performance
% -------------------------------------------------------------------------

maxFlips = 50000;

flipLog.initial_call     = nan(maxFlips,1);
flipLog.predicted_onset  = nan(maxFlips,1);
flipLog.timestamp_return = nan(maxFlips,1);
flipLog.missed           = nan(maxFlips,1);
flipLog.beampos          = nan(maxFlips,1);
flipLog.event_code       = nan(maxFlips,1);

flipIdx = 1;

% -------------------------------------------------------------------------
%                               EEG
% -------------------------------------------------------------------------

NetStation('Synchronize') % Synchronize with NetStation

% -------------------------------------------------------------------------
%                       Start experiment
% -------------------------------------------------------------------------

% Wait fot user input to start the experiment
% input('Press Enter to start the task.');

if cfg.BIDS.run==1
    % Start with state 99
    state     = 99;
elseif cfg.BIDS.run==2
    % Start with state 1 and skip baseline
    state     = 1;
end


while trial_ <= n

    % MANUAL CONTROL 
    [keyIsDown, ~, keyCode] = KbCheck; % Check for keyboard press
    if keyIsDown
        if keyCode(cfg.keys.keyX) % Check if the terminate key (x) was pressed
            break % Exit the function or script
        end
    end

    switch state

% -------------------------------------------------------------------------
%                  Countdown for empatica sync
% -------------------------------------------------------------------------
        case 99
            if cfg.BIDS.run==1
            start_exp = GetSecs();
            NetStation('StartRecording')
            Eyelink('StartRecording');
            end
            % -------------------------------------------
            if cfg.info.parallel_port; parallel_port(99); end   % Send to NetStation
            ev = logEvent(ev, event_, GetSecs(), NaN, 'emp_sync', state, start_exp, 500);
            % -------------------------------------------
            countdown_from = 5; % Start countdown from 10
            for i = countdown_from:-1:1
                Screen('TextSize', cfg.screen.pointer, 60);
                Screen('TextFont', cfg.screen.pointer, cfg.format.font);
                message = sprintf(strcat(eval(strcat('cfg.text.starting', cfg.task.languageSuffix)),' %d'), i);
                DrawFormattedText(cfg.screen.pointer, message, 'center', 'center', cfg.format.textColor);
                Screen('Flip', cfg.screen.pointer);
                WaitSecs(1);
            end
            % -------------------------------------------
            Eyelink('Message','Empatica Synch');
            Eyelink('command','record_status_message "Instructions Screen"');
            % -------------------------------------------
            event_ = event_ + 1;
            state  = 98;

% -------------------------------------------------------------------------
%                            Eyes closed Baseline
% -------------------------------------------------------------------------
        case 98
            % You need to give clear instructions for when the subject
            % needs to open their eyes again
            Screen('TextSize', cfg.screen.pointer, 50);
            DrawFormattedText(cfg.screen.pointer, eval(strcat('cfg.text.baselineClosed', cfg.task.languageSuffix)), 'center', 'center', cfg.format.textColor);
            Screen('Flip', cfg.screen.pointer);
            WaitSecs(5);
            countdown_from = 5; % Start countdown from 10
            for i = countdown_from:-1:1
                Screen('TextSize', cfg.screen.pointer, 60);
                Screen('TextFont', cfg.screen.pointer, cfg.format.font);
                message = sprintf(strcat( eval(strcat('cfg.text.starting', cfg.task.languageSuffix)),' %d'), i);
                DrawFormattedText(cfg.screen.pointer, message, 'center', 'center', cfg.format.textColor);
                Screen('Flip', cfg.screen.pointer);
                WaitSecs(1);
            end
            % -------------------------------------------
            % Draw Cross
            drawCross(cfg.screen.pointer, cfg.screen.resolx, cfg.screen.resoly);
            tFixation = Screen('Flip', cfg.screen.pointer);
            % -------------------------------------------
            if cfg.info.parallel_port; parallel_port(98); end   % Send to NetStation
            NetStation('Event','EVEN',tFixation, 0.001,'cros',state); %NetStation('FlushReadbuffer'); 
            ev = logEvent(ev, event_, GetSecs(), NaN, 'close', state, start_exp, 500);
            Eyelink('Message','Eyes Closed');
            Eyelink('command','record_status_message "Eyes Closed"')
            % -------------------------------------------
            WaitSecs(cfg.task.eyes_closed_duration);
            event_ = event_ + 1;
            state  = 97;
           
% -------------------------------------------------------------------------
%                            Eyes open Baseline
% -------------------------------------------------------------------------
        case 97
            Screen('TextSize', cfg.screen.pointer, 50);
            DrawFormattedText(cfg.screen.pointer, eval(strcat('cfg.text.baselineOpen', cfg.task.languageSuffix)), 'center', 'center', cfg.format.textColor);
            Screen('Flip', cfg.screen.pointer);
            WaitSecs(5);
            countdown_from = 5; % Start countdown
            for i = countdown_from:-1:1
                Screen('TextSize', cfg.screen.pointer, 60);
                Screen('TextFont', cfg.screen.pointer, cfg.format.font);
                message = sprintf(strcat( eval(strcat('cfg.text.starting', cfg.task.languageSuffix)),' %d'), i);
                DrawFormattedText(cfg.screen.pointer, message, 'center', 'center', cfg.format.textColor);
                Screen('Flip', cfg.screen.pointer);
                WaitSecs(1);
            end
            % -------------------------------------------
            % Draw Cross
            drawCross(cfg.screen.pointer, cfg.screen.resolx, cfg.screen.resoly);
            tFixation = Screen('Flip', cfg.screen.pointer);
            % -------------------------------------------            
            if cfg.info.parallel_port; parallel_port(97); end   % Send to NetStation
            NetStation('Event','EVEN',tFixation, 0.001,'cros',state); %NetStation('FlushReadbuffer'); 
            ev = logEvent(ev, event_, GetSecs(), NaN, 'open', state, start_exp, 500);
            Eyelink('Message','Eyes Open');
            Eyelink('command','record_status_message "Eyes Open"')
            % -------------------------------------------
            WaitSecs(cfg.task.eyes_open_duration);
            event_ = event_ + 1;
            state  = 96;

% -------------------------------------------------------------------------
%                 INITIAL PHYSIOLOGICAL AND METAPHYSIOLOGICAL STATE VAS
% -------------------------------------------------------------------------
case 96

    Eyelink('Message','Initial State Ratings');

    % Run initial VAS block
    initResp = runInitState(cfg);

    % EEG marker
    tInit = GetSecs();
    if cfg.info.parallel_port; parallel_port(30); end
    NetStation('Event','EVEN', tInit, 0.001, 'init',30);

    ev = logEvent(ev, event_, tInit, NaN, 'meta', 30, start_exp, 500);
    event_ = event_ + 1;

    state = 1;

% -------------------------------------------------------------------------
%                             Message
% -------------------------------------------------------------------------
        case 1
            if cfg.BIDS.run==2
                start_exp = GetSecs();
                NetStation('StartRecording')   
                Eyelink('StartRecording');
            end
            % Screen
            Screen('TextSize', cfg.screen.pointer, 50);
            DrawFormattedText(cfg.screen.pointer, eval(strcat('cfg.text.getready', cfg.task.languageSuffix)), 'center', 'center', cfg.format.textColor);
            InitialDisplayTime = Screen('Flip', cfg.screen.pointer);
            % EEG
            if cfg.info.parallel_port; parallel_port(1); end   % Send to NetStation
            NetStation('Event','EVEN',InitialDisplayTime, 0.001, 'mess',1); %NetStation('FlushReadbuffer'); 
            ev = logEvent(ev, event_, GetSecs(), NaN, 'message', state, start_exp, 500);
            % ------------------------------------------- EL
            Eyelink('Message', 'TRIALID %d', trial_);
            Eyelink('Message', '!V CLEAR %d %d %d', cfg.el.backgroundcolour(1), cfg.el.backgroundcolour(2), cfg.el.backgroundcolour(3));
            Eyelink('Command', 'record_status_message "TRIAL %d/%d"', trial_, n);            
            % -------------------------------------------            
            WaitSecs(cfg.task.preparation_duration);
            event_ = event_ + 1;
            state = 2;
          

% -------------------------------------------------------------------------
%                             Cross
% -------------------------------------------------------------------------
        case 2
            Eyelink('Message','Fixation Cross');
            Eyelink('command','draw_cross %d %d',...
            cfg.screen.centerX,cfg.screen.centerY);
            % -----------------------------------------
            drawCross(cfg.screen.pointer, cfg.screen.resolx, cfg.screen.resoly);
            tFixation = Screen('Flip', cfg.screen.pointer);
            if cfg.info.parallel_port; parallel_port(2); end   % Send to NetStation            
            NetStation('Event','EVEN',tFixation, 0.001, 'cros',state); %NetStation('FlushReadbuffer');
            % NetStation('Event','EVEN',StimulusOnsetTime, 0.001, 'most',state); NetStation('FlushReadbuffer');              
            Eyelink('Message','EEGSYNCH_%d',state);
            ev = logEvent(ev, event_, GetSecs(), NaN, 'cross', state, start_exp, 500);
            % -------------------------------------------
            WaitSecs(1);
            event_ = event_ + 1;
            state = 3;  % Proceed to next state to play video

% -------------------------------------------------------------------------
%                             Video
% -------------------------------------------------------------------------
 
    case 3
        videoFile    = cfg.sequences.files{trial_}; 
        file         = fullfile(cfg.paths.stim_path, videoFile);
        stim{trial_} = videoFile;
    
        Eyelink('Message', strcat('STIM_ONSET_', videoFile));
    
        % -------------------------------
        % Step 1: Read audio from movie
        % -------------------------------
        try
            [audioData, fs] = audioread(file); % use the movie's audio track
            nrAudioChannels = size(audioData,2);
            disp(['Audio channels detected: ', num2str(nrAudioChannels)]);
            % Start audio playback asynchronously
            sound(audioData, fs);
        catch
            warning('Audio not found or could not be played');
        end
    
        % -------------------------------
        % Step 2: Open movie for video
        % -------------------------------
        if cfg.stim.preloaded
            movie = cfg.stim.moviePntrs(trial_);
            Screen('SetMovieTimeIndex', movie, 0);
        else
            [movie, ~, ~, ~, ~, ~, ~] = Screen('OpenMovie', cfg.screen.pointer, file);
            Screen('SetMovieTimeIndex', movie, 0);
        end
    
        Screen('PlayMovie', movie, 1, 0, 1.0); % play once, normal speed
    
        tex = 0;
        firstFrameDisplayed = false;
    
        % -------------------------------
        % Step 3: Playback loop
        % -------------------------------
        while tex ~= -1
            tex = Screen('GetMovieImage', cfg.screen.pointer, movie, 1);
            if tex > 0
                Screen('DrawTexture', cfg.screen.pointer, tex, [], cfg.screen.stim);
                [InitialDisplayTime, StimulusOnsetTime, FlipTimestamp, Missed, Beampos] = Screen('Flip', cfg.screen.pointer);
                Screen('Close', tex);
    
                if ~firstFrameDisplayed
                    firstFrameDisplayed = true;
                    if cfg.info.parallel_port; parallel_port(3); end
                    NetStation('Event','EVEN',InitialDisplayTime, 0.001,'stim',3);
                    ev = logEvent(ev, event_, GetSecs(), NaN, 'video_pre', 3, start_exp, 500);
                    event_ = event_ + 1;
                end
    
                [flipLog, flipIdx] = logFlip(flipLog, flipIdx, 3, InitialDisplayTime, StimulusOnsetTime, FlipTimestamp, Missed, Beampos);
            end
    
            [keyIsDown, ~, keyCode] = KbCheck;
            if keyIsDown && keyCode(cfg.keys.keyX)
                break
            end
        end
    
        Screen('PlayMovie', movie, 0);
    
        if ~cfg.stim.preloaded
            Screen('CloseMovie', movie);
        end
    
        Eyelink('Message', strcat('STIM_OFFSET_', videoFile));
        event_ = event_ + 1;
        state = 50;

% -------------------------------------------------------------------------
%                            Generic case 
% -------------------------------------------------------------------------

        case 50
            % ---------------- Questionnaire after each video ----------------
            for qi = 1:numel(cfg.rating.items)
                item = cfg.rating.items{qi};

                
                if strcmpi(item.type,'mcq')
                    [idx, txt, rtSec, ok] = runMCQ(cfg, item.question, item.options);

                    resp.choiceIdx(trial_, qi)  = idx;
                    resp.choiceText(trial_, qi) = string(txt);
                    resp.rt(trial_, qi)         = rtSec;

                elseif strcmpi(item.type,'vas')
                    imgFile = '';
                    if isfield(item,'image')
                        if strcmpi(item.image,'valence')
                            imgFile = cfg.rating.sam.valence;
                        elseif strcmpi(item.image,'arousal')
                            imgFile = cfg.rating.sam.arousal;
                        end
                    end

                    [v, rtSec, ok] = runVAS(cfg, item.question, item.anchors{1}, item.anchors{2}, imgFile);

                    resp.vasValue(trial_, qi) = v;
                    resp.rt(trial_, qi)       = rtSec;

                else
                    error('Unknown item type: %s', item.type);
                end

                % EEG marker: response (generic)
                tResp = GetSecs();
                if ok
                    if cfg.info.parallel_port; parallel_port(31); end
                    NetStation('Event','EVEN',tResp, 0.001, 'resp',31); %NetStation('FlushReadbuffer');
                    ev = logEvent(ev, event_, tResp, NaN, 'question', 31, start_exp, 500);
                    %write(s,uint8(1),"uint8");
                    event_ = event_ + 1;
                end

                WaitSecs(0.2);
            end

            % Done with all questions -> blank screen
            state = 7;         



% -------------------------------------------------------------------------
%                             Blank Screen
% ------------------------------------------------------------------------- 
        
        case 7
            % Fill the screen with white color
            Screen('FillRect', cfg.screen.pointer, cfg.format.backgroundColor);  % Assuming 0 is the color code for black
            % Update the display to show the black screen
            BlankTime = Screen('Flip', cfg.screen.pointer);
            % -------------------------------------------
            if cfg.info.parallel_port; parallel_port(7); end   % Send to NetStation
            NetStation('Event','EVEN',BlankTime, 0.001, 'blan',5); %NetStation('FlushReadbuffer');   %May be 7 instead of 5                                                                               
            ev = logEvent(ev, event_, GetSecs(), NaN, 'blank', state, start_exp, 500);                            
            % -------------------------------------------
            WaitSecs(1);
            % ------------------------------------------- End trial EL
            Eyelink('Message','End of trial %d', trial_);
            Eyelink('Message','TRIAL_RESULT 0');
            % -------------------------------------------
            event_ = event_ + 1;            
            trial_ = trial_ + 1;  
            state  = 2;
            % ------------------------------------------- New trial EL
            Eyelink('Message', 'TRIALID %d', trial_);
            Eyelink('Message', '!V CLEAR %d %d %d', cfg.el.backgroundcolour(1), cfg.el.backgroundcolour(2), cfg.el.backgroundcolour(3));
            Eyelink('Command', 'record_status_message "TRIAL %d/%d"', trial_, n);
            % Eyelink('SetOfflineMode');
            % Eyelink('command', 'clear_screen 0'); % clears tracker display
            % -------------------------------------------
    end
end

% -------------------------------------------------------------------------
%                       End of Experiment
% -------------------------------------------------------------------------
ShowCursor();
if cfg.info.parallel_port; parallel_port(10); end   % Send end event to NetStation
ev = logEvent(ev, event_, GetSecs(), 0, 'end', state, start_exp, 500);                            


% -------------------------------------------------------------------------
%                       Stop EEG recording
% -------------------------------------------------------------------------

NetStation('StopRecording')
NetStation('Disconnect')


% -------------------------------------------------------------------------
%                       Stop Eyetracker recording
% -------------------------------------------------------------------------
 

% Close all preloaded movies
if isfield(cfg.stim, 'moviePntrs')
    for i = 1:length(cfg.stim.moviePntrs)
        Screen('CloseMovie', cfg.stim.moviePntrs(i));
    end
end

elFinish(cfg);
elCleanup();

% -------------------------------------------------------------------------
%                          Export task data
% -------------------------------------------------------------------------

% Create base table
addSubColumn = repmat(string(cfg.input{1}), n, 1); % string array
addRunColumn = repmat(str2double(cfg.input{3}), n, 1); % numeric

logTable = table(addSubColumn, addRunColumn, stim', ...
    'VariableNames', {'sub','run','stimulus'});

% Add initial VAS responses (physiological + meta-physio)

for qi = 1:numel(cfg.init.items)
    item = cfg.init.items{qi};
    name = matlab.lang.makeValidName(item.name);

    logTable.(name)         = ones(n,1) * initResp.values(qi);
    logTable.([name '_rt']) = ones(n,1) * initResp.rt(qi);
end

for qi = 1:numel(cfg.rating.items)
    item = cfg.rating.items{qi};
    name = matlab.lang.makeValidName(item.name);

    if strcmpi(item.type,'mcq')
        logTable.([name '_idx']) = resp.choiceIdx(:, qi);
        logTable.([name '_txt']) = resp.choiceText(:, qi);
        logTable.([name '_rt'])  = resp.rt(:, qi);
    else
        logTable.(name)          = resp.vasValue(:, qi); % -100..100
        logTable.([name '_rt'])  = resp.rt(:, qi);
    end
end

eventTable = table( ...
    ev.onsets', ...
    ev.durations', ...
    ev.types', ...
    ev.values', ...
    ev.samples', ...
    ev.time', ...
    'VariableNames', {'onset', 'duration', 'trial_type', 'state', 'getSecs', 'time'});
% Remove rows with no event type (unused events)
emptyRows = cellfun(@isempty, eventTable.trial_type);
eventTable(emptyRows, :) = [];


% -------------------------------------------------------------------------
%                          Convert File into TSV
% -------------------------------------------------------------------------

if cfg.export.exportTsv
    % Write the log table to a TSV file
    writetable(logTable, [cfg.paths.logs_path filesep cfg.text.logFileName '.tsv'], 'FileType', 'text', 'Delimiter', '\t');
    writetable(eventTable, [cfg.paths.event_path filesep cfg.text.eventFileName '.tsv'], 'FileType', 'text', 'Delimiter', '\t');    
    %writetable(flipTable, [cfg.paths.event_path filesep cfg.text.flipFileName '.tsv'], 'FileType', 'text', 'Delimiter', '\t');        
end

% -------------------------------------------------------------------------
%                          Convert File into XLSX
% -------------------------------------------------------------------------

if cfg.export.exportXlsx
    % Write table
    writetable(logTable, [cfg.paths.logs_path filesep cfg.text.logFileName '.xlsx']);
    writetable(eventTable, [cfg.paths.event_path filesep cfg.text.eventFileName '.xlsx']);    
    %writetable(flipTable, [cfg.paths.event_path filesep cfg.text.flipFileName '.xlsx']);
end

%write(s,uint8(0),"uint8");


% -------------------------------------------------------------------------
%                                   Bye
% -------------------------------------------------------------------------
disp("====================================================================")
disp("============================ FINISHED ==============================")
disp("====================================================================")
cd(cfg.paths.task)


end