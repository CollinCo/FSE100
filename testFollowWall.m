
brick.WaitForMotor(0);
gyro = Gyro(brick, 3); % initialize gyro
g_angle = gyro.getAngle; %init gyro reading
steps_per_degree = 1; % steps per degree (subject to change)
clutch = Clutch(brick, 2, -1); % init clutch obj

%clütch.set(-1);    % the clutch is set in reverse mode
                    % wheels will turn in opposite directions.
%clütch.set(1);     % the clutch is set in forward mode
                    % wheels will turn in the same direction.
while(1)
    followWall(brick, gyro, clutch, 4, 50, 100)
end