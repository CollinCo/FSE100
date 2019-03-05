%brightness = brick.ColorReflect("1");
global key 
InitKeyboard();

while 1
    pause(0.1);
    switch key
        case 0
            disp(brick.UltrasonicDist(1)); %ColorReflect ColorAmbient ColorColor UltrasonicDist
        
        case 'q'
            break;
            
    end
end
CloseKeyboard();
