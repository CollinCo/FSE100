% Done being written

function turnRobot(gyro, brick, clutch, angle_input)
    disp('turn robot called');
    angle_input = round(angle_input);
    if(angle_input == 0)
        return
    end
    % gyro   - gyro object
    % brick  - brick cpu object
    % clutch - clutch sensor object
    % clütch.set(-1);    % the clutch is set in reverse mode
                        % wheels will turn in opposite directions.
    % clütch.set(1);     % the clutch is set in forward mode
                        % wheels will turn in the same direction.
    % angle  - degrees to turn
    % speed  - motor speed
    %           slower for passenger pickup?
    %final_angle = g_angle + angle_input; % initial angle (func + 90° turn(PASSED IN VAR REPLACE 90))
    clutch.set(-1); % sets clutch to turn

    g_angle = gyro.getAngle; % sets first angle
    final_angle = g_angle + angle_input; % sets target angle
    steps = (final_angle - g_angle) * 12;

    brick.MoveMotorAngleRel('A', 50, steps, 'Brake');
    brick.WaitForMotor('A');
    pause(1);
    g_angle = gyro.getAngle;
    disp(final_angle);
    disp(g_angle);
    % Turns robot to desired angle
    while(final_angle ~= g_angle) 
        disp(final_angle - g_angle);
        steps = (final_angle - g_angle) * 12;
        brick.MoveMotorAngleRel('A', 10, steps, 'Brake');
        %pause(4);
        brick.WaitForMotor('A');
        pause(1);
        g_angle = gyro.getAngle;
    end
end