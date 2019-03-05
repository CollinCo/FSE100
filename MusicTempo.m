while brick.TouchPressed(1) == 0
    pause(0.75);
end
x = 0
while brick.TouchPressed(1) == 1
    pause(0.1);
    x = x + 1;
end
x = x * 10;
brick.playTone(100, 300, x);
pause(x/1000);
brick.playTone(100, 500, x);
pause(x/1000);
brick.playTone(100, 800, x);
