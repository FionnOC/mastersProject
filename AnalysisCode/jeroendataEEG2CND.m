%% This script takes raw EEG data and turns it into a CND format
% stim should be same length as the eeg data in structs
% dataStim folder contains the features
% first feature with envelope, see hilbert function
% second feature with onsets of laughter
% grouping of laughter in three categories
%
% first get trf based on univariate, one feature which is hilbert
% subsequently add more features (based on audio, and potentially video),
% and run more experiments.


%% Set paths
 
addpath(genpath('/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP'))

% Path to main folder
mainFolder = '/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/datasets/Laughter_Fionn';
cd(mainFolder)

% Folder specification
folderStimuli = "./Stimuli/"; % This could be an external stimulus (speech
                            % perception experiment) or other events, such
                            % as a continuous action (speech production)
folderBehavourial = './Behavourial/'; %Behavourial data
folderEEG = ".EEG_Jeroen";       % EEG data folder
folderCND = "./justJeroen/";   % Data in CEN format
folderAudio = fullfile(folderStimuli, 'Audio');

folderCutAudio = './finalCutAudio/';


% Other parameters  
numSubs = 4; % Subjects/Participants to include

% Load channel location file
load('./chanlocs64.mat') 
%% Read the raw data and turn it into a CND structure

% Uncomment the for loop when > 1 participant, also end in the end
for iiSub = 1:numSubs
    % iiSub = 2;
   
   
    if(iiSub == 1)
       subID = ['Sub',sprintf('%01d', iiSub)]; 
       [EEG,trigs] = Read_bdf('Sub1.bdf');
    
    elseif (iiSub == 2) % For participant 2, the second half of the experiment is shown first and the first half second, both in seperate bdf files
       subID = ['Sub',sprintf('%01d', iiSub)]; 
       [EEG1,trigs1] = Read_bdf('Sub2_firstHalf.bdf');
       [EEG2,trigs2] = Read_bdf('Sub2_secondHalf.bdf');
       EEG = [EEG1 EEG2];
       trigs = [trigs1 trigs2];

    else
       subID = ['Sub',sprintf('%01d', iiSub)];
        this_bdf_file = strcat(subID, '.bdf');
        [EEG,trigs] = Read_bdf(this_bdf_file);

    end
   
  

    %% Normalise trigger values    
    % Normalise trigger values to 0 and 1

    trigs(trigs == max(trigs)) = min(trigs);
    trigs=trigs-min(trigs);
    trigs(trigs>256) = trigs(trigs>256)-min(trigs(trigs>256));
    
    % Add zeros at the start of trigs with a total length of one second
    fs = 512; % Sampling rate in Hz
    numZeros = fs; % Number of zeros to add (equivalent to one second)
    
    trigs = [zeros(1, numZeros), trigs];


    %% Find triggers for start of trials
    
    % Find unique trigger values
    unique(trigs)

    % Find the indices of values equal to 1
    indices = find(trigs == 1); % the nr of indices can be more than nr of trials since trigger can last longer than 1 sample

    % If a triggers last more than one sample, only take the first one and remove subsequent samples
    uniqueIDtrl = indices(diff([0 indices]) ~= 1);
    
    % Rename
    trlStarts = uniqueIDtrl;

    % Display the indices
    disp(indices);


%% Get lenghts of the audiofragments expressed in samples, take into account the new sampling rate
% % % 
% % % % Get a list of all audio files in the folder
% % %     fileList = dir(fullfile(folderAudio, '*.wav')); % Update the file extension if needed
% % % 
% % % % Initialize an array to store fragment lengths
% % %     fragmentLengths = [];
% % % 
% % % % Recording sampling rate
% % %     fs = 512; % Hz
% % % 
% % % 
% % %     if (iiSub == 1)
% % % 
% % %         cutFileList = dir(fullfile(folderCutAudio, '**', '*.wav')); 
% % % 
% % %         subFolders = dir(folderCutAudio);
% % %         subFolders = subFolders([subFolders.isdir]); 
% % %         subFolders = subFolders(~ismember({subFolders.name}, {'.', '..'})); 
% % % 
% % %         for i = 8:numel(subFolders)
% % %             subFolderPath = fullfile((folderCutAudio), subFolders(i).name);
% % % 
% % %             fileList = dir(fullfile(subFolderPath, '*.wav'));
% % % 
% % %             for j = 1:numel(fileList)
% % %                 filePath = fullfile(subFolderPath, fileList(j).name);
% % %                 [audioData, sampleRate] = audioread(filePath);
% % % 
% % %                 % Calculate the length of the audio file in samples
% % %                 numSamples = numel(audioData);
% % %                 lengthInSeconds = numSamples / sampleRate;
% % %                 lengthInSamples = round(lengthInSeconds * fs);
% % % 
% % %                 % Append the length of the fragment to the array
% % %                 fragmentLengths = [fragmentLengths, lengthInSamples];
% % % 
% % %                 % Display the length of the audio file
% % %                 fprintf('File: %s\n', fileList(j).name);
% % %                 fprintf('Length in samples: %d\n', lengthInSamples);
% % %             end
% % % 
% % % 
% % %         end
% % % 
% % % 
% % %     else
% % %         % Loop through each audio file
% % %         for i = 1:numel(fileList)
% % %             filePath = fullfile(folderAudio, fileList(i).name);
% % %             [audioData, sampleRate] = audioread(filePath);
% % % 
% % %             numSamples = numel(audioData);
% % %             lengthInSeconds = numSamples / sampleRate;
% % %             lengthInSamples = round(lengthInSeconds * fs);
% % % 
% % %             fragmentLengths = [fragmentLengths, lengthInSamples];
% % % 
% % %             fprintf('File: %s\n', fileList(i).name);
% % %             fprintf('Length in samples: %d\n', lengthInSamples);
% % %         end
% % %     end
% % % 


    %% Segment EEG based on trial length

    cutFileList = dir(fullfile(folderCutAudio, '**', '*.wav')); % Update '*.wav' to match your file extension
    
    subFolders = dir(folderCutAudio);
    subFolders = subFolders([subFolders.isdir]); % Keep only directories
    subFolders = subFolders(~ismember({subFolders.name}, {'.', '..'})); % Remove '.' and '..'

    if (iiSub == 1)
    
        neuralChunks = cell(1, 7);
        extMastoids = cell(1, 7);
        extCheek= cell(1, 7);

        count = 1;
        for i = 1:7
            stimStart = trlStarts(i);
            subFolderPath = fullfile((folderCutAudio), subFolders(i+7).name);
            
            subFileList = dir(fullfile(subFolderPath, '*.wav'));

            for j = 1:numel(subFileList)
                filePath = fullfile(subFolderPath, subFileList(j).name);
                [audioData, sampleRate] = audioread(filePath);
            
                numSamples = numel(audioData);
                lengthInSeconds = numSamples / sampleRate;
                lengthInSamples = round(lengthInSeconds * fs);
                fragmentLengths = [fragmentLengths, lengthInSamples];
            
                fprintf('File: %s\n', subFileList(j).name);
                fprintf('Length in samples: %d\n', lengthInSamples);

                stimEnd  = stimStart + lengthInSamples;
                neuralChunks{count} = EEG(1:64, stimStart:stimEnd)';
                extMastoids{count} = EEG([65,66], stimStart:stimEnd)';
                extCheek{count} = EEG(67, stimStart:stimEnd)';

                count = count + 1;
                stimStart = stimEnd;

            end

            
        end



    elseif (iiSub == 8)
        neuralChunks = cell(1, length(cutFileList));
        extMastoids = cell(1, length(cutFileList));
        extCheek= cell(1, length(cutFileList));

        for i=1:length(cutFileList)
            stimStart = trlStarts(i);
            stimEnd = trlStarts(i) + fragmentLengths(i);
            
            neuralChunks{i} = EEG(1:64, stimStart:stimEnd)';
            extMastoids{i} = EEG([65,66], stimStart:stimEnd)';
            extCheek{i} = EEG(67, stimStart:stimEnd)';
        end
        
        
    else    
        neuralChunks = cell(1, length(fileList));
        extMastoids = cell(1, length(fileList));
        extCheek= cell(1, length(fileList));
        
        count = 1;

        for i=1:numel(subFolders)
            stimStart = trlStarts(i);
            
            subFolderPath = fullfile((folderCutAudio), subFolders(i).name);
            subFileList = dir(fullfile(subFolderPath, '*.wav'));

            for j = 1:numel(subFileList)
                filePath = fullfile(subFolderPath, subFileList(j).name);
                [audioData, sampleRate] = audioread(filePath);
            
                numSamples = numel(audioData);
                lengthInSeconds = numSamples / sampleRate;
                lengthInSamples = round(lengthInSeconds * fs);
                fragmentLengths = [fragmentLengths, lengthInSamples];
            
                fprintf('File: %s\n', subFileList(j).name);
                fprintf('Length in samples: %d\n', lengthInSamples);

                stimEnd  = stimStart + lengthInSamples;
                neuralChunks{count} = EEG(1:64, stimStart:stimEnd)';
                extMastoids{count} = EEG([65,66], stimStart:stimEnd)';
                extCheek{count} = EEG(67, stimStart:stimEnd)';

                count = count + 1;
                stimStart = stimEnd;

            end

        end
    end

    disp("Chunking done")


    %% Info for eeg structure

    eeg.dataType = 'EEG';
    eeg.deviceName = 'BioSemi ActiveTwo';
    eeg.data = neuralChunks;

    % Fill up extChan
    eeg.extChan{1}.data = extMastoids;
    eeg.extChan{1}.description = 'Mastoids';

    eeg.extChan{2}.data = extCheek;
    eeg.extChan{2}.description = 'Cheek';

    eeg.fs = fs;
    eeg.chanlocs = chanlocs;
    eeg.trlStarts = trlStarts;


    %% Save eeg

    filePath = fullfile(mainFolder, folderCND, ['newJeroenSub', subID, '.mat']);
    
    % Save the variable to a MAT file
    save(filePath, 'eeg');




end
