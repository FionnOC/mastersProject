function timerCallback(src, event)
    port = 'COM7';

    handle = IOPort('OpenSerialPort', port, 'BaudRate=9600');

    [data, when, ~] = IOPort('Read', handle, 10, 5);
    % IOPort('Flush', handle);

    chardata = char(data);
    disp(chardata);
    chardata = string(chardata);
    
    src.UserData.Data(1, src.UserData.Count) = when;
    src.UserData.Data(2, src.UserData.Count) = chardata;
    src.UserData.Count = src.UserData.Count + 1;

    IOPort('Close', handle);
end