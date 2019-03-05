function [wall] = checkWallRight(brick)
%CHECKWALLRIGHT Checks wall on right
%   brick - brick obj
sensorcheck = getUSReadingInches(brick, 4)
    if(sensorcheck < 24)
        disp('Wall found');
        wall = 1;
        return;
    else
        disp('Wall not found');
        wall = 0;
        return;
    end
end

