close all
clc
clear

stims = load('/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/datasets/Laughter_Fionn/dataStim/fionnDataStim.mat', 'stims');
stims = stims.stims;



%%

lengthsArray = stims.data(1, :);

for trial = 1:length(lengthsArray)
    % take fuionnEnvLaughter
    extractFeature = stims.data{14, trial};
    % extract last word onsets
    extractOnsets = stims.data{12, trial};
     
    extractFeature(:, 3) = extractOnsets;
    % extractFeature(:, 4) = extractAllOnsets;
    % 
    stims.data{16, trial} = extractFeature;

    % stims.data{15, trial} = stims.data{16, trial};
    % stims.data{16, trial} = stims.data{17, trial};

end

stims.names{16} = 'fionnCombinedEnvLauLWO'; 
folderSave = "./dataStim";
save(fullfile(folderSave, 'fionnDataStim.mat'), 'stims');


