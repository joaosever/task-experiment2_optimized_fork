function generate_sequences(cfg)
    % Generates random sequences by shuffling filepaths
    
    % Explicitly seed the random number generator
    rng('shuffle');
    
    % Settings
    moveAvi         = false;
    createSequence  = true;
    method          = 'pre-built'; % {'real-time', 'pre-built'};
    filesForEachRun = 50; % Files for each run (half)
    numOfRuns       = 1; 

    
    % Directories
    cfg.paths.allstim_path   = fullfile(cfg.paths.local.sourcedata, 'supp', 'allStimuli');
    cfg.paths.stim_path      = fullfile(cfg.paths.local.sourcedata, 'supp', 'stimuli');
    
    
    % % move avi files if required
    % if moveAvi
    %     move_avi_files(cfg)
    % end
    
    if createSequence
    
        if strcmpi(method,'real-time')
    
            % Assign numbers to each file
            stimFilesCurated = dir(fullfile(cfg.paths.stim_path, '*.avi'));
            numFiles = length(stimFilesCurated);
            fileNumbers = 1:numFiles;
            fileNames = {stimFilesCurated.name}';
            
            % Create a table with numbers and filenames
            fileTable = table(fileNumbers', fileNames, 'VariableNames', {'Number', 'FileName'});
            
            % Randomize numbers
            randomOrder = randperm(numFiles);
            
            % Select 30 numbers for the first sequence
            sequenceFilesComplete = fileTable.FileName;
            sequenceFilesComplete(randomOrder) = fileTable.FileName;
            
            % Save
            cd(fullfile(cfg.paths.task,'sequences'))
            save('sequence1.mat', 'sequenceFiles', 'sequenceNumbers')
            
            % % Perform second randomization for sequence2 (Ensure no overlap with sequence1)
            remainingNumbers = setdiff(randomOrder, sequenceNumbers);
            sequenceNumbers = remainingNumbers(randperm(filesForEachRun)); % Re-shuffle!!!
            sequenceFiles = fileTable.FileName(sequenceNumbers);
            
            % Save
            save('sequence2.mat', 'sequenceFiles', 'sequenceNumbers');
    
        elseif strcmpi(method,'pre-built')
    
            % Assign numbers to each file
            stimFilesCurated = dir(fullfile(cfg.paths.stim_path, '*.mp4'));
            numFiles = length(stimFilesCurated);
            fileNumbers = 1:numFiles;
            fileNames = {stimFilesCurated.name}';
            
            % Create a table with numbers and filenames
            fileTable = table(fileNumbers', fileNames, 'VariableNames', {'Number', 'FileName'});
            
            % Randomize numbers
            randomOrder = randperm(numFiles);
            sequenceFilesComplete = fileTable.FileName(randomOrder);
            % Save complete randomized sequence
            save(strcat('sequences\','ranseq-',char(datetime, 'yyyyMMdd_HHmmss'),'.mat'), 'sequenceFilesComplete')
            % Save run 1 sequence
            sequenceFiles1 = sequenceFilesComplete(1:filesForEachRun);   
            cd(fullfile(cfg.paths.task,'sequences'))
            save('sequence1.mat', 'sequenceFiles1', 'randomOrder')
            % Save run 2 sequence
            sequenceFiles2 = sequenceFilesComplete(filesForEachRun+1:end);       
            cd(fullfile(cfg.paths.task,'sequences'))
            save('sequence2.mat', 'sequenceFiles2', 'randomOrder')
            % Output sequence side by side
            out_sequence = {sequenceFiles1{:}; sequenceFiles2{:}};
            disp(out_sequence');
            if length(unique(out_sequence))~=filesForEachRun*numOfRuns
                error('Stimulus randomization went wrong...')
            end
        end
    end
    
    cd(cfg.paths.task)

end


function move_avi_files(cfg)
    stimFolders   = dir(cfg.paths.cfg.paths.allstim_path); % Get only folders
    stimFolders   = stimFolders([stimFolders.isdir]); % Remove non-folders
    
    % Move all .avi files
    for i = 1:length(stimFolders)
        stimFiles = dir(fullfile(cfg.paths.cfg.paths.allstim_path, stimFolders(i).name, '*.avi'));
        for j = 1:length(stimFiles)
            copyfile(fullfile(cfg.paths.cfg.paths.allstim_path, stimFolders(i).name, stimFiles(j).name), fullfile(cfg.paths.stim_path, stimFiles(j).name));
        end
    end
end
