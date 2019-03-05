%TODO's are all done

% followWall function for interface for lego mindstorm EV3 robots
%
% parameters:
%    brick - handle to a connected EV3 brick object
%    gyro - a handle to the gyro sensor object connected to the brick
%    clutch - a handle to a clutch object associated with the brick
%           (set to 0 if unused).
%    usport - the port to which the ultrasonic sensor is connected on the 
%           robot.
%    inches - the number of inches to move the robot.  Postitive values
%            move the robot forward, negative move in reverse.
%    speed - the motor speed with which to move the robot.
%
%=========================================================================
% Author:   Doug Sandy (douglas.sandy@asu.edu)
% Date:     10/16/2018
% Revision: 1.1
%
% Copyright(C), Arizona State University
% All Rights Reserved
%
% This code is provided for exclusive use in FSE100 at ASU.  All other
% uses including electronic transmission is prohibited without written
% consent from the author.
%

function total_inches_traveled = followWall(brick, gyro, clutch, usport,inches,speed)
    
    % The following lines define the number of motor steps to move the robot
    % one inch.  
    % TODO: Uncomment only one of the following lines
    STEPS_PER_INCH = 312;   % uncomment for Sprocket
    %STEPS_PER_INCH =  -116;   % uncomment for Lock-It
    %STEPS_PER_INCH = -52;    % uncomment for Rocket

    % The following line determines how far the robot moves before checking
    % and fixing its heading. The smaller the value, the straighter the
    % robot will run, but it will take more time to do so.
    % TODO: set this value so that the robot travels straight.  Optimal
    % values should be between 3 and 13 inches.
    INCHES_PER_CHECK = 8;
    
    % Desired distance from the front of the ultrasonic sensor to the wall
    DISTANCE_TO_WALL = 9.0;
    
    % the following lines are constants that should be left alone
    STEPS_PER_CHECK = INCHES_PER_CHECK*STEPS_PER_INCH;
    MAX_POSITION_ERROR = 3;
    ADJUSTMENT_ANGLE = 1/3;
    
    % convert inches into motor steps
    total_steps_to_move = inches * STEPS_PER_INCH;
    total_steps_moved = 0;
    heading_error = 0;
    
    while abs(total_steps_moved-total_steps_to_move)>3
        % get the current distance from the wall
        current_distance = mod(getUSReadingInches(brick,usport),24);
        
        % adjust the heading of the robot based on current distance from
        % the wall and the change in distance from the wall.
        position_error = max(min(current_distance-DISTANCE_TO_WALL,MAX_POSITION_ERROR),-MAX_POSITION_ERROR);
        heading_adjustment = ADJUSTMENT_ANGLE*position_error*sign(inches);
        adjustment_angle = floor(heading_adjustment+heading_error);
        
        % TODO: Replace the following line with a call to your robot turn
        % algorithm
        turnRobot(gyro, brick, clutch, adjustment_angle);
        
        % move the robot straight along the current heading
        if (total_steps_to_move<0)
            steps = max(total_steps_to_move-total_steps_moved,sign(total_steps_to_move)*abs(STEPS_PER_CHECK));
        else 
            steps = min(total_steps_to_move-total_steps_moved,sign(total_steps_to_move)*abs(STEPS_PER_CHECK));
        end
        
        % update the distance that the robot has traveled
        steps_moved = moveStraight(brick,clutch,steps,speed);
        inches_moved = steps_moved / STEPS_PER_INCH;
        total_steps_moved = total_steps_moved + steps_moved;
        
        % calculate the change in heading error for the next iteration
        change_in_distance = mod(getUSReadingInches(brick,usport),24)-current_distance;
        if (inches_moved~=0) 
            heading_error = asind(change_in_distance/double(inches_moved));
        end
        if abs(steps_moved-steps)>3
            break;
        end
    end
    adjustment_angle = floor(heading_error);

    % adjust any final heading error
    % TODO: Replace the following line with a call to your robot turn
    % algorithm
    turnRobot(gyro, brick, clutch, angle_input); % already added the function line from turnDegree
    
    % calculate the total inches traveled
    total_inches_traveled = total_steps_moved/STEPS_PER_INCH;
end
