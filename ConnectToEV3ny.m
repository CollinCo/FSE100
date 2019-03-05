%{
F# 369.994
G# 415.305
D# 311.127
B 493.883
%}

%{
    The script should:
        Issue commands to connect to your team?s EV3 Brick.
        Test the connection by instructing the Lego EV3 brick to emit a tone and to display the battery?s voltage level
%}
%brick = ConnectBrick('Error404');

brick.playTone(100, 369.994, 400);
pause(.4);
brick.playTone(100, 415.305, 400);
pause(.4);
brick.playTone(100, 311.127, 200);
pause(.2);
brick.playTone(100, 311.127, 200);
pause(.2);
pause(.2);
brick.playTone(100, 240, 200); %B - after pause
