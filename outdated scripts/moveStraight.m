% 1. Start a new instance of the Matlab program (having two total)
% 2. Make sure that the simulator path is included in the Matlab path
% 3. In the Matlab command window, type ?simBrickServer?

% If you would like to reset the position of the vehicle within the simulated maze, you must clear your
% SimBrick object from memory in the Matlab widow in which you are programming (NOT the simulator
%   window). You can do this by typing the following at the Matlab command prompt:
%   clear b

% 1. Set the clutch in the forward direction (Sprocket only).
% 2. Read the starting position (angle) of one of the drive motors.
% 3. Start the drive motor(s) moving for the specified number of steps with the specified speed
% 4. While the motor is busy, keep checking to see if the color sensor returns a value other than white.
%    If a change in color is found, stop the motors and exit the loop.
% 5. Here, the motors are stopped because either the move completed or the floor changed colors.
% If the floor is red:
%   a. Determine the number of motor steps required to complete the move
%   b. Start the drive motor(s) moving for the new number of steps with the specified speed.
%   c. Wait for the motor to complete running.
% 6. Return the actual number of steps the motor has moved.

function steps_moved = moveStraight (brick, clutch, steps, speed)
    clutch.set(1); % sets clutch to forward 
    start_steps = brick.GetMotorAngle('A'); % gets starting steps for motors
    brick.MoveMotorAngleRel('A', speed, steps, 'Brake'); % moves motors amount of steps (passed in)
    while (brick.MotorBusy('A')) % while motors are moving
        floorColor = brick.ColorColor(2); % reads floor color
        if (floorColor ~= 6) % if floor != white
            brick.StopAllMotors(); % breaks Motorbusy while condition
        end
    end

    pause(2); %buffer time required 

    if (floorColor == 5) % red = stop sign
        pause(5); 
        fprintf('red floor found');

                                                     
    end                

    if (floorColor ~= 6) % If the above MoveMotorAngleRel was broken (therefore not finished)
        % brick.GetMotorAngle('A') - start_steps is the number of steps already moved
        % steps - ^^^ is the amount of steps needed
        nextSteps = steps - (brick.GetMotorAngle('A') - start_steps);
        brick.MoveMotorAngleRel('A', speed, nextSteps, 'Brake'); % Finish moving
        while (brick.MotorBusy('A'))
            fprintf('? XD ?'); % Wait for motor to finish
        end
    end

    return brick.GetMotorAngle('A') - start_steps;
end
       
% ( ???)/ Hail Hydra!