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
choiceValence     = zeros(1,n); 
choiceArousal     = zeros(1,n);
stim              = cell(1,n);

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
            ev = logEvent(ev, event_, GetSecs(), NaN, 'DI99', state, start_exp, 500);
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
            NetStation('Event','EVEN',tFixation, 0.001,'cros',state); NetStation('FlushReadbuffer'); 
            ev = logEvent(ev, event_, GetSecs(), NaN, 'DI98', state, start_exp, 500);
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
            NetStation('Event','EVEN',tFixation, 0.001,'cros',state); NetStation('FlushReadbuffer'); 
            ev = logEvent(ev, event_, GetSecs(), NaN, 'DI97', state, start_exp, 500);
            Eyelink('Message','Eyes Open');
            Eyelink('command','record_status_message "Eyes Open"')
            % -------------------------------------------
            WaitSecs(cfg.task.eyes_open_duration);
            event_ = event_ + 1;
            state  = 1;

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
            NetStation('Event','EVEN',InitialDisplayTime, 0.001, 'mess',1); NetStation('FlushReadbuffer'); 
            ev = logEvent(ev, event_, GetSecs(), NaN, 'DIN1', state, start_exp, 500);
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
            NetStation('Event','EVEN',tFixation, 0.001, 'cros',state); NetStation('FlushReadbuffer');
            % NetStation('Event','EVEN',StimulusOnsetTime, 0.001, 'most',state); NetStation('FlushReadbuffer');              
            Eyelink('Message','EEGSYNCH_%d',state);
            ev = logEvent(ev, event_, GetSecs(), NaN, 'DIN2', state, start_exp, 500);
            % -------------------------------------------
            WaitSecs(1);
            event_ = event_ + 1;
            state = 3;  % Proceed to next state to play video

% -------------------------------------------------------------------------
%                             Video
% -------------------------------------------------------------------------
        case 3

            % important to select the correct sequence of videos
            videoFile    = cfg.sequences.files{trial_}; 
            file         = fullfile(cfg.paths.stim_path, videoFile);
            stim{trial_} = videoFile;
            fprintf('Stimulus - %s; Trial nº %d\n',videoFile, trial_);
            fprintf('Time elapsed since beginning: %f minutes\n', (GetSecs()-start_exp)/60);

            % Eyelink setup
            % elCheckRecording(el,edfFileName,cfg.screen.pointer); % Check if everything is fine
            Eyelink('Message', strcat('STIM_ONSET_',videoFile));

            if cfg.stim.preloaded % recommended

                movie = cfg.stim.moviePntrs(trial_);
                Screen('SetMovieTimeIndex', movie, 0);
                Screen('PlayMovie', movie, 1);
            
                tex = 0;
                firstFrameDisplayed = false;
                
                % The following while loop finishes if a key is touched
                while tex ~= -1 %&& ~KbCheck() 
                    tex = Screen('GetMovieImage', cfg.screen.pointer, movie, 1);
                    if tex > 0
                        Screen('DrawTexture', cfg.screen.pointer, tex, [], cfg.screen.stim);
                        
                        % ---- capture timing from the flip ----
                        [InitialDisplayTime, StimulusOnsetTime, FlipTimestamp, Missed, Beampos] = Screen('Flip', cfg.screen.pointer);
                
                        % ---- SEND EVENT EXACTLY ON FIRST FRAME ----
                        if ~firstFrameDisplayed
                            if cfg.info.parallel_port; parallel_port(3); end   % Send to NetStation
                            NetStation('Event','EVEN',InitialDisplayTime, 0.001, 'stim',state); NetStation('FlushReadbuffer');           
                            Eyelink('Message', sprintf('EEG_SYNCH_%d', state)) % for post-hoc EEG synch
                            ev = logEvent(ev, event_, GetSecs(), NaN, 'DIN3', state, start_exp, 500);            
                            firstFrameDisplayed = true;
                        end
                        % Log flips (useful for videos)
                        [flipLog, flipIdx] = logFlip(...
                            flipLog, flipIdx, ...         % struct + index
                            state, ...                    % your event code
                            InitialDisplayTime, ...
                            StimulusOnsetTime, ...
                            FlipTimestamp, ...
                            Missed, ...
                            Beampos ...
                        );  
                        Screen('Close', tex);
                    end
                end
            
                Screen('PlayMovie', movie, 0);
                Screen('CloseMovie', movie);

            else

                try
                    % Open the movie, start playback paused
                    movie = Screen('OpenMovie', cfg.screen.pointer, file, 0, inf, 2);
                    Screen('SetMovieTimeIndex', movie, 0);  %Ensure the movie starts at the very beginning
    
                    % Get the first frame and display it
                    tex = Screen('GetMovieImage', cfg.screen.pointer, movie, 1, 0);
                    if tex > 0  % If a valid texture was returned
                        Screen('DrawTexture', cfg.screen.pointer, tex, [], cfg.screen.stim);  % Draw the texture on the screen
                        tMovie = Screen('Flip', cfg.screen.pointer);  % Update the screen to show the first frame
                        % -------------------------------------------
                        if cfg.info.parallel_port; parallel_port(3); end   % Send to NetStation
                        NetStation('Event','EVEN',tMovie, 0.001, 'stim',3); NetStation('FlushReadbuffer');                        
                        ev = logEvent(ev, event_, GetSecs(), NaN, 'DIN3', state, start_exp, 500);            
                        % -------------------------------------------
                        % There is no need to hold the first frame since the first frame is already paused for 1 second in the video itself
                        % WaitSecs(1);  % Hold the first frame for 1.5 seconds (Not 1 sec?)
                        Screen('Close', tex);  % Close the texture
                        event_ = event_ + 1;
                    end
    
                    % Continue playing movie from the first frame
                    Screen('PlayMovie', movie, 1, 0);  % Start playback at normal speed from the current position
                    % -------------------------------------------
                    if cfg.info.parallel_port; parallel_port(4); end   % Send to NetStation
                    NetStation('Event','EVEN',GetSecs() - start_exp, 0.001, 'stim',4); NetStation('FlushReadbuffer');                                        
                    ev = logEvent(ev, event_, GetSecs(), NaN, 'DIN4', state, start_exp, 500);            
                    % -------------------------------------------
                    % Further video playback code handling remains unchanged as per your original setup
                catch ME
                    disp(['Failed to open movie file: ', file]);
                    rethrow(ME);
                end

                % Play and display the movie
                tex = 0;
                while ~KbCheck && tex~=-1  % Continue until keyboard press or movie ends
                    [tex, ~] = Screen('GetMovieImage', cfg.screen.pointer, movie, 1);
                    if tex > 0  % If a valid texture was returned
                        % Draw the texture on the screen
                        Screen('DrawTexture', cfg.screen.pointer, tex, [], cfg.screen.stim);
                        % Update the screen to show the current frame
                        Screen('Flip', cfg.screen.pointer);
                        % Release the texture
                        Screen('Close', tex);
                    end
                end
                    
                % -------------------------------------------
                Screen('PlayMovie', movie, 0); % Stop playback
                Screen('CloseMovie', movie);

            end

            % -------------------------------------------
            Eyelink('Message', strcat('STIM_OFFSET_',videoFile))
            % WaitSecs(0.1);
            % Eyelink('StopRecording');
            % -------------------------------------------
            event_ = event_ + 1;
            state = 5;              

% -------------------------------------------------------------------------
%                             Valence
% -------------------------------------------------------------------------

%TO DO: Change to VAS

        case 5 
            % Set the mouse cursor to the center of the screen
            ShowCursor();
            SetMouse(cfg.screen.centerX, cfg.screen.centerY, cfg.screen.pointer);
            file_valence = fullfile(cfg.paths.allstim_path,strcat('Score_Valence', cfg.task.languageSuffix, '.png'));
            % Load the image from the file
            imageArray_valence = imread(file_valence);
            % Make texture from the image array
            texture = Screen('MakeTexture', cfg.screen.pointer, imageArray_valence);
            % Define the destination rectangle to draw the image in its original size
            dst_rect_valence = CenterRectOnPointd([0 0 size(imageArray_valence, 2) size(imageArray_valence, 1)], cfg.screen.centerX, cfg.screen.centerY);
            % Set text size and font
            Screen('TextSize', cfg.screen.pointer, cfg.format.fontSizeText);
            Screen('TextFont', cfg.screen.pointer, cfg.format.font);
            % Draw the texture to the window
            Screen('DrawTexture', cfg.screen.pointer, texture, [], dst_rect_valence);
            % Draw circles
            [start_x,y_position,space_between_circles,circle_radius] = drawCircles(cfg.screen.centerX, cfg.screen.centerY, imageArray_valence, cfg.screen.pointer, 'surround', 0);
            % Update the display
            ValenceTime = Screen('Flip', cfg.screen.pointer); 
            % -------------------------------------------
            if cfg.info.parallel_port; parallel_port(5); end   % Send to NetStation
            NetStation('Event','EVEN',ValenceTime, 0.001, 'vale',state); NetStation('FlushReadbuffer');                                                        
            ev = logEvent(ev, event_, GetSecs(), NaN, 'DIN5', state, start_exp, 500);            
            % -------------------------------------------            
            % Initialize variables for circle clicks
            clicked_in_circle = false;

            while ~clicked_in_circle
                % Check for mouse clicks
                [clicks, x, y, ~] = GetClicks(cfg.screen.pointer, 0);
                if clicks
                    for i = 1:9
                        current_x = start_x + (i-1) * space_between_circles;
                        distance_squared = (x - current_x)^2 + (y - y_position)^2;
                        if distance_squared <= circle_radius^2
                            % Compute RT
                            rt_valence(trial_) = GetSecs() - ValenceTime;
                            % Redraw all circles
                            Screen('DrawTexture', cfg.screen.pointer, texture, [], dst_rect_valence);
                            drawCircles(cfg.screen.centerX, cfg.screen.centerY, imageArray_valence, cfg.screen.pointer, 'surround', i);
                            tValResp = Screen('Flip', cfg.screen.pointer);
                            % Send event marker
                            if cfg.info.parallel_port; parallel_port(20); end   % Send to NetStation
                            NetStation('Event','EVEN',tValResp, 0.001, 'resv',20); NetStation('FlushReadbuffer'); 
                            ev = logEvent(ev, event_, GetSecs(), NaN, 'DI20', state, start_exp, 500);                            
                            % Update the clicked circle index
                            clicked_in_circle     = true;
                            choiceValence(trial_) = i;
                            fprintf('Valence rating is %d\n', choiceValence(trial_))
                            elCreateVariables(trial_, videoFile, rt_valence(trial_)) % rt in ms
                            pause(0.5)
                            break;  % Exit the for loop since circle is found
                        end
                    end
                end
            end
            % -------------------------------------------
            event_ = event_ + 1;
            state = 6;

% -------------------------------------------------------------------------
%                             Arousal
% -------------------------------------------------------------------------     

%TO DO: Change to VAS

        case 6
            SetMouse(cfg.screen.centerX, cfg.screen.centerY, cfg.screen.pointer);
            file_arousal = fullfile(cfg.paths.allstim_path,strcat('Score_Arousal', cfg.task.languageSuffix, '.png'));
            % Load the image from the file
            imageArray_arousal = imread(file_arousal);
            % Make texture from the image array
            texture = Screen('MakeTexture', cfg.screen.pointer, imageArray_arousal);
            % Define the destination rectangle to draw the image in its original size
            dst_rect_arousal = CenterRectOnPointd([0 0 size(imageArray_arousal, 2) size(imageArray_arousal, 1)], cfg.screen.centerX, cfg.screen.centerY);
            % Set text size and font
            Screen('TextSize', cfg.screen.pointer, cfg.format.fontSizeText);
            Screen('TextFont', cfg.screen.pointer, cfg.format.font);
            % Draw the texture to the window
            Screen('DrawTexture', cfg.screen.pointer, texture, [], dst_rect_arousal);
            % Draw circles
            [start_x,y_position,space_between_circles,circle_radius] = drawCircles(cfg.screen.centerX, cfg.screen.centerY, imageArray_arousal, cfg.screen.pointer, 'surround', 0);
            % Update the display
            ArousalTime = Screen('Flip', cfg.screen.pointer);
            % -------------------------------------------
            if cfg.info.parallel_port; parallel_port(6); end   % Send to NetStation
            NetStation('Event','EVEN',ArousalTime, 0.001, 'arou',5); NetStation('FlushReadbuffer');                                                                        
            ev = logEvent(ev, event_, GetSecs(), NaN, 'DIN6', state, start_exp, 500);            
            % -------------------------------------------            
            % Initialize variables for circle clicks
            clicked_in_circle = false;

            while ~clicked_in_circle
                % Check for mouse clicks
                [clicks, x, y, ~] = GetClicks(cfg.screen.pointer, 0);
                if clicks
                    for i = 1:9
                        current_x = start_x + (i-1) * space_between_circles;
                        distance_squared = (x - current_x)^2 + (y - y_position)^2;
                        if distance_squared <= circle_radius^2
                            rt_arousal(trial_)   = GetSecs() - ArousalTime;
                            % Redraw all circles
                            Screen('DrawTexture', cfg.screen.pointer, texture, [], dst_rect_arousal);
                            drawCircles(cfg.screen.centerX, cfg.screen.centerY, imageArray_arousal, cfg.screen.pointer, 'surround', i);
                            tAroResp = Screen('Flip', cfg.screen.pointer);
                            % Send event marker
                            if cfg.info.parallel_port; parallel_port(21); end   % Send to NetStation
                            NetStation('Event','EVEN',tAroResp, 0.001, 'resa',21); NetStation('FlushReadbuffer'); 
                            ev = logEvent(ev, event_, GetSecs(), NaN, 'DI21', state, start_exp, 500);                                                        
                            % Update the clicked circle index                            
                            clicked_in_circle = true;
                            choiceArousal(trial_) = i;
                            fprintf('Arousal rating is %d\n', choiceArousal(trial_))
                            elCreateVariables(trial_, videoFile, rt_arousal(trial_))
                            pause(0.5)
                            HideCursor();  
                            break;  % Exit the for loop since circle is found
                        end
                    end
                end
            end
            % -------------------------------------------
            event_ = event_ + 1;
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
            NetStation('Event','EVEN',BlankTime, 0.001, 'blan',5); NetStation('FlushReadbuffer');                                                                                  
            ev = logEvent(ev, event_, GetSecs(), NaN, 'DIN7', state, start_exp, 500);                            
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
ev = logEvent(ev, event_, GetSecs(), 0, 'DI10', state, start_exp, 500);                            


% -------------------------------------------------------------------------
%                       Stop EEG recording
% -------------------------------------------------------------------------

NetStation('StopRecording')
NetStation('Disconnect')


% -------------------------------------------------------------------------
%                       Stop Eyetracker recording
% -------------------------------------------------------------------------
 
elFinish(cfg);
elCleanup();

% -------------------------------------------------------------------------
%                          Export task data
% -------------------------------------------------------------------------

% Create log table
addRunColumn = ones(n,1).*str2double(cfg.input{3});
addSubColumn = repmat(cfg.input{1}, n, 1); % Add the run and subject columns to the log variables
% Assuming logOnsets, logDurations, logTypes, logValues, logSamples are your log variables
logTable = table(addSubColumn, addRunColumn, choiceValence', rt_valence', choiceArousal', rt_arousal', stim',...
    'VariableNames', {'sub', 'run', 'valence', 'rt_valence', 'arousal', 'rt_arousal', 'stimulus'});

% Compute event duration
ev = logEventDurations(ev);
% Create event table
eventTable = table( ...
    ev.onsets', ...
    ev.durations', ...
    ev.types', ...
    ev.values', ...
    ev.samples', ...
    ev.time', ...
    'VariableNames', {'onset', 'duration', 'trial_type', 'value', 'sample', 'time'});
% Remove rows with no event type (unused events)
emptyRows = cellfun(@isempty, eventTable.trial_type);
eventTable(emptyRows, :) = [];

% Create flip table
usedRows = 1:flipIdx-1;

flipTable = table( ...
    flipLog.initial_call(usedRows), ...
    flipLog.predicted_onset(usedRows), ...
    flipLog.timestamp_return(usedRows), ...
    flipLog.missed(usedRows), ...
    flipLog.beampos(usedRows), ...
    flipLog.event_code(usedRows), ...
    'VariableNames', {'initial_call','predicted_onset','timestamp_return','missed','beampos','event_code'});


% -------------------------------------------------------------------------
%                          Convert File into TSV
% -------------------------------------------------------------------------

if cfg.export.exportTsv
    % Write the log table to a TSV file
    writetable(logTable, [cfg.paths.logs_path filesep cfg.text.logFileName '.tsv'], 'FileType', 'text', 'Delimiter', '\t');
    writetable(eventTable, [cfg.paths.event_path filesep cfg.text.eventFileName '.tsv'], 'FileType', 'text', 'Delimiter', '\t');    
    writetable(flipTable, [cfg.paths.event_path filesep cfg.text.flipFileName '.tsv'], 'FileType', 'text', 'Delimiter', '\t');        
end

% -------------------------------------------------------------------------
%                          Convert File into XLSX
% -------------------------------------------------------------------------

if cfg.export.exportXlsx
    % Write table
    writetable(logTable, [cfg.paths.logs_path filesep cfg.text.logFileName '.xlsx']);
    writetable(eventTable, [cfg.paths.event_path filesep cfg.text.eventFileName '.xlsx']);    
    writetable(flipTable, [cfg.paths.event_path filesep cfg.text.flipFileName '.xlsx']);
end


% -------------------------------------------------------------------------
%                                   Bye
% -------------------------------------------------------------------------
disp("====================================================================")
disp("============================ FINISHED ==============================")
disp("====================================================================")
cd(cfg.paths.task)


end