%audio_ep2 = load('Laughter/audio_E2_final.mat');

%short2 = audio_ep2.final_onsets;

%%

cutTimes = [(short2(182)+4.5) - 1990];

inputFile = 'Laughter_Fionn/Stimuli/Audio/Audio_E2_7.wav';

% Create output folder for audio segments if it doesn't exist
outputAudioFolder = 'Laughter_Fionn/finalCutAudio/E2_7_new';
if ~exist(outputAudioFolder, 'dir')
    mkdir(outputAudioFolder);
end

[y, Fs] = audioread(inputFile);
cutIndices = round(cutTimes * Fs);
cutIndices = [1, cutIndices, length(y)];

% Iterate through each cut
for i = 1:length(cutIndices)-1
    startIndex = cutIndices(i);
    endIndex = cutIndices(i+1);   
    segment = y(startIndex:endIndex,:);    
    outputFileName = fullfile(outputAudioFolder, sprintf('segment_%d.wav', i));
    
    audiowrite(outputFileName, segment, Fs);
end

