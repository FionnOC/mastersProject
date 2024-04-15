% Define the path to vid
inputVideo = 'Laughter_Fionn/Stimuli/Video/E1_3.mp4'; 

% Array containing the timestamps to cut the video at
cutTimes = [(short(66)+1.5) - 800, (short(69)+4.25) - 800, (short(74) + 2)-800, (short(79) + 2.4)-800];

videoReader = VideoReader(inputVideo);

totalFrames = videoReader.NumFrames;

frameRate = videoReader.FrameRate;

outputVideoPath = 'Laughter_Fionn/finalCutVideos/E1_3';
if ~exist(outputVideoPath, 'dir')
    mkdir(outputVideoPath);
end

startFrame = 1;

% Iterate through each cut time 
for i = 1:length(cutTimes)
    cutFrame = round(cutTimes(i) * frameRate);
    endFrame = min(totalFrames, cutFrame);
    
    frames = read(videoReader, [startFrame, endFrame]);    
    outputVideoName = sprintf('segment_%03d.mp4', i);
    outputVideo = VideoWriter(fullfile(outputVideoPath, outputVideoName), 'MPEG-4');
    open(outputVideo);
    
    writeVideo(outputVideo, frames);
    
    close(outputVideo);
    startFrame = cutFrame + 1;
end

if startFrame <= totalFrames
    frames = read(videoReader, [startFrame, totalFrames]);
    outputVideoName = sprintf('segment_%03d.mp4', length(cutTimes) + 1);
    outputVideo = VideoWriter(fullfile(outputVideoPath, outputVideoName), 'MPEG-4');
    open(outputVideo);
    writeVideo(outputVideo, frames);
    close(outputVideo);
end

delete(videoReader);
