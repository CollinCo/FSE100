
brick.WaitForMotor(0);
gyro = Gyro(brick, 3); % initialize gyro
g_angle = gyro.getAngle; %init gyro reading
steps_per_degree = 1; % steps per degree (subject to change)
clutch = Clutch(brick, 2, -1); % init clutch obj

%clütch.set(-1);    % the clutch is set in reverse mode
                    % wheels will turn in opposite directions.
%clütch.set(1);     % the clutch is set in forward mode
                    % wheels will turn in the same direction.

final_angle = g_angle + 90; % initial angle (func + 90° turn(PASSED IN VAR REPLACE 90))
clutch.set(-1);

steps = (final_angle - g_angle) * 12;

brick.MoveMotorAngleRel('A', 50, steps, 'Brake');
pause(6);
g_angle = gyro.getAngle;
disp(final_angle);
disp(g_angle);
while(final_angle ~= g_angle) 
    disp(final_angle - g_angle);
    steps = (final_angle - g_angle) * 12;
    brick.MoveMotorAngleRel('A', 10, steps, 'Brake');
    pause(4);
    g_angle = gyro.getAngle;
end

    