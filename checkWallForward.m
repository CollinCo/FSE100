function [wall] = checkWallForward(gyro,brick,clutch)
%CHECKWALLFORWARD Turns robot and checks for a wall in front
%   Wall = 1, No wall = 0
    turnDegrees(gyro, brick, clutch, -90)
    wall = checkWallRight(brick);
    turnDegrees(gyro, brick, clutch, 90)
end