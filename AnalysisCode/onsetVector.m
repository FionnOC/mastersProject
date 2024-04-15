% Load the array of word onset times

test = zeros(9782, 1);

onsetTimes = result{1, 1}(1).start{1};
labels = result{1, 1}(1).labels{1, 1};

onsetTimes = onsetTimes .* 128;

onsetTimes = onsetTimes + 1;

onsetTimes = round(onsetTimes);

times = [];
count = 1;
for iTr = 1:length(labels)
    % disp(labels(iTr));
    if (~isempty(labels{iTr}) )
        disp(labels(iTr));
        times(count) = onsetTimes(iTr);
        count = count + 1; 
    end
end

times = times';

for iTr = times
    test(iTr) = 1;
end

%%  now generalise

stims = load('/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/datasets/Laughter_Fionn/dataStim/dataStimSplit_fix.mat', 'stims');
stims = stims.stims;


textGrids = load('/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/datasets/Laughter_Fionn/textGridMat/allTextGrids.mat', 'allResult');
textGrids = textGrids.allResult;

lengthsArray = stims.data(1, :);

saveAll = cell(55, 1);

for trial = 1:length(lengthsArray)
    % disp(length(lengthsArray{trial}));
    lengthOfZeros = length(lengthsArray{trial});

    zerosArray = zeros(lengthOfZeros, 1);

    onsetTimes = textGrids(trial).start{1};
    labels = textGrids(trial).labels{1};

    % is this necessary 
    % onsetTimes = onsetTimes + 1;
    
    onsetTimes = onsetTimes .* 128;
    onsetTimes = onsetTimes + 1;
    
    onsetTimes = round(onsetTimes);

    times = [];
    count = 1;
    for iTr = 1:length(labels)
        if (~isempty(labels{iTr}) )
            disp(labels(iTr));
            times(count) = onsetTimes(iTr);
            count = count + 1;
        end
    end
    
    times = times';
    
    for iTr = times
        zerosArray(iTr) = 1;
    end
    
    saveAll{trial} = zerosArray;
end


%%

wordOnsetFeature = saveAll;

wordOnsetFeature = wordOnsetFeature';
folderSave = "./dataStim";
save(fullfile(folderSave, 'wordOnsetFeature.mat'), 'wordOnsetFeature');

stims.data(11, :) = wordOnsetFeature;
stims.names{11} = 'wordOnsets';
save(fullfile(folderSave, 'fionnDataStim.mat'), 'stims');

%%

stims = load('/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/datasets/Laughter_Fionn/dataStim/fionnDataStim.mat', 'stims');
stims = stims.stims;


lengthsArray = stims.data(1, :);

for trial = 1:length(lengthsArray)
    extractFeature = stims.data{10, trial};

    extractOnsets = stims.data{11, trial};

    extractFeature(:, 5) = extractOnsets;

    stims.data{12, trial} = extractFeature;

end

stims.names{12} = 'fionnCombined';
save(fullfile(folderSave, 'fionnDataStim.mat'), 'stims');


%%
for trial = 1:length(lengthsArray)
    extractFeature = stims.data{1, trial};

    extractOnsets = stims.data{11, trial};

    extractFeature(:, 2) = extractOnsets;

    stims.data{13, trial} = extractFeature;

end
folderSave = "./dataStim";

stims.names{13} = 'fionnEnvWordOnset';
save(fullfile(folderSave, 'fionnDataStim.mat'), 'stims');






