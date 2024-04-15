clear all
close all
clc

addpath /Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/libs/cnsp_utils
addpath /Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/libs/cnsp_utils/cnd
addpath /Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/libs/mTRF-Toolbox_v2/mtrf
addpath /Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/libs/NoiseTools
addpath /Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/libs/eeglab_old/
% eeglab

% Path to main folder
dataMainFolder = '/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/datasets/Laughter_Fionn/';
cd(dataMainFolder);

% dataMainFolder = '../datasets/LalorNatSpeechReverse/';
% dataCNDSubfolder = 'joinCND/';
dataCNDSubfolder = 'changeBandpassCND/';
dataStimSubfolder = 'dataStim/';

dim2plot = 1:3;

reRefType = 'Mastoids'; % or 'Mastoids'
bandpassFilterRange = [1,8]; % Hz (indicate 0 to avoid running the low-pass
                          % or high-pass filters or both)
                          % e.g., [0,8] will apply only a low-pass filter
                          % at 8 Hz
downFs = 128; % Hz. *** fs/downFs must be an integer value ***

% eegFilenames = dir([dataMainFolder, dataCNDSubfolder,'dataSub*.mat']);
eegFilenames = dir([dataMainFolder, dataCNDSubfolder,'subject*.mat']);

namesToRemove = {'subject1.mat', 'subject2.mat', 'subject3.mat', 'subject4.mat', 'subject5.mat'};

indicesToRemove = contains({eegFilenames.name}, namesToRemove);

eegFilenames(indicesToRemove) = [];

% Assuming your struct array is named 'structArray'

firstStruct = eegFilenames(1);

% Remove the first struct from the array
eegFilenames(1) = [];

% Concatenate the first struct at the end
eegFilenames = [eegFilenames; firstStruct];


if downFs < bandpassFilterRange(2)*2
    disp('Warning: Be careful. The low-pass filter should use a cut-off frequency smaller than downFs/2')
end

nSubs = 5;
% model


% TRF hyperparameters
tmin = -200;
tmax = 600;
% lambdas = [1e-2,1e0,1e2]; % small set of lambdas (quick)
lambdas = [1e-6,1e-3,1e-4,1e-3,1e-2,1e-1,1e0,1,1e2,1e3,1e4]; % larger set of lambdas (slower)
dirTRF = 1; % Forward TRF model
% Be careful: backward models (dirTRF-1) with many electrodes and large time-windows
% can require long computational time   s. So, we suggest reducing the
% dimensionality if you are just playing around with the code (e.g., select
% only few electrodes and/or reduce the TRF window)

% Loading Stimulus data
stimFilename = [dataMainFolder,dataStimSubfolder,'enjoymentFeature0304.mat'];
disp(['Loading stimulus data: ','enjoymentFeature0304.mat'])
load(stimFilename,'behaviourFeature');

stimFilename = [dataMainFolder,dataStimSubfolder,'fionnDataStim.mat'];
disp(['Loading stimulus data: ','fionnDataStim.mat'])
load(stimFilename,'stims')

% Downsampling stim if necessary
if downFs < stims.fs
    stims = cndDownsample(stims,downFs);
end


% join onsets with enjoyment?
lwo = stims.data(12, :);
laughter = stims.data(14, :);

for i = 1:length(laughter)
    laughterOnsets{i} = laughter{1, i}(:, 2);
end


%%

% TRF
clear rAll rAllElec modelAl l
figure('Position',[100,100,600,600]);


for sub = 1:nSubs
% Loading preprocessed EEG
    eegPreFilename = [dataMainFolder,dataCNDSubfolder,'pre_',eegFilenames(sub).name];
    disp(['Loading preprocessed EEG data: pre_',eegFilenames(sub).name])
    load(eegPreFilename,'eeg');

    stimFeature.data = behaviourFeature(sub,:); % envelope or word onset
    % 
    % for i = 1:length(stimFeature.data)
    %     stimFeature.data{1, i}(:, 2) = lwo{1, i};
    %     stimFeature.data{1, i}(:, 3) = laughterOnsets{1, i};
    % end
    
    stimFeature.fs = 128;
    % disp(sub);
    % disp("sub");

    % i need to shuffle the stimuli
    % 
    % for i = 1:numel(stimFeature.data)
    %     [rows, cols] = size(stimFeature.data{i});
    %     for j = 1:cols
    %         shuffledIndex = randperm(rows);
    %         column = stimFeature.data{i}(:, j);
    % 
    %         shuffledColumn = column(shuffledIndex);
    % 
    %         stimFeature.data{i}(:, j) = shuffledColumn;
    %     end
    % end


    % Making sure that stim and neural data have the same length
    % The trial may end a few seconds after the end of the audio
    % e.g., the neural data may include the break between trials
    % It would be best to do this chunking at preprocessing, but let's
    % check here, just to be sure
    [stimFeature,eeg] = cndCheckStimNeural(stimFeature,eeg);
    
    % Standardise stim data (preserving the ratio between features)
    % This is thought for continuous signals e.g., speech envelope, eeg
    stimFeature = cndNormaliseStim(stimFeature);

    % Standardise neural data (preserving the ratio between channels)
    eeg = cndNormalise(eeg);
        
    % TRF crossvalidation - determining optimal regularisation parameter
    disp('Running mTRFcrossval')
    % [stats,t] = mTRFcrossval(stimFeature.data,eeg.data,eeg.fs,dirTRF,tmin,tmax,lambdas,'verbose',0);
    eegData = eeg.data;
    eegData2 = eeg.extChan{1, 2}.data;
    
    for i = 1:length(eeg.data)
        lengthEEG = length(eegData{1, i});
        lengthExt = length(eegData2{1, i});

        if lengthEEG ~= lengthExt
            % eegData{1, i}(:, 65) = eeg.extChan{1, 2}.data{1, i};
            eegData2{1, i} = eegData2{1, i}(1:lengthEEG, :);

        end
    end

    %%% this is for just the external
    % [stats,t] = mTRFcrossval(stimFeature.data,eegData2,eeg.fs,dirTRF,tmin,tmax,lambdas,'verbose',0);

    [stats,t] = mTRFcrossval(stimFeature.data,eegData2,eeg.fs,dirTRF,tmin,tmax,lambdas,'verbose',0);

    % Calculating optimal lambda. Display and store results
    [maxR,bestLambda] = max(squeeze(mean(mean(stats.r,1),3)));
    disp(['r = ',num2str(maxR)])
    rAll(sub) = maxR;
    rAllElec(:,sub) = squeeze(mean(stats.r(:,bestLambda,:),1));
    
    
    % Fit TRF model with optimal regularisation parameter
    disp('Running mTRFtrain')
    % model = mTRFtrain(stimFeature.data,eeg.data,eeg.fs,dirTRF,tmin,tmax,lambdas(bestLambda),'verbose',0);
    model = mTRFtrain(stimFeature.data, eegData2, eeg.fs,dirTRF,tmin,tmax,lambdas(bestLambda),'verbose',0);
    
    % Store TRF model
    modelAll(sub) = model;  

    model2plot = modelAll;
    % for iiSub = 1:length(model2plot)
    %     model2plot(iiSub).w = mean(model2plot(iiSub).w(dim2plot,:,:),1);
    % end

    % Check to see if normalising in mTRF_plotForwardTRF function
    if dirTRF == 1
        mTRF_plotForwardTRF_externalElec(eeg,model2plot,rAllElec);
        % mTRF_plotForwardTRF(eeg,model2plot,rAllElec);
    elseif dirTRF == -1
        mTRF_plotBackwardTRF(eeg,model2plot,rAllElec);
    end
    
    disp(['Mean r = ',num2str(mean(rAll))])
    
    drawnow;
end

%%

folderSave = "./sliderModels";
save(fullfile(folderSave, 'enjoymentLWOLaughterAllEEGModel.mat'), 'modelAll');

save(fullfile(folderSave, 'enjoymentLWOLaughterAllEEGModel_rAllElec.mat'), 'rAllElec');

   
