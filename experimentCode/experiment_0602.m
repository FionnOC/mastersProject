% Script constants
STIM_START_CODE = 1;
TRIGGER_PORT = hex2dec('3FB8'); % Booth 3

% Create and open a text file for saving trial numbers
trialLogFileName = 'trial_numbers.txt';
trialLogFile = fopen(trialLogFileName, 'wt');

% Create and open a text file for saving participant answers
participantLogFileName = 'participant_answers.txt';
participantLogFile = fopen(participantLogFileName, 'wt');

% Create and open a text file for saving participant arduino responses
arduinoLogFileName = 'participant_arduino.txt';
arduinoLogFile = fopen(arduinoLogFileName, 'wt');

% Create cell array for the responses to the arduino
responsesArduino = {};


% Define the folder paths for your videos and audios
videoFolder = 'Video';
audioFolder = 'Audio';

% List all video files in the folder
videoFiles = dir(fullfile(videoFolder, '*.mp4'));

% List all audio files in the folder
audioFiles = dir(fullfile(audioFolder, '*.wav'));


% Check if the number of video and audio files match
if numel(videoFiles) ~= numel(audioFiles)
    error('The number of video and audio files does not match.');
end

% Set up trigger port
ioObj = io64();
status = io64(ioObj);
port = hex2dec('3FB8');
WaitSecs(0.05);
io64(ioObj,port,0);

portArduino = 'COM7';
timerObj = timer;
timerObj.Period = 1/16;
timerObj.ExecutionMode = 'fixedDelay';

timerObj.UserData = struct('Data', zeros(2, 10000), 'Count', 1);
timerObj.TimerFcn = @timerCallback;




%%

% Set up Psychtoolbox
PsychDefaultSetup(2);

Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'VisualDebugLevel', 0);
KbName('UnifyKeyNames');

% Open a window and retrieve the window pointer
screenNumber = max(Screen('Screens'));

[screenWidth, screenHeight] = Screen('WindowSize', screenNumber);
windowRect = [0 0 screenWidth screenHeight];

[window, ~] = PsychImaging('OpenWindow', screenNumber, [0 0 0], windowRect);
% Get the center coordinates of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Calculate the text size based on the screen size
textSize = min(screenWidth, screenHeight) * 0.04;  % Adjust the multiplier as needed

% Set the text size
Screen('TextSize', window, round(textSize));

Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
HideCursor();

% Get the screen refresh
ifi = Screen('GetFlipInterval', window); % ifi: duration frame in seconds
fsVideo = 1/ifi; % hz: frames per second

% Get audio device
InitializePsychSound;
audioDevice = PsychPortAudio('Open', [], [], 0, [], 1); % gives speakers laptop

% Set the desired volume level
volumeLevel = 0.6; % Adjust the volume level as needed (0.0 to 1.0)
PsychPortAudio('Volume', audioDevice, volumeLevel);

% Set up the keyboard input
KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');
continueKey = KbName('Space');

buffer_time = 1; % 1 sec delay

v_lag = zeros(numel(videoFiles),1);


% Experimental parameters
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
KbName('UnifyKeyNames')
escKey = KbName('Escape');
s = ' '; % Draw space


responsesEnjoyment = zeros(1,numel(videoFiles)); 
responsesDifficulty = zeros(1,numel(videoFiles));




% Display the start frame
DrawFormattedText(window, 'Press the SPACE key to start with the first fragment', 'center', yCenter, white);
Screen('Flip', window);
while true
    [keyIsDown, ~, keyCode] = KbCheck;
    if keyIsDown && keyCode(continueKey)
        break;
    elseif keyIsDown && keyCode(escapeKey)
        sca;
        PsychPortAudio('Close', audioDevice);
        return;
    end
end

% Clear the screen
Screen('FillRect', window, [0 0 0]);
Screen('Flip', window);


% Loop through each video and audio file
for iTr = 1:numel(videoFiles)

    % Append trial number in trial log file
    fprintf(trialLogFile, 'Trial %d:\n', iTr);

    % Open Video
    video = VideoReader(fullfile(videoFolder, videoFiles(iTr).name));

    % Calculate frame duration and video frame rate
    frameDuration = 1 / video.FrameRate;

    % Open Audio
    audio = audioread(fullfile(audioFolder, audioFiles(iTr).name));

    % Buffer Audio44 
    PsychPortAudio('FillBuffer', audioDevice, audio');

    % Take control over processor
    Priority(2);

    % Schedule sound playback for future time
    goSecsAudio = GetSecs + buffer_time; % when audio starts

    % Send EEG trigger (uncomment when conducting experiment)
    io64(ioObj, port,1);
    
    handle = IOPort('OpenSerialPort', 'COM7', 'BaudRate=9600');

    % ie flush here or after acc?
    [~, trigger1Start, ~] = IOPort('Read', handle, 1, 1);
    IOPort('Close', handle);
    
    % Schedule sound playback for future time
    PsychPortAudio('Start', audioDevice, 1, goSecsAudio);
    goSecsVideo = goSecsAudio - (1/fsVideo)/2; % when video starts

    % Play the video and audio synchronously
    startTime = Screen('Flip', window);
    vbl = startTime;

    first_frame = 1; % true
    previous_frame = 0; % index of previous frame
    current_frame = 0;
    
    while hasFrame(video)

        % Read the frame for the current time
        if first_frame
            current_frame = 1; % index of current frame
            io64(ioObj, port,2);
            handle = IOPort('OpenSerialPort', 'COM7', 'BaudRate=9600');

            [~, startDateTime, ~] = IOPort('Read', handle, 1, 1);
            IOPort('Close', handle);
            start(timerObj);

        else
            current_frame = ceil(((GetSecs-timeVideoStart))*video.FrameRate);
        end

        if current_frame > previous_frame
            % Get rid of the previous texture
            if ~first_frame
                Screen('Close', frameTexture);
            end
            frame = readFrame(video);
            frameTexture = Screen('MakeTexture', window, frame);

            previous_frame = current_frame;
        end

        if current_frame
            Screen('DrawTexture', window, frameTexture, [], windowRect);
        end

        % Wait for sound playback to flip the first frame
        if first_frame
            WaitSecs('UntilTime', goSecsVideo);
        end
        t = Screen('Flip', window);

        % Estimate audio-video delay (max +-10ms)
        if first_frame
            timeVideoStart = t;
            v_lag(iTr) = timeVideoStart-goSecsAudio;
            first_frame = 0;
        end

        pause(0.001); % useless if flip screen is blocking
    end
    io64(ioObj, port,0);
    % Stop arduino input
    stop(timerObj);

    % Release processor
    Priority(0);

    % Stop audio playback
    PsychPortAudio('Stop', audioDevice, 1);
   

     % First question on enjoyment
    enjoymentQuestion = 'How much did you enjoy the jokes on a scale from 1 (not funnny) to 5 (very funny)?';
    DrawFormattedText(window, enjoymentQuestion, 'center', yCenter-200, white);
    DrawFormattedText(window, ['>', s, '1'], 'center', yCenter-100, white);
    DrawFormattedText(window, ['>', s, '2'], 'center', yCenter, white);
    DrawFormattedText(window, ['>', s, '3'], 'center', yCenter+100, white);
    DrawFormattedText(window, ['>', s, '4'], 'center', yCenter+200, white);
    DrawFormattedText(window, ['>', s, '5'], 'center', yCenter+300, white);

    % Flip the screen to display the text
    Screen('Flip', window);

    WaitSecs(0.05)


    
    % Wait for subject's input
    responseEnjoyment = [];
    enjoyment = 0;
    validInput = false;
    while ~validInput
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown
            keyName = KbName(keyCode);
            enjoyment = str2double(keyName(1));
            if ~isnan(enjoyment) && ismember(enjoyment, 1:5)
                validInput = true;
            end
        end
        WaitSecs(0.01);
    end


    % Save difficulty responses for each trial
    responsesEnjoyment(1,iTr) = enjoyment;
    
    WaitSecs(0.1)

    % Second question on comprehension
    difficultyQuestion = 'How difficult was it to understand the jokes, on a scale from 1 (easy) to 5 (difficult)?';
    DrawFormattedText(window, difficultyQuestion, 'center', yCenter-200, white);
    DrawFormattedText(window, ['>', s, '1'], 'center', yCenter-100, white);
    DrawFormattedText(window, ['>', s, '2'], 'center', yCenter, white);
    DrawFormattedText(window, ['>', s, '3'], 'center', yCenter+100, white);
    DrawFormattedText(window, ['>', s, '4'], 'center', yCenter+200, white);
    DrawFormattedText(window, ['>', s, '5'], 'center', yCenter+300, white);

    % Flip the screen to display the text
    Screen('Flip', window);

    WaitSecs(0.1)



    % Wait for subject's input
    responseDifficulty = [];
    difficulty = 0;
    validInput = false;
    while ~validInput
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown
            keyName = KbName(keyCode);
            difficulty = str2double(keyName(1));
            if ~isnan(difficulty) && ismember(difficulty, 1:5)
                validInput = true;
            end
        end
        WaitSecs(0.01);
    end

    % Save difficulty responses for each trial
    responsesDifficulty(1,iTr) = difficulty;

    [numRows, numCols] = size(timerObj.UserData.Data);

    % Write the enjoyment and difficulty responses to the participant log file
    fprintf(participantLogFile, 'Trial %d:\n', iTr);
    fprintf(participantLogFile, 'Enjoyment: %d\n', enjoyment);
    fprintf(participantLogFile, 'Difficulty: %d\n', difficulty);
    fprintf(participantLogFile, 'Start Time: %f\n', startDateTime);
    fprintf(participantLogFile, 'Start Time at trigger: %f\n', trigger1Start);

    
    for col = 1:numCols
        fprintf(participantLogFile, '%f, %f\n', timerObj.UserData.Data(1, col), timerObj.UserData.Data(2, col));
    end

    WaitSecs(0.1)



    if(iTr < numel(videoFiles))
        if(iTr == 3 || iTr == 7 || iTr == 10)
             DrawFormattedText(window, 'Please take a 2 minute break. \n\nAfter the break, press the SPACE key to continue to the next fragment.', 'center', 'center', [255 255 255]);
            Screen('Flip', window);
            while true
                [keyIsDown, ~, keyCode] = KbCheck;
                if keyIsDown && keyCode(continueKey)
                    break;
                elseif keyIsDown && keyCode(escapeKey)
                    sca;
                    PsychPortAudio('Close', audioDevice);
                    return;
                end
            end


        else    
        % Prompt the participant to press the continue button
            DrawFormattedText(window, 'Press the SPACE key to continue to the next fragment.', 'center', 'center', [255 255 255]);
            Screen('Flip', window);
            while true
                [keyIsDown, ~, keyCode] = KbCheck;
                if keyIsDown && keyCode(continueKey)
                    break;
                elseif keyIsDown && keyCode(escapeKey)
                    sca;
                    PsychPortAudio('Close', audioDevice);
                    return;
                end
            end
        end
    end

    if(iTr == numel(videoFiles))
        % Display the end frame
        DrawFormattedText(window, 'The experiment has ended. Press the SPACE key to exit.', 'center', 'center', [255 255 255]);
        Screen('Flip', window);
        while true
            [keyIsDown, ~, keyCode] = KbCheck;
            if keyIsDown && keyCode(continueKey)
                break;
            elseif keyIsDown && keyCode(escapeKey)
                sca;
                PsychPortAudio('Close', audioDevice);
                return;
            end
        end
    end

    % reset Arduino User Data
    timerObj.UserData = struct("Data", zeros(2, 10000), "Count", 1);

    % Clear the screen
    Screen('FillRect', window, [0 0 0]);
    Screen('Flip', window);
end
%% 
% Close the log files
fclose(trialLogFile);
fclose(participantLogFile);
fclose(arduinoLogFile);

% Clean up and close the window
sca;
PsychPortAudio('Close', audioDevice);

