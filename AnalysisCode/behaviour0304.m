clear
close all 
clc


subs1_2 = load('/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/datasets/Laughter_Fionn/behaviour0104/subs1_2.mat');
subs3_4_5 = load('/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/datasets/Laughter_Fionn/behaviour0104/subs3_4_5.mat');

subs1_2 = subs1_2.storeArrays;
subs3_4_5 = subs3_4_5.storeArrays;

stims = load('/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/datasets/Laughter_Fionn/dataStim/fionnDataStim.mat');
stims = stims.stims;
behaviour = [subs1_2; subs3_4_5];

behaviourUpscaled = load('/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/datasets/Laughter_Fionn/behaviour0104/upscaledBehaviour.mat');
behaviourUpscaled = behaviourUpscaled.behaviourUpscaled;

%%
% close all
% figure;
% plot(behaviourUpscaled{1, 3}(:, 2), 'DisplayName', 'Subject 6');
% hold on;
% plot(behaviourUpscaled{2, 3}(:, 2), 'DisplayName', 'Subject 7');
% plot(behaviourUpscaled{3, 3}(:, 2), 'DisplayName', 'Subject 8');
% plot(behaviourUpscaled{4, 3}(:, 2), 'DisplayName', 'Subject 9');
% plot(behaviourUpscaled{5, 3}(:, 2), 'DisplayName', 'Subject 10');
% 
% legend('show')
% hold off;
%% save behaviour as a feature?

% do i save it as 
behaviourFeature = [];
for trial = 1:length(behaviourUpscaled)
    behaviourFeature{trial, 1} = behaviourUpscaled{1, trial}(:, 2);
    behaviourFeature{trial, 2} = behaviourUpscaled{2, trial}(:, 2);
    behaviourFeature{trial, 3} = behaviourUpscaled{3, trial}(:, 2);
    behaviourFeature{trial, 4} = behaviourUpscaled{4, trial}(:, 2);
    behaviourFeature{trial, 5} = behaviourUpscaled{5, trial}(:, 2);
end

% Convert cell array to a numerical array
numericalArray = cell2mat(behaviourFeature);

%% agreement? 

thresholds = [20, 50, 70, 90];

[numRows, numCols] = size(numericalArray);

lengthTrial = 1:1:numRows;
lengthTrial = lengthTrial/128;
lengthTrial = lengthTrial/60;

laughter7 = stims.data{14, 7}(:, 2);


for threshold = thresholds

    totalAgreement = zeros(numRows, 1);
    
    for colNum = 1:numCols
        totalAgreement = totalAgreement + (numericalArray(:, colNum) > threshold);
    end
    
    figure;
    plot(lengthTrial, totalAgreement);
    ylabel("Number of agreeing participants")
    title(["Enjoyment Agreement", " Threshold: " + num2str(threshold)]);
    xlabel("Time (mins)");
    xlim([0 lengthTrial(end)]);
    set(gca, 'FontSize', 25);
    ylim([0 5])
    grid on;

    filename = "totalAgreement" + num2str(threshold)+".png";
    % Save the plot in high resolution (e.g., 300 dots per inch)
    folderPath = 'finalFiguresSave/agreementFigures';  % Replace with the desired folder path
    full_filename = fullfile(folderPath, filename);
    print(full_filename, '-dpng', '-r300');
end
%%

trialNum = 7;
laughter7 = stims.data{14, trialNum}(:, 2);
behaviour7 = behaviourFeature(trialNum, :);

% Convert cell array to a numerical array
num7 = cell2mat(behaviour7);

thresholds = [20, 50, 70, 90];

[numRows, numCols] = size(num7);

laughter7 = laughter7 * 5;

lengthTrial = 1:1:numRows;
lengthTrial = lengthTrial/128;

for threshold = thresholds

    totalAgreement = zeros(numRows, 1);
    
    for colNum = 1:numCols
        totalAgreement = totalAgreement + (num7(:, colNum) > threshold);
    end
    
    figure;
    plot(lengthTrial, totalAgreement, 'DisplayName','Agreement');
    hold on;
    plot(lengthTrial, laughter7, 'DisplayName',"Laughter");
    ylabel("Number of agreeing participants")
    title(["Enjoyment Agreement - Segment " + num2str(trialNum), " Threshold: " + num2str(threshold)]);
    set(gca, 'FontSize', 25); 
    xlim([0 lengthTrial(end)]);
    ylim([0 5])
    ylabel("Number of Agreeing Participants");
    xlabel("Time (s)");
    grid on;
    legend('show', 'Location','northwest');

    % filename = "agreementTrial" + num2str(trialNum) + "Threshold" + num2str(threshold) + ".png";
    % % Save the plot in high resolution (e.g., 300 dots per inch)
    % folderPath = 'finalFiguresSave/agreementFigures';  % Replace with the desired folder path
    % full_filename = fullfile(folderPath, filename);
    % print(full_filename, '-dpng', '-r300');
end



%%

lengthOfExp = 1:1:length(numericalArray);
lengthOfExp = lengthOfExp/128;
lengthOfExp = lengthOfExp/60;

figure_width = 15;  
figure_height = 12;  

% Create bar plot for mean enjoyment with standard deviation bars
figure('Units', 'inches', 'Position', [0, 0, figure_width, figure_height]);

% figure;
plot(lengthOfExp, numericalArray(:, 1), 'DisplayName', 'Subject 6');
hold on;
plot(lengthOfExp, numericalArray(:, 2), 'DisplayName', 'Subject 7');
plot(lengthOfExp, numericalArray(:, 3), 'DisplayName', 'Subject 8');
plot(lengthOfExp, numericalArray(:, 4), 'DisplayName', 'Subject 9');
plot(lengthOfExp, numericalArray(:, 5), 'DisplayName', 'Subject 10');
title("All Enjoyment Across Participants");
legend('show')
ylim([0 100]);
xlim([0 lengthOfExp(end)])
ylabel("Enjoyment");
xlabel("Time (minutes)");
set(gca, 'FontSize', 25);
% grid on;

hold off;
% 
% Export the figure to a PNG file
filename = 'allEnjoyment.png';
% Save the plot in high resolution (e.g., 300 dots per inch)
folderPath = 'sendGiovanni';  % Replace with the desired folder path
full_filename = fullfile(folderPath, filename);
print(full_filename, '-dpng', '-r300');

%%

% Compute the standard deviation
standardDeviation = std(numericalArray', 0, 1, 'omitnan');
meanBehaviour = mean(numericalArray');

laughterMoments = {};
for i = 1:length(stims.data)
    column = stims.data{14, i}(:, 2);
    laughterMoments{i} = column;
end

laughterMoments2 = vertcat(laughterMoments{:});
laughterMomentsMean = laughterMoments2 * max(meanBehaviour);
laughterMomentsStd = laughterMoments2 * max(standardDeviation);


figure;
plot(lengthOfExp, meanBehaviour);
hold on;
title('Mean Enjoyment');
% plot(laughterMomentsMean);
ylim([0 100]);
xlim([0 lengthOfExp(end)])
ylabel("Enjoyment");
xlabel("Time (minutes)");
set(gca, 'FontSize', 25);
grid on;

hold off;
% 
% Export the figure to a PNG file
filename = 'meanEnjoymentAll.png';
% Save the plot in high resolution (e.g., 300 dots per inch)
folderPath = 'sendGiovanni';  % Replace with the desired folder path
full_filename = fullfile(folderPath, filename);
print(full_filename, '-dpng', '-r300');
% 

figure;
plot(lengthOfExp, standardDeviation);
hold on;
% plot(laughterMomentsStd);
title("Std Dev of Enjoyment");

xlim([0 lengthOfExp(end)])
ylabel("Enjoyment");
xlabel("Time (minutes)");
set(gca, 'FontSize', 25);
grid on;

hold off;
% 
% % Export the figure to a PNG file
filename = 'StdDevEnjoymentAll.png';
% Save the plot in high resolution (e.g., 300 dots per inch)
folderPath = 'sendGiovanni';  % Replace with the desired folder path
full_filename = fullfile(folderPath, filename);
print(full_filename, '-dpng', '-r300');



%% just do trial 7

laughter7 = stims.data{14, 7}(:, 2);
behaviour7 = behaviourFeature(7, :);

% Convert cell array to a numerical array
num7 = cell2mat(behaviour7);

% Compute the standard deviation
standardDeviation7 = std(num7, 0, 2);
% Compute the mean across rows
mean7 = mean(num7, 2);

laughter7_mean = laughter7 * 100;
laughter7_std = laughter7 * max(standardDeviation7);

lengthOfExp = 1:1:length(mean7);
lengthOfExp = lengthOfExp/128;

% all participant enjoyment
% figure;
% plot(lengthOfExp, num7(:, 1), 'DisplayName', 'Subject 6');
% hold on;
% plot(lengthOfExp, num7(:, 2), 'DisplayName', 'Subject 7');
% plot(lengthOfExp, num7(:, 3), 'DisplayName', 'Subject 8');
% plot(lengthOfExp, num7(:, 4), 'DisplayName', 'Subject 9');
% plot(lengthOfExp, num7(:, 5), 'DisplayName', 'Subject 10');
% title("All Enjoyment - Segment 7");
% legend('show', 'Location','northwest');
% ylim([0 100]);
% xlim([0 lengthOfExp(end)])
% ylabel("Enjoyment");
% xlabel("Time (secs)");
% set(gca, 'FontSize', 25);
% grid on;
% hold off;


figure;
plot(lengthOfExp, mean7, 'DisplayName','Mean');
hold on;
plot(lengthOfExp, laughter7_mean, 'DisplayName', 'Laughter Onsets');
title("Segment 7", "Mean Enjoyment and Laughter");
ylim([0 100]);
xlim([0 lengthOfExp(end)])
ylabel("Enjoyment");
xlabel("Time (s)");
set(gca, 'FontSize', 25);
legend('show')
grid on;

% % Export the figure to a PNG file
filename = 'meanEnjoymentTrial7.png';
% Save the plot in high resolution (e.g., 300 dots per inch)
folderPath = 'sendGiovanni';  % Replace with the desired folder path
full_filename = fullfile(folderPath, filename);
print(full_filename, '-dpng', '-r300');

figure;
plot(lengthOfExp, standardDeviation7, 'DisplayName','Standard Deviation');
hold on;
plot(lengthOfExp, laughter7_std, 'DisplayName','Laughter Onsets');
title("Segment 7", "Std Dev Enjoyment and Laughter");
% ylim([0 100]);
xlim([0 lengthOfExp(end)])
ylabel("Enjoyment");
xlabel("Time (s)");
set(gca, 'FontSize', 25);
legend('show', 'Location','northwest');
grid on;

% % Export the figure to a PNG file, 
filename = 'StdDevEnjoymentTrial7.png';
% Save the plot in high resolution (e.g., 300 dots per inch)
folderPath = 'sendGiovanni';  % Replace with the desired folder path
full_filename = fullfile(folderPath, filename);
print(full_filename, '-dpng', '-r300');
