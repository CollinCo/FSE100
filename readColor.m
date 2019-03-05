% made this because we have to check for a stop today
% color sensor returns a brightness value for different colors
% set an if where when red is returned it stops for a few seconds
% red = 5
% don't do stop all motors
% do either wait for motor or motor busy as a loop variable to check and wait, eliminate delay

% Tom made this file obsolete
int brightness = brick.ColorColor(2);
return brightness; 
