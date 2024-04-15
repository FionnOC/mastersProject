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

modelFolder = "/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/datasets/Laughter_Fionn/finalModels/";
dataCNDSubfolder = 'joinCND/';

load('chanlocs64.mat');

%% univariate Envelope model figures


univariateModelFile = fullfile(modelFolder, 'univariateModel.mat');
univariateModel = load(univariateModelFile, 'modelAll');
univariateModel = univariateModel.modelAll;

allElecFile = fullfile(modelFolder, 'univariate_rAllElec.mat');
univariate_rAllElec = load(allElecFile, 'rAllElec');
univariate_rAllElec = univariate_rAllElec.rAllElec;

shuffledUnivariateModelFile = fullfile(modelFolder, 'shuffledUnivariateModel.mat');
shuffledUnivariateModel = load(shuffledUnivariateModelFile, 'modelAll');
shuffledUnivariateModel = shuffledUnivariateModel.modelAll;

shuffled_allElecFile = fullfile(modelFolder, 'shuffledUnivariate_rAllElec.mat');
shuffledUnivariate_rAllElec = load(shuffled_allElecFile, 'rAllElec');
shuffledUnivariate_rAllElec = shuffledUnivariate_rAllElec.rAllElec;


rAll = mean(univariate_rAllElec,1); % averaging across electrodes
rAllShuffled = mean(shuffledUnivariate_rAllElec, 1);

model2plot = univariateModel;

plotNormFlag = 1;
avgUnivariate = mTRFmodelAvg(model2plot,plotNormFlag);

tmin = univariateModel(1).t(1);
tmax = univariateModel(1).t(end);

figure;
plot(avgUnivariate.t,squeeze(avgUnivariate.w))
title('Envelope TRF - Univariate')
xlabel('Time-latency (ms)')
ylabel('Magnitude (a.u.)')
xlim([tmin+50,tmax-50])
ylim([-2.5,2.5])
grid on;
set(gca, 'FontSize', 17);
% run prepExport.m

% % % Export the figure to a PNG file
% filename = 'univariateTRF.png';
% % Save the plot in high resolution (e.g., 300 dots per inch)
% folderPath = 'finalFiguresSave';  % Replace with the desired folder path
% full_filename = fullfile(folderPath, filename);
% print(full_filename, '-dpng', '-r300');


figure;
avgUnivariateGFP = mTRFplot(avgUnivariate, 'gfp', [], 'all');
title("Envelope GFP - Univariate");
xlabel("Time Latency (ms)");
grid on;
set(gca, 'FontSize', 17);
% run prepExport.m

% % % Export the figure to a PNG file
% filename = 'univariateGFP.png';
% % Save the plot in high resolution (e.g., 300 dots per inch)
% folderPath = 'finalFiguresSave';  % Replace with the desired folder path
% full_filename = fullfile(folderPath, filename);
% print(full_filename, '-dpng', '-r300');


% topography

[peakValues, peakLocations] = findpeaks(avgUnivariateGFP.YData, avgUnivariateGFP.XData);
% additionalLocations = [400];

peakLocations = peakLocations(peakLocations >= 0);

peakTimes = find(ismember(avgUnivariate.t, peakLocations));

% Set custom width and height for the figures
figure_width = 22;  % Adjust figure width as needed
figure_height = 12;  % Adjust figure height as needed

% Set custom font size
font_size = 32;  % Adjust font size as needed

% Create bar plot for mean enjoyment with standard deviation bars
figure('Units', 'inches', 'Position', [0, 0, figure_width, figure_height]);
% figure
count = 1;

for i = peakTimes
    weights = avgUnivariate.w(1, i, :);

    weightsAtTime = squeeze(weights);

    subplot(2, 3, count);
    topoplot(weightsAtTime, chanlocs);
    clim([-2.5 2.5]);
    title([num2str(avgUnivariate.t(i)), ' ms'], 'FontSize', 30);
    
    set(gca, 'FontSize', 40);
    count = count + 1;
end

cb = colorbar;
tickPositions = [-2, -1, 0, 1, 2];
cb.Ticks = tickPositions;
newPosition = [0.92, 0.1, 0.02, 0.8]; % [left, bottom, width, height]
set(cb, 'Position', newPosition);
set(gca, 'FontSize', 30);

% run prepExport.m
% Export the figure to a PNG file
% filename = 'univariateTops.png';
% % Save the plot in high resolution (e.g., 300 dots per inch)
% folderPath = 'finalFiguresSave';  % Replace with the desired folder path
% full_filename = fullfile(folderPath, filename);
% print(full_filename, '-dpng', '-r300');



% box plots
figure;
subplot(2, 2, [1, 2])
boxplot(rAll, 'Positions', 1);
hold on;
boxplot(rAllShuffled, 'Positions', 2);


hold off;

p = signrank(rAll, rAllShuffled)

% q = signrank(rAllEnv, rAllEnvShuffled)


median1 = median(rAll);
median2 = median(rAllShuffled);
line([1 2], [median1+0.01 median1+0.01], 'Color', 'k');
text(1.5, median1 + 0.011, '**', 'FontSize', 20, 'HorizontalAlignment', 'center');

hold off;
xticks([1, 2]);
xticklabels({'rAll', 'rAllShuffled'});
ylim([-0.01 median1+0.015])
ylabel('Prediction corr (r)');
set(gca, 'FontSize', 20);
grid on;

subplot(2, 2, 3)
title('Prediction Corr', 'FontSize', 56)
topoplot(mean(univariate_rAllElec,2),chanlocs,'electrodes','on');
clim([0 0.04])
set(gca, 'FontSize', 20);



subplot(2,2,4)
title('Prediction Corr', 'FontSize', 56)
topoplot(mean(shuffledUnivariate_rAllElec,2),chanlocs,'electrodes','on');
clim([0 0.04])
set(gca, 'FontSize', 20);
% fontsize(16,"points")
colorbar

% % Export the figure to a PNG file
% filename = 'univariateSignificance.png';
% % Save the plot in high resolution (e.g., 300 dots per inch)
% folderPath = 'finalFiguresSave';  % Replace with the desired folder path
% full_filename = fullfile(folderPath, filename);
% print(full_filename, '-dpng', '-r300');


%% multivariate 4 features figures

modelFolder = "/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/datasets/Laughter_Fionn/model28Mar/";

% modelAllFilename = fullfile(modelFolder, 'modelAll_1903.mat');
modelAllFilename = fullfile(modelFolder, 'modelEnvLauLWOWO.mat');

multi4model = load(modelAllFilename, 'modelAll');
multi4model = multi4model.modelAll;

allElecFile = fullfile(modelFolder, 'rAllElecEnvLauLWOWO.mat');
multi4rAllElec = load(allElecFile, 'rAllElec');
multi4rAllElec = multi4rAllElec.rAllElec;

modelFolder = "/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/datasets/Laughter_Fionn/finalModels/";


shufmodelAllFilename = fullfile(modelFolder, 'shuffled4Model.mat');

shuffled4Model = load(shufmodelAllFilename, 'modelAll');
shuffled4Model = shuffled4Model.modelAll;

shufallElecFile = fullfile(modelFolder, 'shuffled4_rAllElec.mat');
shuffled_4rAllElec = load(shufallElecFile, 'rAllElec');
shuffled_4rAllElec = shuffled_4rAllElec.rAllElec;

rAll = mean(multi4rAllElec,1); % averaging across electrodes
rAllShuffled = mean(shuffled_4rAllElec, 1);

% rAlltest = mean(multi4rAllElec,2); % averaging across electrodes
% rAllShuffledtest = mean(shuffled_4rAllElec, 2);

% rVals = [];
% 
% for i = 1:length(multi4rAllElec)
%     pVal = signrank(multi4rAllElec(i, :), shuffled_4rAllElec(i, :));
%     rVals = [rVals, pVal];
% end
% 
% significantElectrodes = rVals(rVals <= 0.05);

significantIndices = [];
rVals = [];
sigVals = [];
for i = 1:length(multi4rAllElec)
    [p, h] = signrank(multi4rAllElec(i, :), shuffled_4rAllElec(i, :));
    rVals = [rVals, p];

    if h == 1
        significantIndices = [significantIndices, i];
        sigVals = [sigVals, p];

    end
end

% 
% cfg = [];
% cfg.layout = chanlocs; % Extract channel locations
% cfg.style = 'blank';  
% cfg.highlight = 'on';
% cfg.highlightcolor = [1 0 0]; % Red
% cfg.highlightsize = 10; 
% significant_channels = find(rVals < 0.05); % Using p < 0.05 example  
% cfg.highlightchannel = significant_channels;
% 
% % You can supply your 'EEG' dataset for layout
% figure;
% topoplot([], chanlocs, 'style', 'blank', 'electrodes', 'labelpoint', 'chaninfo', )


significantElectrodes = {};
oneHotIndices = [];

for idx = 1:length(significantIndices)
    checkIndex = significantIndices(idx);
    electrode = chanlocs(checkIndex).labels;
    significantElectrodes{idx} = electrode;
    
end

for idx = significantIndices
    oneHotIndices(idx) = 1;
end

figure;
topoplot(significantIndices, chanlocs, 'style', 'blank', 'electrodes', 'ptslabels');

rAll_Topo = mean(multi4rAllElec, 2);

custom_colormap = [1, 1, 1; colormap("turbo")];
figure;
% Plot the topoplot with the custom colormap
topoplot(rAll_Topo, chanlocs, 'pmask', oneHotIndices, 'whitebk', 'on', 'electrodes', 'off', 'colormap', custom_colormap);
clim([0 0.035])
colorbar

% box plots
figure;
subplot(2, 2, [1, 2])
boxplot(rAll, 'Positions', 1);
hold on;
boxplot(rAllShuffled, 'Positions', 2);
title("4 Feature Multivariate Model vs Shuffled Word Onsets")
xticks([]);
hold off;

p = signrank(rAll, rAllShuffled)

% median1 = median(rAll);
% median2 = median(rAllShuffled);
% line([1 2], [median1+0.01 median1+0.01], 'Color', 'k');
% text(1.5, median1 + 0.011, '**', 'FontSize', 20, 'HorizontalAlignment', 'center');

% hold off;
% xticks([1, 2]);
% xticklabels({'rAll', 'rAllShuffled'});
% ylim([-0.01 median1+0.015])

ylabel('Prediction corr (r)');
grid on;

subplot(2, 2, 3)
title('Prediction Corr', 'FontSize', 56)
topoplot(mean(multi4rAllElec,2),chanlocs,'electrodes','on');
clim([0 0.04])

subplot(2,2,4)
title('Prediction Corr', 'FontSize', 56)
topoplot(mean(shuffled_4rAllElec,2),chanlocs,'electrodes','on');
clim([0 0.04])
fontsize(16,"points")
colorbar

%% multivariate 3 features figures

modelFolder = "/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/datasets/Laughter_Fionn/model28Mar/";

% modelAllFilename = fullfile(modelFolder, 'modelAll_1903.mat');
modelAllFilename = fullfile(modelFolder, 'modelEnvLauLWO.mat');

multi3model = load(modelAllFilename, 'modelAll');
multi3model = multi3model.modelAll;

allElecFile = fullfile(modelFolder, 'rAllElecEnvLauLWO.mat');
multi3rAllElec = load(allElecFile, 'rAllElec');
multi3rAllElec = multi3rAllElec.rAllElec;

modelFolder = "/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/datasets/Laughter_Fionn/finalModels/";

shufmodelAllFilename = fullfile(modelFolder, 'shuffled3Model.mat');

shuffled3Model = load(shufmodelAllFilename, 'modelAll');
shuffled3Model = shuffled3Model.modelAll;

shufallElecFile = fullfile(modelFolder, 'shuffled3_rAllElec.mat');
shuffled_3rAllElec = load(shufallElecFile, 'rAllElec');
shuffled_3rAllElec = shuffled_3rAllElec.rAllElec;

rAll_3 = mean(multi3rAllElec,1); % averaging across electrodes
rAllShuffled_3 = mean(shuffled_3rAllElec, 1);


significantIndices = [];
rVals = [];
sigVals = [];

for i = 1:length(multi3rAllElec)
    p = signrank(multi3rAllElec(i, :), shuffled_3rAllElec(i, :));
    rVals = [rVals, p];
    
    if p <= 0.05
        significantIndices = [significantIndices, i];
        sigVals = [sigVals, p];
    end
end

significantElectrodes = {};

for idx = 1:length(significantIndices)
    checkIndex = significantIndices(idx);
    electrode = chanlocs(checkIndex).labels;
    significantElectrodes{idx} = electrode;
end


oneHotIndices = [];
for idx = significantIndices
    oneHotIndices(idx) = 1;
end

figure;
topoplot(significantIndices, chanlocs, 'style', 'blank', 'electrodes', 'ptslabels');

rAll_Topo = mean(multi3rAllElec, 2);

custom_colormap = [1, 1, 1; colormap("turbo")];
figure;
% Plot the topoplot with the custom colormap
topoplot(rAll_Topo, chanlocs, 'pmask', oneHotIndices, 'whitebk', 'on', 'electrodes', 'off', 'colormap', custom_colormap);
clim([0 0.035])
colorbar


% box plots
figure;
subplot(2, 2, [1, 2])
boxplot(rAll_3, 'Positions', 1);
hold on;
boxplot(rAllShuffled_3, 'Positions', 2);
title("3 Feature Multivariate Model vs Shuffled Word Onsets")
xticks([]);
hold off;

p = signrank(rAll_3, rAllShuffled_3)






% median1 = median(rAll);
% median2 = median(rAllShuffled);
% line([1 2], [median1+0.01 median1+0.01], 'Color', 'k');
% text(1.5, median1 + 0.011, '**', 'FontSize', 20, 'HorizontalAlignment', 'center');

% hold off;
% xticks([1, 2]);
% xticklabels({'rAll', 'rAllShuffled'});
% ylim([-0.01 median1+0.015])

ylabel('Prediction corr (r)');
grid on;

subplot(2, 2, 3)
title('Prediction Corr', 'FontSize', 56)
topoplot(mean(multi3rAllElec,2),chanlocs,'electrodes','on');
clim([0 0.04])

subplot(2,2,4)
title('Prediction Corr', 'FontSize', 56)
topoplot(mean(shuffled_3rAllElec,2),chanlocs,'electrodes','on');
clim([0 0.04])
fontsize(16,"points")
colorbar



%% corrected shuffling

modelFolder = "/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/datasets/Laughter_Fionn/model28Mar/";

% modelAllFilename = fullfile(modelFolder, 'modelAll_1903.mat');
modelAllFilename = fullfile(modelFolder, 'modelEnvLauLWOWO.mat');

multi4model = load(modelAllFilename, 'modelAll');
multi4model = multi4model.modelAll;

allElecFile = fullfile(modelFolder, 'rAllElecEnvLauLWOWO.mat');
multi4rAllElec = load(allElecFile, 'rAllElec');
multi4rAllElec = multi4rAllElec.rAllElec;

modelFolder = "/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/datasets/Laughter_Fionn/finalModels/";


shufmodelAllFilename = fullfile(modelFolder, 'correctedShuffle4.mat');

shuffled4Model = load(shufmodelAllFilename, 'modelAll');
shuffled4Model = shuffled4Model.modelAll;

shufallElecFile = fullfile(modelFolder, 'correctedShuffle4_rAllElec.mat');
shuffled_4rAllElec = load(shufallElecFile, 'rAllElec');
shuffled_4rAllElec = shuffled_4rAllElec.rAllElec;

rAll = mean(multi4rAllElec,1); % averaging across electrodes
rAllShuffled = mean(shuffled_4rAllElec, 1);


% box plots
figure;
subplot(2, 2, [1, 2])
boxplot(rAll, 'Positions', 1);
hold on;
boxplot(rAllShuffled, 'Positions', 2);
title("4 Feature Multivariate Model vs Shuffled Last Word Onsets")
xticks([]);
hold off;

p = signrank(rAll, rAllShuffled)

% median1 = median(rAll);
% median2 = median(rAllShuffled);
% line([1 2], [median1+0.01 median1+0.01], 'Color', 'k');
% text(1.5, median1 + 0.011, '**', 'FontSize', 20, 'HorizontalAlignment', 'center');

% hold off;
% xticks([1, 2]);
% xticklabels({'rAll', 'rAllShuffled'});
% ylim([-0.01 median1+0.015])

ylabel('Prediction corr (r)');
grid on;

subplot(2, 2, 3)
title('Prediction Corr', 'FontSize', 56)
topoplot(mean(multi4rAllElec,2),chanlocs,'electrodes','on');
clim([0 0.04])

subplot(2,2,4)
title('Prediction Corr', 'FontSize', 56)
topoplot(mean(shuffled_4rAllElec,2),chanlocs,'electrodes','on');
clim([0 0.04])
fontsize(16,"points")
colorbar


% rAlltest = mean(multi4rAllElec,2); % averaging across electrodes
% rAllShuffledtest = mean(shuffled_4rAllElec, 2);

% rVals = [];
% 
% for i = 1:length(multi4rAllElec)
%     pVal = signrank(multi4rAllElec(i, :), shuffled_4rAllElec(i, :));
%     rVals = [rVals, pVal];
% end
% 
% significantElectrodes = rVals(rVals <= 0.05);

significantIndices = [];
rVals = [];
sigVals = [];
for i = 1:length(multi4rAllElec)
    [p, h] = signrank(multi4rAllElec(i, :), shuffled_4rAllElec(i, :));
    rVals = [rVals, p];

    if h == 1
        significantIndices = [significantIndices, i];
        sigVals = [sigVals, p];

    end
end

% 
% cfg = [];
% cfg.layout = chanlocs; % Extract channel locations
% cfg.style = 'blank';  
% cfg.highlight = 'on';
% cfg.highlightcolor = [1 0 0]; % Red
% cfg.highlightsize = 10; 
% significant_channels = find(rVals < 0.05); % Using p < 0.05 example  
% cfg.highlightchannel = significant_channels;
% 
% You can supply your 'EEG' dataset for layout


significantElectrodes = {};
oneHotIndices = zeros(1, 64);

for idx = 1:length(significantIndices)
    checkIndex = significantIndices(idx);
    electrode = chanlocs(checkIndex).labels;
    significantElectrodes{idx} = electrode;

end

for idx = significantIndices
    oneHotIndices(idx) = 1;
end

figure;
topoplot(significantIndices, chanlocs, 'style', 'blank', 'electrodes', 'ptslabels');

rAll_Topo = mean(multi4rAllElec, 2);

custom_colormap = [1, 1, 1; colormap("turbo")];
figure;
% Plot the topoplot with the custom colormap
topoplot(rAll_Topo, chanlocs, 'pmask', oneHotIndices, 'whitebk', 'on', 'electrodes', 'off', 'colormap', custom_colormap);
clim([0 0.035])
colorbar

%% multivariate 3 features figures

modelFolder = "/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/datasets/Laughter_Fionn/model28Mar/";

% modelAllFilename = fullfile(modelFolder, 'modelAll_1903.mat');
modelAllFilename = fullfile(modelFolder, 'modelEnvLauLWO.mat');

multi3model = load(modelAllFilename, 'modelAll');
multi3model = multi3model.modelAll;

allElecFile = fullfile(modelFolder, 'rAllElecEnvLauLWO.mat');
multi3rAllElec = load(allElecFile, 'rAllElec');
multi3rAllElec = multi3rAllElec.rAllElec;

modelFolder = "/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/datasets/Laughter_Fionn/finalModels/";

shufmodelAllFilename = fullfile(modelFolder, 'correctedShuffle3.mat');

shuffled3Model = load(shufmodelAllFilename, 'modelAll');
shuffled3Model = shuffled3Model.modelAll;

shufallElecFile = fullfile(modelFolder, 'correctedShuffle3_rAllElec.mat');
shuffled_3rAllElec = load(shufallElecFile, 'rAllElec');
shuffled_3rAllElec = shuffled_3rAllElec.rAllElec;

rAll_3 = mean(multi3rAllElec,1); % averaging across electrodes
rAllShuffled_3 = mean(shuffled_3rAllElec, 1);


significantIndices = [];
rVals = [];
sigVals = [];

for i = 1:length(multi3rAllElec)
    p = signrank(multi3rAllElec(i, :), shuffled_3rAllElec(i, :));
    rVals = [rVals, p];
    
    if p <= 0.05
        significantIndices = [significantIndices, i];
        sigVals = [sigVals, p];
    end
end

significantElectrodes = {};

for idx = 1:length(significantIndices)
    checkIndex = significantIndices(idx);
    electrode = chanlocs(checkIndex).labels;
    significantElectrodes{idx} = electrode;
end


oneHotIndices = zeros(1, 64);
for idx = significantIndices
    oneHotIndices(idx) = 1;
end

figure;
topoplot(significantIndices, chanlocs, 'style', 'blank', 'electrodes', 'ptslabels');

rAll_Topo = mean(multi3rAllElec, 2);

custom_colormap = [1, 1, 1; colormap("turbo")];
figure;
% Plot the topoplot with the custom colormap
topoplot(rAll_Topo, chanlocs, 'pmask', oneHotIndices, 'whitebk', 'on', 'electrodes', 'off', 'colormap', custom_colormap);
clim([0 0.035])
colorbar


% box plots
figure;
subplot(2, 2, [1, 2])
boxplot(rAll_3, 'Positions', 1);
hold on;
boxplot(rAllShuffled_3, 'Positions', 2);
title("3 Feature Multivariate Model vs Shuffled Word Onsets")
xticks([]);
hold off;

p = signrank(rAll_3, rAllShuffled_3)






% median1 = median(rAll);
% median2 = median(rAllShuffled);
% line([1 2], [median1+0.01 median1+0.01], 'Color', 'k');
% text(1.5, median1 + 0.011, '**', 'FontSize', 20, 'HorizontalAlignment', 'center');

% hold off;
% xticks([1, 2]);
% xticklabels({'rAll', 'rAllShuffled'});
% ylim([-0.01 median1+0.015])

ylabel('Prediction corr (r)');
grid on;

subplot(2, 2, 3)
title('Prediction Corr', 'FontSize', 56)
topoplot(mean(multi3rAllElec,2),chanlocs,'electrodes','on');
clim([0 0.04])

subplot(2,2,4)
title('Prediction Corr', 'FontSize', 56)
topoplot(mean(shuffled_3rAllElec,2),chanlocs,'electrodes','on');
clim([0 0.04])
fontsize(16,"points")
colorbar


%%

topoplot([], chanlocs, 'electrodes', 'ptslabels');

