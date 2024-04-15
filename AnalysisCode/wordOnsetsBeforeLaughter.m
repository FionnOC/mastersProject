close all
clc
clear

stims = load('/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/datasets/Laughter_Fionn/dataStim/fionnDataStim.mat', 'stims');
stims = stims.stims;

stimFeature.data = stims.data(10,:); 

for i = 1:numel(stimFeature.data)
    stimFeature.data{i}(:, 2) = sum(stimFeature.data{i}(:, 2:4), 2);
    stimFeature.data{i}(:, 3:4) = [];
end


%%
stims.data(14, :) = stimFeature.data;
stims.names{14} = 'fionnEnvLaughter';

folderSave = "./dataStim";
save(fullfile(folderSave, 'fionnDataStim.mat'), 'stims');

%% now extract word onsets before laughter

laughterMoments = stims.data(14, :);

%%
store = cell(55, 1);
for iTr = 1:length(laughterMoments)
    bing = laughterMoments{iTr}(:, 2);
    store{iTr} = bing;
end

%%

finalCell = cell(55, 1);

for trial = 1:length(store)
    wordOnsets = stims.data{11, trial};
    laughterOnsets = store{trial}; 

    laughterIndices = find(laughterOnsets);
    wordIndices = find(wordOnsets);

    word_onsets_before_laughter = [];

    for i = 1:length(laughterIndices)
        currentLaughter = laughterIndices(i);
    
        word_index = find(wordOnsets(1:currentLaughter), 1, 'last');
        word_onsets_before_laughter = [word_onsets_before_laughter, word_index];
        
    end
    
    word_onsets_before_laughter_onehot = zeros(size(wordOnsets));
    word_onsets_before_laughter_onehot(word_onsets_before_laughter) = 1;

    finalCell{trial} = word_onsets_before_laughter_onehot;

end


%%
stims.data(15, :) = lastWordOnsets;
stims.names{15} = 'lastWordOnsets';

%%
folderSave = "./dataStim";
save(fullfile(folderSave, 'fionnDataStim.mat'), 'stims');

%%

lengthsArray = stims.data(1, :);

for trial = 1:length(lengthsArray)
    extractFeature = stims.data{14, trial};

    extractOnsets = stims.data{15, trial};
    extractAllOnsets = stims.data{11, trial};

    extractFeature(:, 3) = extractOnsets;
    extractFeature(:, 4) = extractAllOnsets;

    stims.data{16, trial} = extractFeature;

end
%%
stims.names{16} = 'fionnCombinedE_L_LWO_WO';

%%
folderSave = "./dataStim";
save(fullfile(folderSave, 'fionnDataStim.mat'), 'stims');

%%

lengthsArray = stims.data(1, :);

for trial = 1:length(lengthsArray)
    % extractFeature = stims.data{14, trial};
    % 
    % extractOnsets = stims.data{15, trial};
    % extractAllOnsets = stims.data{11, trial};
    % 
    % extractFeature(:, 3) = extractOnsets;
    % extractFeature(:, 4) = extractAllOnsets;
    % 
    % stims.data{16, trial} = extractFeature;

    % stims.data{15, trial} = stims.data{16, trial};
    % stims.data{16, trial} = stims.data{17, trial};

end
%%
stims.names{15} = 'fionnCombinedEnvLauLWOWO'; 
