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

% addpath(genpath('C:\Users\oconnof9\OneDrive\Documenten\Trinity College Dublin\Courses\Dissertation\CNSP'))
 
addpath(genpath('/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP'))

% Path to main folder
mainFolder = '/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/datasets/Laughter_Fionn';
cd(mainFolder)

% Folder specification
folderStimuli = "./Stimuli/"; % This could be an external stimulus (speech
                            % perception experiment) or other events, such
                            % as a continuous action (speech production)
folderBehavourial = './Behavourial/'; %Behavourial data
folderEEG = ".EEG";       % EEG data folder
folderCND = "./fionnCND/";   % Data in CEN format
folderAudio = fullfile(folderStimuli, 'Audio');

folderCutAudio = './finalCutAudio/';


% Other parameters  
numSubs = 6; % Subjects/Participants to include

% Load channel location file
load('./chanlocs64.mat') % Is this correct?

%% Read the raw data and turn it into a CND structure

% Uncomment the for loop when > 1 participant, also end in the end
for iiSub = 1:numSubs
    % iiSub = 4;
   
   
    if(iiSub == 1)
       subID = ['subject',sprintf('%01d', iiSub)]; 
       % [EEG,trigs] = Read_bdf([strcat(folderEEG, '/subject2.bdf')]);
       [EEG,trigs] = Read_bdf('subject1.bdf');
       disp('1');

    elseif (iiSub == 2)
        subID = ['subject',sprintf('%01d', iiSub)]; 
        [EEG,trigs] = Read_bdf('subject2.bdf');
        disp('2');

    else
        disp(iiSub);
        subID = ['subject',sprintf('%01d', iiSub)];
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
    endIndices = find(trigs == 0);

    % if (iiSub == 3)
    %     newStartIndices = find(trigs == 2);
    %     newEndIndices = find(trigs == 3);

    if (iiSub == 4 || iiSub == 5 || iiSub == 6)
        newStartIndices = find(trigs == 1);
        newEndIndices = find(trigs == 2);
    end

    

%%
    % If a triggers last more than one sample, only take the first one and remove subsequent samples
    uniqueIDtrl = indices(diff([0 indices]) ~= 1);
    uniqueENDIDtrl = endIndices(diff([0 endIndices]) ~= 1);
    % 
    % if (iiSub == 3)
    %     newUniqueIDtrl = newStartIndices(diff([0 newStartIndices]) ~= 1);
    %     newUniqueENDIDtrl = newEndIndices(diff([0 newEndIndices]) ~= 1);

    if (iiSub == 4 || iiSub == 5 || iiSub == 6)
        newUniqueIDtrl = newStartIndices(diff([0 newStartIndices]) ~= 1);
        newUniqueENDIDtrl = newEndIndices(diff([0 newEndIndices]) ~= 1);
    end
    %%
    
    % Rename
    if (iiSub == 4 || iiSub == 5 || iiSub == 6)
        trlStarts = newUniqueIDtrl;
        trlEnds = newUniqueENDIDtrl;
    else
        trlStarts = uniqueIDtrl;
        trlEnds = uniqueENDIDtrl;
    end


%% Get lenghts of the audiofragments expressed in samples, take into account the new sampling rate

% Get a list of all audio files in the folder
    % fileList = dir(fullfile(folderAudio, '*.wav')); % Update the file extension if needed

% Initialize an array to store fragment lengths
    fragmentLengths = [];

% Recording sampling rate
    fs = 512; % Hz

    cutFileList = dir(fullfile(folderCutAudio, '**', '*.wav')); % Update '*.wav' to match your file extension
    
    subFolders = dir(folderCutAudio);
    subFolders = subFolders([subFolders.isdir]); % Keep only directories
    subFolders = subFolders(~ismember({subFolders.name}, {'.', '..'})); % Remove '.' and '..'

    for i = 1:numel(subFolders)
        subFolderPath = fullfile((folderCutAudio), subFolders(i).name);
        
        fileList = dir(fullfile(subFolderPath, '*.wav'));

        for j = 1:numel(fileList)
            filePath = fullfile(subFolderPath, fileList(j).name);
            [audioData, sampleRate] = audioread(filePath);
        
            % Calculate the length of the audio file in samples
            numSamples = numel(audioData);
            lengthInSeconds = numSamples / sampleRate;
            lengthInSamples = round(lengthInSeconds * fs);
            
            % Append the length of the fragment to the array
            fragmentLengths = [fragmentLengths, lengthInSamples];
        
            % Display the length of the audio file
            fprintf('File: %s\n', fileList(j).name);
            fprintf('Length in samples: %d\n', lengthInSamples);
        end
        
    end



    %% Segment EEG based on trial length
    
    if (iiSub == 1 || iiSub == 2 || iiSub == 3)
    
        neuralChunks = cell(1, length(fileList));
        extMastoids = cell(1, length(fileList));
        extCheek= cell(1, length(fileList));

        count = 1;
        for i = 1:numel(subFolders)
            stimStart = trlStarts(i);
            subFolderPath = fullfile((folderCutAudio), subFolders(i).name);
            
            subFileList = dir(fullfile(subFolderPath, '*.wav'));

            for j = 1:numel(subFileList)
                stimEnd  = stimStart + fragmentLengths(count);
                neuralChunks{count} = EEG(1:64, stimStart:stimEnd)';
                extMastoids{count} = EEG([65,66], stimStart:stimEnd)';
                extCheek{count} = EEG(67, stimStart:stimEnd)';

                count = count + 1;
                stimStart = stimEnd;

            end

            
        end



    elseif (iiSub == 4 || iiSub == 5 || iiSub == 6)
        neuralChunks = cell(1, length(cutFileList));
        extMastoids = cell(1, length(cutFileList));
        extCheek= cell(1, length(cutFileList));

        for i=1:length(cutFileList)
            % Epoch the data here (important!) 
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
        for i = 1:numel(subFolders)
            stimStart = trlStarts(i);
            subFolderPath = fullfile((folderCutAudio), subFolders(i).name);
            
            subFileList = dir(fullfile(subFolderPath, '*.wav'));

            for j = 1:numel(subFileList)
                filePath = fullfile(subFolderPath, subFileList(j).name);
                [audioData, sampleRate] = audioread(filePath);
            
                % Calculate the length of the audio file in samples
                numSamples = numel(audioData);
                lengthInSeconds = numSamples / sampleRate;
                lengthInSamples = round(lengthInSeconds * fs);
                
                % Append the length of the fragment to the array
                fragmentLengths = [fragmentLengths, lengthInSamples];
            
                % Display the length of the audio file
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
%     eeg.extChan{2}.data = extOcularHor;
%     eeg.extChan{2}.description = 'Horizontal eye movements (Right eye)';
    eeg.extChan{2}.data = extCheek;
    eeg.extChan{2}.description = 'Cheek';

    eeg.fs = fs;
    eeg.chanlocs = chanlocs;
    eeg.trlStarts = trlStarts;
    eeg.trlEnds = trlEnds;
    % eeg.lengthTriggers = trlDifferences;
    %eeg.origTrialPosition = stimOriginal;


    %% Save eeg
    %save([mainFolder, folderCND,'data',subID,'.mat'],'eeg')

    % Specify the file path for saving
    filePath = fullfile(mainFolder, folderCND, ['fionn', subID, '.mat']);
    
    % Save the variable to a MAT file
    save(filePath, 'eeg');




end


% downFs = 512;
% [audioStream,fsAudio] = audioread('audio.wav');
% env = abs(hilbert(audioStream(:,1)));
% env = resample(env,downFs,fsAudio);
%