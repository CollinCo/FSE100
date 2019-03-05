%{
    The script should:
        Issue commands to connect to your team?s EV3 Brick.
        Test the connection by instructing the Lego EV3 brick to emit a tone and to display the battery?s voltage level
%}
brick = ConnectBrick('Error404');
for x = 0:10
    brick.playTone(100, x*100, 100);
end