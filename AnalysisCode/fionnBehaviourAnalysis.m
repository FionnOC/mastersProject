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
behaviorFolderUpscaled = fullfile(dataMainFolder, 'behaviour0104/');

dataFilename = fullfile(behaviorFolder, 'allTrialData0104.mat');
data = load(dataFilename, 'allTrialData');
data = data.allTrialData;

dataFilename = fullfile(behaviorFolderUpscaled, 'upscaledBehaviour.mat');
behaviourData = load(dataFilename, 'behaviourUpscaled');
behaviourData = behaviourData.behaviourUpscaled;

% Trial data participant 1
enjoyment1 = [NaN, NaN, NaN, NaN, NaN, NaN, NaN, 5, 3, 4, 1, 3, 1, 2];
difficulty1 = [NaN, NaN, NaN, NaN, NaN, NaN, NaN, 2, 2, 2, 1, 1, 1, 2];

% Trial data participant 2
enjoyment2 = [5, 5, 5, 2, 3, 3, 3, 4, 4, 3, 3, 4, 3, 4];
difficulty2 = [1, 2, 1, 3, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2];

% Trial data participant 3
enjoyment3 = [3, 2, 4, 5, 4, 4, 3, 2, 3, 3, 4, 3, 3, 4];
difficulty3 = [2, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1];

% Trial data participant 4
enjoyment4 = [3, 3, 4, 3, 4, 2, 2, 3, 3, 3, 3, 4, 4, 4];
difficulty4 = [1, 2, 1, 1, 1, 1, 1, 1, 2, 3, 1, 1, 1, 1];

enjoyment6 = [];
enjoyment7 = [];
enjoyment8 = [];
enjoyment9 = [];
enjoyment10 = [];

difficulty6 = [];
difficulty7 = [];
difficulty8 = [];
difficulty9 = [];
difficulty10 = [];


%% fionn code

for i = 1:length(data)
    enjoyment6 = [enjoyment6, data(1, i).enjoyment];
    enjoyment7 = [enjoyment7, data(2, i).enjoyment];
    enjoyment8 = [enjoyment8, data(3, i).enjoyment];
    enjoyment9 = [enjoyment9, data(4, i).enjoyment];
    enjoyment10 = [enjoyment10, data(5, i).enjoyment];
    
    difficulty6 = [difficulty6, data(1, i).difficulty];
    difficulty7 = [difficulty7, data(2, i).difficulty];
    difficulty8 = [difficulty8, data(3, i).difficulty];
    difficulty9 = [difficulty9, data(4, i).difficulty];
    difficulty10 = [difficulty10, data(5, i).difficulty];
end


% Trial data for all participants
participants = {'Participant 01', 'Participant 02', 'Participant 03', 'Participant 04', ... 
    'Participant 06', 'Participant 07', 'Participant 08', 'Participant 09', 'Participant 10'};
enjoyment_data = [enjoyment1', enjoyment2', enjoyment3', enjoyment4', ... 
    enjoyment6', enjoyment7', enjoyment8', enjoyment9', enjoyment10'];
difficulty_data = [difficulty1', difficulty2', difficulty3', difficulty4', ...
    difficulty6', difficulty7', difficulty8', difficulty9', difficulty10'];

%%

% Calculate mean and standard deviation for each participant
mean_enjoyment = mean(enjoyment_data, 1, 'omitnan');
std_enjoyment = std(enjoyment_data, 0, 1, 'omitnan');

mean_difficulty = mean(difficulty_data, 1, 'omitnan');
std_difficulty = std(difficulty_data, 0, 1, 'omitnan');

% Set custom width and height for the figures
figure_width = 22;  % Adjust figure width as needed
figure_height = 8;  % Adjust figure height as needed

% Set custom font size
font_size = 32;  % Adjust font size as needed

[participants, sortIndex] = sort(participants);  % Sort participants alphabetically

% Create bar plot for mean enjoyment with standard deviation bars
figure('Units', 'inches', 'Position', [0, 0, figure_width, figure_height]);
bar(categorical(participants), mean_enjoyment);
hold on;
errorbar(categorical(participants), mean_enjoyment, std_enjoyment, 'r.', 'LineWidth', 2);
hold off;
title("Mean Enjoyment of Each Participant")
xlabel('Participant', 'FontSize', font_size);
ylabel('Mean Enjoyment', 'FontSize', font_size);
%title('Mean Enjoyment with Standard Deviation');
ylim([0, 5]); % Set y-axis limit
set(gca, 'FontSize', font_size);  % Set font size for tick labels
set(gcf, 'renderer', 'painters'); % Use painters renderer for better quality

% % Export the figure to a PNG file
% filename = 'enjoymentparticipants.png';
% % Save the plot in high resolution (e.g., 300 dots per inch)
% folderPath = 'behaviourFigures';  % Replace with the desired folder path
% full_filename = fullfile(folderPath, filename);
% print(full_filename, '-dpng', '-r300');



% Create bar plot for mean difficulty with standard deviation bars
figure('Units', 'inches', 'Position', [0, 0, figure_width, figure_height]);
bar(categorical(participants), mean_difficulty);
hold on;
errorbar(categorical(participants), mean_difficulty, std_difficulty, 'r.', 'LineWidth', 1.5);
hold off;
title("Mean Difficulty of Each Participant")
xlabel('Participant', 'FontSize', font_size);
ylabel('Mean Difficulty', 'FontSize', font_size);
%title('Mean Difficulty with Standard Deviation');
set(gca, 'FontSize', font_size);  % Set font size for tick labels
set(gcf, 'renderer', 'painters'); % Use painters renderer for better quality

% % Export the figure to a PNG file
% filename = 'difficultyparticipants.png';
% % Save the plot in high resolution (e.g., 300 dots per inch)
% folderPath = 'behaviourFigures';  % Replace with the desired folder path
% full_filename = fullfile(folderPath, filename);
% print(full_filename, '-dpng', '-r300');

%%
% Trial data for all trials
trials = 1:14;

% Calculate mean and standard deviation for each trial
mean_enjoyment = mean(enjoyment_data, 2, 'omitnan');
std_enjoyment = std(enjoyment_data, 0, 2, 'omitnan');

mean_difficulty = mean(difficulty_data, 2, 'omitnan');
std_difficulty = std(difficulty_data, 0, 2, 'omitnan');

% Set custom width and height for the figures
figure_width = 22;  % Adjust figure width as needed
figure_height = 6;  % Adjust figure height as needed

% Set custom font size
font_size = 32;  % Adjust font size as needed

% Create bar plot for mean enjoyment with standard deviation bars
figure('Units', 'inches', 'Position', [0, 0, figure_width, figure_height]);
bar(trials, mean_enjoyment);
hold on;
errorbar(trials, mean_enjoyment, std_enjoyment, 'r.', 'LineWidth', 2);
hold off;
title("Mean Enjoyment of Each Trial")
xlabel('Trial', 'FontSize', font_size);
ylabel('Mean Enjoyment', 'FontSize', font_size);
%title('Mean Enjoyment with Standard Deviation');
ylim([0, 5]); % Set y-axis limit
set(gca, 'FontSize', font_size);  % Set font size for tick labels
set(gcf, 'renderer', 'painters'); % Use painters renderer for better quality
% 
% % Export the figure to a PNG file
% filename = 'enjoymentfragments.png';
% % Save the plot in high resolution (e.g., 300 dots per inch)
% folderPath = 'behaviourFigures';  % Replace with the desired folder path
% full_filename = fullfile(folderPath, filename);
% print(full_filename, '-dpng', '-r300');


% Create bar plot for mean difficulty with standard deviation bars
figure('Units', 'inches', 'Position', [0, 0, figure_width, figure_height]);
bar(trials, mean_difficulty);
hold on;
errorbar(trials, mean_difficulty, std_difficulty, 'r.', 'LineWidth', 1.5);
hold off;
title("Mean Difficulty of Each Trial")
xlabel('Trial', 'FontSize', font_size);
ylabel('Mean Difficulty', 'FontSize', font_size);
%title('Mean Difficulty with Standard Deviation');
set(gca, 'FontSize', font_size);  % Set font size for tick labels
set(gcf, 'renderer', 'painters'); % Use painters renderer for better quality

% % Export the figure to a PNG file
% filename = 'difficultyfragments.png';
% % Save the plot in high resolution (e.g., 300 dots per inch)
% folderPath = 'behaviourFigures';  % Replace with the desired folder path
% full_filename = fullfile(folderPath, filename);
% print(full_filename, '-dpng', '-r300');






