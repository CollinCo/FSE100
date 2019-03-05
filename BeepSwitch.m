fprintf('Press the button to start the tone');

while brick.TouchPressed(1) == 0
    pause(0.75);
end
brick.playTone(100, 300, 500);