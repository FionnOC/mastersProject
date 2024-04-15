% Cognition and Natural Sensory Processing (CNSP) Workshop
% Example 1 - Forward TRF
%
% This example script loads and preprocesses a publicly available dataset
% (you can use any of the dataset in the CNSP resources). Then, the script
% runs a typical forward TRF analysis.
%
% Note:
% This code was written with the assumption that all subjects were
% presented with the same set of stimuli. Hence, we use a single stimulus
% file (dataStim.mat) that applies to all subjects. This is compatible
% with scenarios with randomise presentation orders. In that case, the
% EEG/MEG trials should be sorted to match the single stimulus file. 
% The original order is preserved in a specific CND variable. If distinct
% subjects were presented with different stimuli, it is necessary to
% include a stimulus file per participant.
%
% CNSP-Workshop 2022
% https://cnsp-workshop.github.io/website/index.html
% Author: Giovanni M. Di Liberto
% Copyright 2021 - Giovanni Di Liberto
%                  Nathaniel Zuk
%                  Michael Crosse
%                  Aaron Nidiffer
%                  Giorgia Cantisani
%                  (see license file for details)
% Last update: 24 June 2022

clear all
close all
clc

addpath /Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/libs/cnsp_utils
addpath /Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/libs/cnsp_utils/cnd
addpath /Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/libs/mTRF-Toolbox_v2/mtrf
addpath /Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/libs/NoiseTools
addpath /Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/libs/eeglab_old/
eeglab



%% Parameters - Natural speech listening experiment
% Path to main folder
dataMainFolder = '/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/datasets/Laughter_Fionn/';
cd(dataMainFolder);
dataCNDSubfolder = 'joinCND/';
dataStimSubfolder = 'dataStim/';

reRefType = 'Mastoids'; % or 'Mastoids'
bandpassFilterRange = [1,8]; % Hz (indicate 0 to avoid running the low-pass
                          % or high-pass filters or both)
                          % e.g., [0,8] will apply only a low-pass filter
                          % at 8 Hz
downFs = 128; % Hz. *** fs/downFs must be an integer value ***

% eegFilenames = dir([dataMainFolder, dataCNDSubfolder,'dataSub*.mat']);
eegFilenames = dir([dataMainFolder, dataCNDSubfolder,'subject*.mat']);

nSubs = length(eegFilenames);

if downFs < bandpassFilterRange(2)*2
    disp('Warning: Be careful. The low-pass filter should use a cut-off frequency smaller than downFs/2')
end

nSubs = 10;

%% Preprocess EEG - Natural speech listening experiment
for sub = 1:nSubs
    %sub = 3; 
    % Loading EEG data
    eegFilename = fullfile(dataMainFolder, dataCNDSubfolder, eegFilenames(sub).name);
    disp(['Loading EEG data: ',eegFilenames(sub).name]) %error because mismatch 1 and 2 subject
    load(eegFilename,'eeg')

    eeg = cndNewOp(eeg,'Load'); % Saving the processing pipeline in the eeg struct

    % Filtering - LPF (low-pass filter)
    if bandpassFilterRange(2) > 0
        hd = getLPFilt(eeg.fs,bandpassFilterRange(2));
        
        % A little coding trick - for loop vs cellfun
        if (0)
            % Filtering each trial/run with a for loop
            for ii = 1:length(eeg.data)
                eeg.data{ii} = filtfilthd(hd,eeg.data{ii});
            end
        else
            % Filtering each trial/run with a cellfun statement
            eeg.data = cellfun(@(x) filtfilthd(hd,x),eeg.data,'UniformOutput',false);
        end
        
        % Filtering external channels
        if isfield(eeg,'extChan')
            for extIdx = 1:length(eeg.extChan)
                eeg.extChan{extIdx}.data = cellfun(@(x) filtfilthd(hd,x),eeg.extChan{extIdx}.data,'UniformOutput',false);
            end
        end
        
        eeg = cndNewOp(eeg,'LPF');
    end
    
    % Downsampling EEG and external channels
    if downFs < eeg.fs
        eeg = cndDownsample(eeg,downFs);
    end
    
    % Filtering - HPF (high-pass filter)
    if bandpassFilterRange(1) > 0 
        hd = getHPFilt(eeg.fs,bandpassFilterRange(1));
        
        % Filtering EEG data
        eeg.data = cellfun(@(x) filtfilthd(hd,x),eeg.data,'UniformOutput',false);
        
        % Filtering external channels
        if isfield(eeg,'extChan')
            for extIdx = 1:length(eeg.extChan)
                eeg.extChan{extIdx}.data = cellfun(@(x) filtfilthd(hd,x),eeg.extChan{extIdx}.data,'UniformOutput',false);
            end  
        end
        
        eeg = cndNewOp(eeg,'HPF');
    end
    
    % Replacing bad channels
    if isfield(eeg,'chanlocs')
        for tr = 1:length(eeg.data)
            eeg.data{tr} = removeBadChannels(eeg.data{tr}, eeg.chanlocs);
        end
    end
    
    % Re-referencing EEG data
    eeg = cndReref(eeg,reRefType);
    
    % Removing initial padding (specific to this dataset)
%     if isfield(eeg,'paddingStartSample')
%         for tr = 1:length(eeg.data)
%             eeg.data{tr} = eeg.data{tr}(eeg.paddingStartSample,:);
%             for extIdx = 1:length(eeg.extChan)
%                 eeg.extChan{extIdx}.data = eeg.extChan{extIdx}.data{tr}(1+eeg.paddingStartSample,:);
%             end
%         end
%     end
    
    % Saving preprocessed data
    eegPreFilename = [dataMainFolder,dataCNDSubfolder,'pre_',eegFilenames(sub).name];
    disp(['Saving preprocessed EEG data: pre_',eegFilenames(sub).name])
    save(eegPreFilename,'eeg')
end

%% The multivariate Temporal Response Function

% TRF hyperparameters
tmin = -200;
tmax = 900;
% lambdas = [1e-2,1e0,1e2]; % small set of lambdas (quick)
lambdas = [1e-6,1e-3,1e-4,1e-3,1e-2,1e-1,1e0,1,1e2,1e3,1e4]; % larger set of lambdas (slower)
dirTRF = 1; % Forward TRF model
% Be careful: backward models (dirTRF-1) with many electrodes and large time-windows
% can require long computational time   s. So, we suggest reducing the
% dimensionality if you are just playing around with the code (e.g., select
% only few electrodes and/or reduce the TRF window)c
stimIdx = 15; % 15 is 4 features 16 is 3
dim2plot = 1:3;

% Loading Stimulus data
stimFilename = [dataMainFolder,dataStimSubfolder,'fionnDataStim.mat'];
disp(['Loading stimulus data: ','fionnDataStim.mat'])
load(stimFilename,'stims')
% Downsampling stim if necessary
if downFs < stims.fs
    stims = cndDownsample(stims,downFs);
end

% TRF
clear rAll rAllElec modelAl l
figure('Position',[100,100,600,600]);

for sub = 1:nSubs
% Loading preprocessed EEG
    eegPreFilename = [dataMainFolder,dataCNDSubfolder,'pre_',eegFilenames(sub).name];
    disp(['Loading preprocessed EEG data: pre_',eegFilenames(sub).name])
    load(eegPreFilename,'eeg')

    % Selecting feature of interest ('stimIdx' feature)
    stimFeature = stims;
    stimFeature.names = stimFeature.names{stimIdx};

    if (sub == 1)
        stimFeature.data = stimFeature.data(stimIdx,32:55); % envelope or word onset
        
    % elseif (sub == 6)
    %     stimFeature.data = stimFeature.data(stimIdx, [1, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12]);

    else    
        stimFeature.data = stimFeature.data(stimIdx,:); % envelope or word onset
    end

    

    % Shuffle the stimuli
    % 
    % for i = 1:numel(stimFeature.data)
    %     [rows, cols] = size(stimFeature.data{i});
    %     for j = 3:cols
    %         shuffledIndex = randperm(rows);
    %         column = stimFeature.data{i}(:, j);
    % 
    %         shuffledColumn = column(shuffledIndex);
    % 
    %         stimFeature.data{i}(:, j) = shuffledColumn;
    %     end
    % 
    %     % for 3 
    %     shuffledIndex = randperm(rows);
    %     column = stimFeature.data{i}(:, 3);
    %     shuffledColumn = column(shuffledIndex);
    %     stimFeature.data{i}(:, 3) = shuffledColumn;
    % end

        % 
    for i = 1:numel(stimFeature.data)
        [rows, cols] = size(stimFeature.data{i});

        allWordOnsets = find(stimFeature.data{i}(:, 4) == 1);

        shuffledLastWordOnsets = zeros(1, rows);
        numberLWO = sum(stimFeature.data{i}(:, 3));

        randomIndices = randsample(allWordOnsets, numberLWO);
        
        shuffledLastWordOnsets(randomIndices) = 1;
        stimFeature.data{i}(:, 3) = shuffledLastWordOnsets;

        stimFeature.data{i} = stimFeature.data{i}(:, 1:3);
    end

    


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
    [stats,t] = mTRFcrossval(stimFeature.data,eeg.data,eeg.fs,dirTRF,tmin,tmax,lambdas,'verbose',0);
    
    % Calculating optimal lambda. Display and store results
    [maxR,bestLambda] = max(squeeze(mean(mean(stats.r,1),3)));
    disp(['r = ',num2str(maxR)])
    rAll(sub) = maxR;
    rAllElec(:,sub) = squeeze(mean(stats.r(:,bestLambda,:),1));
    
    
    % Fit TRF model with optimal regularisation parameter
    disp('Running mTRFtrain')
    model = mTRFtrain(stimFeature.data,eeg.data,eeg.fs,dirTRF,tmin,tmax,lambdas(bestLambda),'verbose',0);
    
    % Store TRF model
    modelAll(sub) = model;  
    % 
    %modelAll = model;
    model2plot = modelAll;
    for iiSub = 1:length(model2plot)
        model2plot(iiSub).w = mean(model2plot(iiSub).w(dim2plot,:,:),1);
    end

    % Check to see if normalising in mTRF_plotForwardTRF function
    if dirTRF == 1
        mTRF_plotForwardTRF(eeg,model2plot,rAllElec);
    elseif dirTRF == -1
        mTRF_plotBackwardTRF(eeg,model2plot,rAllElec);
    end
    
    disp(['Mean r = ',num2str(mean(rAll))])
    
    drawnow;
end

%% Save modelAll

folderSave = "./finalModels";
save(fullfile(folderSave, 'correctedShuffle3.mat'), 'modelAll');

save(fullfile(folderSave, 'correctedShuffle3_rAllElec.mat'), 'rAllElec');

