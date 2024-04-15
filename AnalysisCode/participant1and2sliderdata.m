clear
close all
clc

addpath /Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/libs/cnsp_utils
addpath /Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/libs/cnsp_utils/cnd
addpath /Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/libs/mTRF-Toolbox_v2/mtrf
addpath /Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/libs/NoiseTools
addpath /Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/libs/eeglab_old/

dataMainFolder = '/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/datasets/Laughter_Fionn/';
cd(dataMainFolder);

filesFolder = "finalCutAudio/";
behaviorFolder = fullfile(dataMainFolder, 'behaviorProcessed/');

data1Filename = fullfile(behaviorFolder, 'allTrialData0104.mat');

data = load(data1Filename, 'allTrialData');
data = data.allTrialData;

subject1 = data(1, :);

folderPath = fullfile(dataMainFolder, filesFolder);

subFolders = dir(fullfile(folderPath));
% Keep only directories
subFolders = subFolders([subFolders.isdir]);  
% Remove '.' and '..'
subFolders = subFolders(~ismember({subFolders.name}, {'.', '..'}));  


fileLengthsCell = cell(1, numel(subFolders));

for folder = 1:numel(subFolders)
    subfolderName = fullfile(folderPath, subFolders(folder).name);
    
    wavFiles = dir(fullfile(subfolderName, '*.wav'));
    
    fileLengths = zeros(1, numel(wavFiles));
    
    for file = 1:numel(wavFiles)
        fileName = fullfile(subfolderName, wavFiles(file).name);
        [data, sampleRate] = audioread(fileName);
        fileLengths(file) = size(data, 1) / sampleRate;
    end
    
    fileLengthsCell{folder} = fileLengths;
end


%% now do 1 and 2
allSubArrays = [];

subjects = data(1:2, :);

[numSubs, ~] = size(subjects);

storeArrays = {};

for participant = 1:numSubs
    disp("Participant ", num2str(participant));

    allSubArrays = [];

    subject = subjects(participant, :);

    for trial = 1:length(subject)
        disp("Trial ", num2str(trial));
        fileLengthsTrial = fileLengthsCell{trial};
    
        initialTime = subject(trial).startTime;
        startTimes = [initialTime];
    
        for i = 1:length(fileLengthsTrial) - 1
            next = sum(fileLengthsTrial(1:i));
            
            nextStart = initialTime + next;
            startTimes = [startTimes, nextStart];
        
        end
    
        trialData = subject(trial).data;
        trialData = cell2mat(trialData);
        
        subArrays = cell(1, length(startTimes));
        
        lengthList = length(startTimes);
        
        for i = 1:lengthList
            timestamps = trialData(:, 1);
        
            if i == lengthList
                disp("Last");
                subArray = trialData(1:end, :);
                subArrays{i} = subArray;
                break; 
            end
        
            disp(["Loop ", num2str(i)]);
            nextStart = startTimes(i + 1);
        
            [~, idx] = min(abs(timestamps - nextStart));
        
            finish = idx - 1;
        
            subArray = trialData(1:finish, :);
        
            subArrays{i} = subArray;
        
            trialData = trialData(idx:end, :);
        
        end
    
        allSubArrays = [allSubArrays, subArrays];
    end

    for i = 1:length(allSubArrays)
        data = allSubArrays{i};
        data = data(data(:, 1) ~= 0, :);
        allSubArrays{i} = data;

    end

    storeArrays = [storeArrays;allSubArrays];
end



%% testing - now read in subject 1

allSubArrays = [];

for trial = 1:length(subject1)
    fileLengthsTrial = fileLengthsCell{trial};

    initialTime = subject1(trial).startTime;
    startTimes = [initialTime];

    for i = 1:length(fileLengthsTrial) - 1
        next = sum(fileLengthsTrial(1:i));
        
        nextStart = initialTime + next;
        startTimes = [startTimes, nextStart];
    
    end

    trialData = subject1(trial).data;
    trialData = cell2mat(trialData);
    
    subArrays = cell(1, length(startTimes));
    
    lengthList = length(startTimes);
    
    for i = 1:lengthList
        timestamps = trialData(:, 1);
    
        if i == lengthList
            disp("Last");
            subArray = trialData(1:end, :);
            subArrays{i} = subArray;
            break; 
        end
    
        disp(["Loop ", num2str(i)]);
        nextStart = startTimes(i + 1);
    
        [~, idx] = min(abs(timestamps - nextStart));
    
        finish = idx - 1;
    
        subArray = trialData(1:finish, :);
    
        subArrays{i} = subArray;
    
        trialData = trialData(idx:end, :);
    
    end

    allSubArrays = [allSubArrays, subArrays];
end


%%

folderSave = "./behaviour0104";
save(fullfile(folderSave, 'subs1_2.mat'), 'storeArrays');



