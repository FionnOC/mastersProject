%% Cleaner plots as better understanding of Models

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

modelFolder = "/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/datasets/Laughter_Fionn/model28Mar/";
dataCNDSubfolder = 'joinCND/';

% modelAllFilename = fullfile(modelFolder, 'modelAll_1903.mat');
modelAllFilename = fullfile(modelFolder, 'modelEnvLauLWOWO_900.mat');

load(modelAllFilename, 'modelAll');

allElecFile = fullfile(modelFolder, 'rAllElecEnvLauLWOWO_900.mat');
load(allElecFile, 'rAllElec');


load chanlocs64.mat

dirTRF = 1;
dim2plot = 1:4;

rAll = mean(rAllElec,1); % averaging across electrodes
% rAllShuffled = mean(rAllElecShuffled, 1);
% 
% rAllEnv = mean(rAllElecEnv, 1);
% rAllEnvShuffled = mean(rAllElecEnvShuffled, 1);

tmin = modelAll(1).t(1);
tmax = modelAll(1).t(end);

plotNormFlag = 1;

% Plot average TRF
avgModel = mTRFmodelAvg(modelAll,plotNormFlag);

model2plot = modelAll;

for iiSub = 1:length(modelAll)
    model2plot(iiSub).w = mean(modelAll(iiSub).w(dim2plot,:,:),1);
end

plotNormFlag = 1;
avgEnvLauLWOWO = mTRFmodelAvg(model2plot,plotNormFlag);

%% just look at the last word onset weights

% in the stimulus -> it is env, laughter, last word onset, all word onsets
% means we want to plot the weights of the third column?

lastWordModel = modelAll;
wordOnsetModel = modelAll;
laughterModel = modelAll;
envModel = modelAll;

for iiSub = 1:length(modelAll)
    lastWordModel(iiSub).w = modelAll(iiSub).w(3,:,:);
    % wordOnsetModel(iiSub).w = modelAll(iiSub).w(4,:,:);
    laughterModel(iiSub).w = modelAll(iiSub).w(2,:,:);
    envModel(iiSub).w = modelAll(iiSub).w(1,:,:);
end

plotNormFlag = 1;
avgLastWord = mTRFmodelAvg(lastWordModel,plotNormFlag);
% avgWordOnset = mTRFmodelAvg(wordOnsetModel,plotNormFlag);
avgLaughter = mTRFmodelAvg(laughterModel,plotNormFlag);
avgEnv = mTRFmodelAvg(envModel,plotNormFlag);

%% LastWord
figure;
% subplot(1, 2, 1)
plot(avgLastWord.t,squeeze(avgLastWord.w))
title('Last Word Onset TRF')
xlabel('Time-latency (ms)')
ylabel('Magnitude (a.u.)')
xlim([tmin+50,tmax-50])
ylim([-2.5,2.5])
grid on;
set(gca, 'FontSize', 25);
% run prepExport.m

% filename = 'lastWord4TRF.png';
% % Save the plot in high resolution (e.g., 300 dots per inch)
% folderPath = 'finalFiguresSave';  % Replace with the desired folder path
% full_filename = fullfile(folderPath, filename);
% print(full_filename, '-dpng', '-r300');

% subplot(1, 2, 2)
figure;
lWGfp = mTRFplot(avgLastWord, 'gfp', [], 'all');
title('Last Word Onset GFP');
set(gca, 'FontSize', 25);
% run prepExport.m
grid on;

% filename = 'lastWord4GFP.png';
% % Save the plot in high resolution (e.g., 300 dots per inch)
% folderPath = 'finalFiguresSave';  % Replace with the desired folder path
% full_filename = fullfile(folderPath, filename);
% print(full_filename, '-dpng', '-r300');


[peakValues, peakLocations] = findpeaks(lWGfp.YData, lWGfp.XData);
% additonalLocations = [398.4375];
additonalLocations = [445.3125, 476.5625];
peakLocations = [peakLocations, additonalLocations];

peakLocations = peakLocations(peakLocations >= 0);

peakTimes = find(ismember(avgLastWord.t, peakLocations));
figure;
count = 1;
for i = peakTimes
    weights = avgLastWord.w(1, i, :);

    weightsAtTime = squeeze(weights);

    subplot(2, 3, count);
    topoplot(weightsAtTime, chanlocs);
    clim([-2 2]);
    title([num2str(avgLastWord.t(i)), ' ms'], 'FontSize', 60);
    count = count + 1;
end

cb = colorbar;
tickPositions = [-2,-1.5, -1, -0.5, 0, 0.5, 1, 1.5, 2];
cb.Ticks = tickPositions;
newPosition = [0.92, 0.1, 0.02, 0.8]; % [left, bottom, width, height]
set(cb, 'Position', newPosition);
set(cb, 'FontSize', 40);
% set(gca, 'FontSize', 40);



% figure;
% index = find(ismember(avgLastWord.t, 250.0000));
% weights = avgLastWord.w(1, index, :);
% weightsAtTime = squeeze(weights);
% topoplot(weightsAtTime, chanlocs);
% clim([-2 2]);
% title([num2str(250), ' ms'], 'FontSize', 30);
% % count = count + 1;
% colorbar;


%% AllWordOnsets
figure;
% subplot(1, 2, 1)
plot(avgWordOnset.t,squeeze(avgWordOnset.w))
title('All Word Onset TRF')
xlabel('Time-latency (ms)')
ylabel('Magnitude (a.u.)')
xlim([tmin+50,tmax-50])
ylim([-2.5,2.5])
grid on;
set(gca, 'FontSize', 25);
% run prepExport.m

% filename = 'allWord4TRF.png';
% % Save the plot in high resolution (e.g., 300 dots per inch)
% folderPath = 'finalFiguresSave';  % Replace with the desired folder path
% full_filename = fullfile(folderPath, filename);
% print(full_filename, '-dpng', '-r300');

% subplot(1, 2, 2)
figure;
allWGfp = mTRFplot(avgWordOnset, 'gfp', [], 'all');
title('All Word Onset GFP')
set(gca, 'FontSize', 25);
% run prepExport.m
grid on;

% filename = 'allWord4GFP.png';
% % Save the plot in high resolution (e.g., 300 dots per inch)
% folderPath = 'finalFiguresSave';  % Replace with the desired folder path
% full_filename = fullfile(folderPath, filename);
% print(full_filename, '-dpng', '-r300');

% parentSubplot = subplot(1, 3, 3);

[peakValues, peakLocations] = findpeaks(allWGfp.YData, allWGfp.XData);
% additionalLocations = [400];
peakLocations = [peakLocations, 398.4375];

peakLocations = peakLocations(peakLocations >= 0);

peakTimes = find(ismember(avgWordOnset.t, peakLocations));
figure;
count = 1;

for i = peakTimes
    weights = avgWordOnset.w(1, i, :);

    weightsAtTime = squeeze(weights);

    subplot(2, 3, count);
    topoplot(weightsAtTime, chanlocs);
    clim([-2 2]);
    title([num2str(avgWordOnset.t(i)), ' ms'], 'FontSize', 60);
    % colorbar;
    count = count + 1;
end
cb = colorbar;
tickPositions = [-2,-1.5, -1, -0.5, 0, 0.5, 1, 1.5, 2];
cb.Ticks = tickPositions;
newPosition = [0.92, 0.1, 0.02, 0.8]; % [left, bottom, width, height]
set(cb, 'Position', newPosition);
set(cb, 'FontSize', 40);
%% LaughterOnsets
figure;
% subplot(1, 2, 1)
plot(avgLaughter.t,squeeze(avgLaughter.w))
title('Laughter Onset TRF')
xlabel('Time-latency (ms)')
ylabel('Magnitude (a.u.)')
xlim([tmin+50,tmax-50])
ylim([-2.5,2.5])
grid on;
set(gca, 'FontSize', 25);
% run prepExport.m

% filename = 'laughter4TRF.png';
% % Save the plot in high resolution (e.g., 300 dots per inch)
% folderPath = 'finalFiguresSave';  % Replace with the desired folder path
% full_filename = fullfile(folderPath, filename);
% print(full_filename, '-dpng', '-r300');

% subplot(1, 2, 2)
figure;
laughterGfp = mTRFplot(avgLaughter, 'gfp', [], 'all');
title('Laughter Onset GFP')
% run prepExport.m
set(gca, 'FontSize', 25);
grid on;

% filename = 'laughter4GFP.png';
% % Save the plot in high resolution (e.g., 300 dots per inch)
% folderPath = 'finalFiguresSave';  % Replace with the desired folder path
% full_filename = fullfile(folderPath, filename);
% print(full_filename, '-dpng', '-r300');

% parentSubplot = subplot(1, 3, 3);

[peakValues, peakLocations] = findpeaks(laughterGfp.YData, laughterGfp.XData);

peakLocations = peakLocations(peakLocations >= 0);

peakTimes = find(ismember(avgLaughter.t, peakLocations));
figure;
count = 1;
for i = peakTimes
    weights = avgLaughter.w(1, i, :);

    weightsAtTime = squeeze(weights);

    subplot(3, 3, count);
    topoplot(weightsAtTime, chanlocs);
    clim([-2 2]);
    title([num2str(avgLaughter.t(i)), ' ms'], 'FontSize', 60);
    count = count + 1;
end

cb = colorbar;
tickPositions = [-2,-1.5, -1, -0.5, 0, 0.5, 1, 1.5, 2];
cb.Ticks = tickPositions;
newPosition = [0.92, 0.1, 0.02, 0.8]; % [left, bottom, width, height]
set(cb, 'Position', newPosition);
set(cb, 'FontSize', 40);

%% Envelope
figure;
% subplot(1, 2, 1)
plot(avgEnv.t,squeeze(avgEnv.w))
title('Envelope TRF')
xlabel('Time-latency (ms)')
ylabel('Magnitude (a.u.)')
xlim([tmin+50,tmax-50])
ylim([-2.5,2.5])
grid on;
set(gca, 'FontSize', 25);
% run prepExport.m

% filename = 'env4TRF.png';
% % Save the plot in high resolution (e.g., 300 dots per inch)
% folderPath = 'finalFiguresSave';  % Replace with the desired folder path
% full_filename = fullfile(folderPath, filename);
% print(full_filename, '-dpng', '-r300');

% subplot(1, 2, 2)
figure;
laughterGfp = mTRFplot(avgEnv, 'gfp', [], 'all');
title('Envelope GFP')
% run prepExport.m
set(gca, 'FontSize', 25);
grid on;

% filename = 'env4GFP.png';
% % Save the plot in high resolution (e.g., 300 dots per inch)
% folderPath = 'finalFiguresSave';  % Replace with the desired folder path
% full_filename = fullfile(folderPath, filename);
% print(full_filename, '-dpng', '-r300');

% parentSubplot = subplot(1, 3, 3);

[peakValues, peakLocations] = findpeaks(laughterGfp.YData, laughterGfp.XData);

peakLocations = peakLocations(peakLocations >= 0);
peakLocations = peakLocations(peakLocations <= 600);

peakTimes = find(ismember(avgEnv.t, peakLocations));
figure;
count = 1;
for i = peakTimes
    weights = avgEnv.w(1, i, :);

    weightsAtTime = squeeze(weights);

    subplot(2, 3, count);
    topoplot(weightsAtTime, chanlocs);
    clim([-2 2]);
    title([num2str(avgEnv.t(i)), ' ms'], 'FontSize', 60);
    count = count + 1;
end

cb = colorbar;
tickPositions = [-2,-1.5, -1, -0.5, 0, 0.5, 1, 1.5, 2];
cb.Ticks = tickPositions;
newPosition = [0.92, 0.1, 0.02, 0.8]; % [left, bottom, width, height]
set(cb, 'Position', newPosition);
set(cb, 'FontSize', 30);
% set(gca, 'FontSize', 50);
% run prepExport.m

