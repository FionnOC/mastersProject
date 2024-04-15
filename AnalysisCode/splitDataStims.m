clear
clc

stimJeroen = load('/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/datasets/Laughter_Fionn/dataStim/dataStim.mat');
stimJeroen = stimJeroen.stims;

folderStimuli = "/Users/fionnoconnor/Documents/MATLAB/TCD/CNSP-resources/CNSP/datasets/Laughter_Fionn/";
folderOriginalAudio = fullfile(folderStimuli, 'Stimuli/Audio/');
folderFionnAudio = fullfile(folderStimuli, 'finalCutAudio/');


downFs = stimJeroen.fs ;

%% Length of Jeroen audio

fileList = dir(fullfile(folderOriginalAudio, '*.wav')); 

fragmentLengths = [];

% Loop through each audio file
for i = 1:numel(fileList)
    filePath = fullfile(folderOriginalAudio, fileList(i).name);
    [audioData, sampleRate] = audioread(filePath);
    
    numSamples = numel(audioData);
    lengthInSeconds = numSamples / sampleRate;
    lengthInSamples = round(lengthInSeconds * downFs);
    
    fragmentLengths = [fragmentLengths, lengthInSamples];

    fprintf('File: %s\n', fileList(i).name);
    fprintf('Length in samples: %d\n', lengthInSamples);
end

jeroenLengths = fragmentLengths;


%% Fionn Lengths

fragmentLengths = [];

subFolders = dir(folderFionnAudio);
subFolders = subFolders([subFolders.isdir]); 
subFolders = subFolders(~ismember({subFolders.name}, {'.', '..'})); 

for i = 1:numel(subFolders)
    subFolderPath = fullfile((folderFionnAudio), subFolders(i).name);
    
    fileList = dir(fullfile(subFolderPath, '*.wav'));

    for j = 1:numel(fileList)
        filePath = fullfile(subFolderPath, fileList(j).name);
        [audioData, sampleRate] = audioread(filePath);
    
        numSamples = numel(audioData);
        lengthInSeconds = numSamples / sampleRate;
        lengthInSamples = round(lengthInSeconds * downFs);
        
        fragmentLengths = [fragmentLengths, lengthInSamples];
    
        fprintf('File: %s\n', fileList(j).name);
        fprintf('Length in samples: %d\n', lengthInSamples);
    end
    
end

fionnLengths = fragmentLengths;

%% Split dataStim

% count = 1;
% 
% for i = 1:numel(subFolders)
% 
%     subFolderPath = fullfile((folderFionnAudio), subFolders(i).name);
% 
%     fileList = dir(fullfile(subFolderPath, '*.wav'));
% 
%     for j = 1:numel(fileList)
% 
% 
%     end 
% 
% end


%% Alternative way to store fionn Lengths

subFolders = dir(folderFionnAudio);
subFolders = subFolders([subFolders.isdir]); 
subFolders = subFolders(~ismember({subFolders.name}, {'.', '..'})); 

fragmentLengths2 = cell(1, numel(subFolders)); 

for i = 1:numel(subFolders)
    subFolderPath = fullfile(folderFionnAudio, subFolders(i).name);
    
    fileList = dir(fullfile(subFolderPath, '*.wav'));
    
    lengths = []; 

    for j = 1:numel(fileList)
        filePath = fullfile(subFolderPath, fileList(j).name);
        [audioData, sampleRate] = audioread(filePath);
    
        numSamples = numel(audioData);
        lengthInSeconds = numSamples / sampleRate;
        lengthInSamples = round(lengthInSeconds * downFs);
        
        lengths = [lengths, lengthInSamples];
    
        fprintf('File: %s\n', fileList(j).name);
        fprintf('Length in samples: %d\n', lengthInSamples);
    end
    
    % Store lengths for current subfolder in cell array
    fragmentLengths2{i} = lengths;
    
end

% Convert cell array to 1x14 double array
fionnSplits = fragmentLengths2;
% fionnLengths3 = cumsum(fionnLengths2{1, 1});
% fionnSplits = fionnLengths3(1:4);


%% testing functions
% 
% test = stimJeroen.data(:, 1);
% 
% for i = 1:numel(test)
%     testResults = splitDoubleByLines(test{i, 1}, fionnSplits);
%     for j = 1:numel(testResults)
%         test{i, j} = testResults{j};
%     end
% end



%%  final


resultCollection = cell(size(stimJeroen.data, 1), numel(subFolders)); % Preallocate cell array

for k = 1:numel(subFolders)
    test = stimJeroen.data(:, k);
    fionnSubSplits = cumsum(fionnSplits{1, k});
    fionnSubSplits = fionnSubSplits(1:(numel(fionnSubSplits) - 1));

    for i = 1:numel(test)
        testResults = splitDouble(test{i}, fionnSubSplits);
        % Assign each element of testResults to the corresponding element of resultCollection
        for j = 1:numel(testResults)
            resultCollection{i, k}{j} = testResults{j};
        end
    end
end





%% save alternatively

reshapedResults = cell(size(resultCollection, 1), sum(cellfun(@numel, resultCollection(1,:))));

for i = 1:size(resultCollection, 1)  % Iterate over rows
    columnIndex = 1;
    for j = 1:size(resultCollection, 2)  % Iterate over columns
        for subCellIndex = 1:numel(resultCollection{i, j})
            reshapedResults{i, columnIndex} = resultCollection{i, j}{subCellIndex};
            columnIndex = columnIndex + 1;
        end
    end
end

%% refine final row?


% for i = 1:55
%     extract = reshapedResults{10, i};
%     extract = extract';
%     reshapedResults{10, i} = extract;
% end


%% save it 

stims = struct('names', [], 'data', [], 'fs', []);

stims.fs = 128;

stims.data = reshapedResults;

stims.names{1} = 'Envelope';
stims.names{2} = 'DerEnvelope';
stims.names{3} = 'Filtered Envelope';
stims.names{4} = 'New Onset Dummy';
stims.names{5} = 'Anticipation Ms';
stims.names{6} = 'Full Anticipation Ms';
stims.names{7} = 'Dummy No Anticipation';
stims.names{8} = 'Dummy Short Anticipation';
stims.names{9} = 'Dummy Long Anticipation';
stims.names{10} = 'Combined Variable';


folderdataStim = "./dataStim/";
save(fullfile(folderdataStim, 'dataStimSplit_fix.mat'), 'stims');


%% splitFuncition

function splitResults = splitDouble(inputDouble, lineNumbers)

    % Loop through each line number and split the double
    splitResults = cell(numel(lineNumbers) + 1, 1); 
    prevIndex = 1;
    for i = 1:numel(lineNumbers)
        % Check if the line number is valid
        if lineNumbers(i) < 1 || lineNumbers(i) > numel(inputDouble)
            error(['Invalid line number: ' num2str(lineNumbers(i))]);
        end
        
        splitResults{i} = inputDouble(prevIndex:lineNumbers(i), :);
        prevIndex = lineNumbers(i);
    end
    
    splitResults{end} = inputDouble(prevIndex:end, :);
end


