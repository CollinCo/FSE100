%=====================================================
% Robot State Machine
%=========================================================================
% This template code is provided for exclusive use in FSE100 at ASU.  
% All other uses including electronic transmission is prohibited without 
% written consent from the course instructor.

% state variable values:
INITIALIZING   = 1;
TURNING_LEFT   = 2;
TURNING_RIGHT  = 3;
CHECKING       = 4;
MOVING_FORWARD = 5;
BACKING_UP     = 6;
PICKING_UP     = 7;
DROPPING_OFF   = 8;

GREEN = 3;
YELLOW = 4;
RED = 5;

state = INITIALIZING;
picked_up = false;
while true
    switch state
        case INITIALIZING
            disp('Initializing...');
            % Initialize the brick, clutch and claw
            brick.WaitForMotor(0);
            gyro = Gyro(brick, 3); % initialize gyro
            g_angle = gyro.getAngle; %init gyro reading
            steps_per_degree = 1; % steps per degree (subject to change)
            clutch = Clutch(brick, 2, -1); % init clutch obj
                %clutch.set(-1);    % the clutch is set in reverse mode
                                    % wheels will turn in opposite directions.
                %clutch.set(1);     % the clutch is set in forward mode
                                    % wheels will turn in the same direction.

            % TODO: write checks for exit conditions and set the state 
            % variable to the correct next state value
            state = CHECKING;
            
        case CHECKING
            disp('Checking walls');
            % check to see if there is a wall to the right or ahead and 
            % take the appropriate action.  
            % NOTE: This function may need to rotate the robot in order to 
            % make checks.  Regardless of any rotations that occur in this 
            % state, the robot orientation is restored before moving on to 
            % the next state.
            % TODO: Write checking code here (if any)
            
            % Check wall right 
                % No Wall found - turns right                     
                            
                % Wall found on right - no wall in front
                    % Move forward

                % Wall on right an in front turns left

                                                                        
                                                                        

            % TODO: write checks for exit conditions and set the state 
            % variable to the correct next state value

            wall_right = checkWallRight(brick);
            wall_forward = checkWallForward(gyro, brick, clutch);       

            if(wall_right && wall_forward)                
                state = TURNING_LEFT;

            elseif (wall_right && ~wall_forward)
                state = MOVING_FORWARD;

            else
                state = TURNING_RIGHT;
            end
                
                
        case MOVING_FORWARD
            disp('Moving forward');
            % Attempt to move forward into the next maze cell.  If there 
            % is a color change in the floor, exit with the appropriate 
            % action.  
            % NOTE: it may be helpful to keep track of how many inches the
            % robot actually traveled in case the robot needs to back up
            % into the center of the cell it moved from.
            
            % TODO: Write moving forward code here (if any)
            
            % TODO: write checks for exit conditions and set the state 
            % variable to the correct next state value
            
            % Dist < 24 - Detect color
            floor_color = brick.ColorColor(2);
            
            % green 3     yellow 4     red 5
            distance_moved = checkWallForward(gyro, brick, clutch);
            if(distance_moved >= 23)
                state = CHECKING;

            elseif (distance_moved < 23 && floor_color == GREEN && picked_up == false)
                state = BACKING_UP;

            elseif (distance_moved < 23 && floor_color == GREEN && picked_up == true)
                state = DROPPING_OFF;

            else
                state = PICKING_UP;

            end
                
        case DROPPING_OFF
            disp('Dropping off the victim');
            % drop off the passenger and exit
            % TODO: Write dropping off code here (if any)
            
            % exit the while loop
            moveStraight(brick, clutch, 12, 100);
            dropoff(brick);

            break;
        case PICKING_UP
            disp('Picking up the victim');
            moveStraight(brick, clutch, -distance_moved, 100);
            % pick up the passenger.  
            % NOTE: When the state exits, it is assumed
            % that the robot has exited the pickup area facing away from
            % the pickup zone and the robot is in the center of the cell.
            % NOTE: On exit, set the variable picked_up to true.
            % TODO: Write the picking up code here (if any)
            
            % TODO: write checks for exit conditions and set the state 
            % variable to the correct next state value

            picked_up = true;
        case BACKING_UP
            disp('Found green prematurely; heading back');
            % Backing up to the center of the previous cell rotating
            % the robot 180 degrees.  
            % NOTE: in order to back up to the exact center of the previous
            % cell, it may be helpful to know the distance that was
            % previously traveled in MOVING_FORWARD.
            % TODO: Write the backing up code here (if any)
            
            % TODO: write checks for exit conditions and set the state 
            % variable to the correct next state value
            state = CHECKING;
        case TURNING_LEFT
            disp('Turning left');
            turnRobot(gyro, brick, clutch, -90)
            % turn left 90 degrees.
            % TODO: Write the turning left code here (if any)
            
            % TODO: write checks for exit conditions and set the state 
            % variable to the correct next state value
            state = CHECKING;
        case TURNING_RIGHT
            disp('Turing right');
            turnRobot(gyro, brick, clutch, 90)
            % turn right 90 degrees
            % TODO: Write the turning right code here (if any)
            
            % TODO: write checks for exit conditions and set the state 
            % variable to the correct next state value
            state = MOVING_FORWARD;
    end
end
