clear
close all
clc

addpath /Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/libs/cnsp_utils
addpath /Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/libs/cnsp_utils/cnd
addpath /Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/libs/mTRF-Toolbox_v2/mtrf
addpath /Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/libs/NoiseTools
addpath /Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/libs/eeglab_old/
% eeglab

dataMainFolder = '/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/datasets/Laughter_Fionn/';
cd(dataMainFolder);

behaviorFolder = fullfile(dataMainFolder, 'behaviorProcessed/');

dataCNDSubfolder = 'joinCND/';

data1Filename = fullfile(behaviorFolder, 'allTrialData0104.mat');
% data2Filename = fullfile(behaviorFolder, 'allTrialDataStrings.mat');

data = load(data1Filename, 'allTrialData');
data = data.allTrialData;

subject3 = data(3, :);

% eegPreFilename = [dataMainFolder,dataCNDSubfolder,'pre_',eegFilenames(sub).name];
% disp(['Loading preprocessed EEG data: pre_',eegFilenames(sub).name])
%     load(eegPreFilename,'eeg')


%%
% each row of data is a different participant
% each column is a different trial

%% try to take just trial 1 with exp 3, 4, 5

trialData = data(3, 1).data;
trialData = cell2mat(trialData);

startTimes = data(3, 1).startTime;

subArrays = cell(1, length(startTimes));

lengthList = length(startTimes);

for i = 1:lengthList
    timestamps = trialData(:, 1);

    if i == 5
        disp("Last");
        subArray = trialData(1:end, :);
        subArrays{i} = subArray;
        break; 
    end

    disp(["Loop ", num2str(i)]);
    nextStart = startTimes{i + 1};

    [~, idx] = min(abs(timestamps - nextStart));

    finish = idx - 1;

    subArray = trialData(1:finish, :);

    subArrays{i} = subArray;

    trialData = trialData(idx:end, :);

end


%% now extend for the entirity of participant 3

allSubArrays = [];

for trial = 1:length(subject3)

    trialData = subject3(trial).data;
    trialData = cell2mat(trialData);
    
    startTimes = subject3(trial).startTime;
    
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
        nextStart = startTimes{i + 1};
    
        [~, idx] = min(abs(timestamps - nextStart));
    
        finish = idx - 1;
    
        subArray = trialData(1:finish, :);
    
        subArrays{i} = subArray;
    
        trialData = trialData(idx:end, :);
    
    end

    allSubArrays = [allSubArrays, subArrays];

end

%% Now extend to all 3, 4, 5
% to run, run the top section and then this one. Will return a cell 1x55
% each 

subjects = data(3:5, :);

[numSubs, ~] = size(subjects);

storeArrays = {};

for participant = 1:numSubs
    disp("Participant", num2str(participant));

    allSubArrays = [];

    subject = subjects(participant, :);

    for trial = 1:length(subject)
        disp("Trial", num2str(trial));
    
        trialData = subject(trial).data;
        trialData = cell2mat(trialData);
        
        startTimes = subject(trial).startTime;
        
        subArrays = cell(1, length(startTimes));
        
        lengthList = length(startTimes);
        
        for i = 1:lengthList
            timestamps = trialData(:, 1);
        
            if i == lengthList
                % disp("Last");
                subArray = trialData(1:end, :);
                subArrays{i} = subArray;
                break; 
            end
        
            % disp(["Loop ", num2str(i)]);
            nextStart = startTimes{i + 1};
        
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

    storeArrays = [storeArrays; allSubArrays];
end
%%


folderSave = "./behaviour0104";
save(fullfile(folderSave, 'subs3_4_5.mat'), 'storeArrays');

%%
clear
subs1_2 = load('/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/datasets/Laughter_Fionn/behaviour0104/subs1_2.mat');
subs3_4_5 = load('/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/datasets/Laughter_Fionn/behaviour0104/subs3_4_5.mat');

subs1_2 = subs1_2.storeArrays;
subs3_4_5 = subs3_4_5.storeArrays;

stims = load('/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/datasets/Laughter_Fionn/dataStim/fionnDataStim.mat');
stims = stims.stims;
behaviour = [subs1_2; subs3_4_5];

%%

[numSubs, ~] = size(behaviour);

behaviourUpscaled = {};


for sub = 1:numSubs
    disp("check")
    subject = behaviour(sub, :);
    subBehaviour = [];

    for trial = 1:length(stims.data)
        trialData = subject{trial};
        lengthSlider = length(trialData);

        [rows, cols] = size(trialData);
        [upscaleRow, ~] = size(stims.data{1, trial});

        indices = linspace(1, rows, upscaleRow);
        upscaledArray = interp1(1:rows, trialData, indices, 'pchip');

        subBehaviour = [subBehaviour, {upscaledArray}];

    end

    behaviourUpscaled = [behaviourUpscaled; subBehaviour];

end

%%
close all
figure;
plot(behaviourUpscaled{1, 3}(:, 2), 'DisplayName', 'Subject 6');
hold on;
plot(behaviourUpscaled{2, 3}(:, 2), 'DisplayName', 'Subject 7');
plot(behaviourUpscaled{3, 3}(:, 2), 'DisplayName', 'Subject 8');
plot(behaviourUpscaled{4, 3}(:, 2), 'DisplayName', 'Subject 9');
plot(behaviourUpscaled{5, 3}(:, 2), 'DisplayName', 'Subject 10');

legend('show')
hold off;

%%

folderSave = "./behaviour0104";
save(fullfile(folderSave, 'upscaledBehaviour.mat'), 'behaviourUpscaled');
%% save behaviour as a feature?

% do i save it as 
behaviourFeature = {};
for trial = 1:length(behaviourUpscaled)
    behaviourFeature{1, trial} = behaviourUpscaled{1, trial}(:, 2);
    behaviourFeature{2, trial} = behaviourUpscaled{2, trial}(:, 2);
    behaviourFeature{3, trial} = behaviourUpscaled{3, trial}(:, 2);
    behaviourFeature{4, trial} = behaviourUpscaled{4, trial}(:, 2);
    behaviourFeature{5, trial} = behaviourUpscaled{5, trial}(:, 2);
end

