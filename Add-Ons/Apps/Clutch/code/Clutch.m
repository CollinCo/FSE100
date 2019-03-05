% Clutch interface for lego mindstorm robot
%
% Methods::
% clutch             Constructor, intializes the physical device
% delete             Destructor, turns off clutch motor brake
% set                sets the clutch in forward, neutral, or reverse
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

classdef Clutch < handle
    properties (Constant = true)
        % the percent of motor power used when calibrating the clutch
        cal_pwr = 15;
        % the percent of motor power used when running the clutch
        run_pwr = 15;
        % the amount of angle to back off from stop in order to provide
        % some pressure relief to the clutch gears.  The larger the 
        % reief angle is, the farther the clutch gear will be from the 
        % drive gear when in normal operation.  When relief is zero, the 
        % clutch gear is tightly pressed against the drive gears - this 
        % has a tendency to put additional stress on the clutch gear axle.
        relief_angle = 4;
    end
    properties
        % a handle for the mindstorm control brick that the clutch is 
        % connected to
        brick;
        % a single character descriptor of the motor port that the
        % clutch is connected to
        motor;
        % the motor speed that the clutch operates at
        motor_speed;
        % the setpoint for the clutch "straight" position.  This property is
        % initialized by the registration method.
        setpoint_f;
        % the setpoint for the clutch "turn" position.  This property is 
        % initialized by the registration method.
        setpoint_r;
        % the setpoint for the clutch neutral position.  This property is 
        % initialized by the clutch registration method.
        setpoint_n;
        % the polarity of the clutch (1 = run forward to reach the
        % "straight" gear.  -1 = run reverse to reach the "straight" gear 
        % position).
        polarity;
        % the current position of the clutch (1,0,-1)
        % 1 = straight, 0 = neutral, -1 = turn
        current_position;
    end
    
    methods
        function clutch = Clutch(brick, motor, polarity) 
             % create a new clutch object
             % check for case of zero input arguments - this is an error
             if nargin == 0
                fprintf('Error - Clutch object cannot be created without parmeters\n');
                return;
             end
             
             % init the properties
             clutch.brick = brick;
             clutch.motor = motor;
             clutch.polarity = polarity;
             clutch.current_position = 0;
             clutch.setpoint_f = 100000;
             clutch.setpoint_r = 100000;
             clutch.setpoint_n = 100000;
             
             % perform registration of the clutch
             clutch.register();
             
             % set the clutch in the "straight" position
             clutch.set(1);
        end
        
        function register(clutch)
            % unlock brake (if locked)
            clutch.brick.MoveMotorAngleRel(clutch.motor, clutch.cal_pwr, 0, 0)
            clutch.waitForClutch(10);

            % start the clutch motor
            clutch.brick.MoveMotor(clutch.motor,clutch.cal_pwr*clutch.polarity);
            pause(1.5);
            % wait for the clutch to hit the stop
            clutch.waitForClutch(10);
            clutch.brick.motorClrCount(clutch.motor);
            clutch.setpoint_f = 0.0 - clutch.relief_angle*clutch.polarity;
            
            % the clutch is now fully engaged in the forward direction 
            % stop the motor
            clutch.brick.StopMotor(clutch.motor,1);
            clutch.waitForClutch(10);

            % start the clutch motor in the reverse direction
            clutch.brick.MoveMotor(clutch.motor,-1*clutch.polarity*clutch.cal_pwr);

            % wait for the clutch to hit the stop
            clutch.waitForClutch(10);
            lastangle = clutch.brick.GetMotorAngle(clutch.motor);
            clutch.setpoint_r = lastangle + clutch.relief_angle*clutch.polarity;
            clutch.setpoint_n = (clutch.setpoint_f+clutch.setpoint_r)/2;
                                    
            % the clutch is now fully engaged - stop the motor
            %clutch.brick.StopMotor(clutch.motor,1);
            clutch.waitForClutch(10);
        end
        
        function delete(clutch)
            % Clutch.delete Delete the Clutch object
            %
            % delete(c) closes unlocks the clutch motoro brake
            clutch.brick.MoveMotorAngleRel(clutch.motor, clutch.cal_pwr, 0, 0)
            clutch.waitForClutch(10);            
        end
        
        function position = getPosition(clutch)
            % get the clutch position
            % position 1 = forward
            % position -1 = reverse
            % position 0 = neutral
            if clutch.brick.GetMotorAngle(clutch.motor) == clutch.setpoint_f
                position = 1;
                return;
            end
            if clutch.brick.GetMotorAngle(clutch.motor) == clutch.setpoint_r
                position = -1;
                return;
            end
            position = 0;
        end    
      
        function result = waitForClutch(clutch,limit)
            % wait for the clutch to complete it's motion.  If the clutch
            % stops at a setpoint, returns true.  Otherwise, returns false.
            result = false;
            lastangle = clutch.brick.GetMotorAngle(clutch.motor);
            prevangle = lastangle -1;
            lastangle2 = 0;
            prevangle2 = 0;
            
            % loop until motion stops or time runs out
            dt = 0.25;
            for i=1:limit/dt
                pause(dt);
                if ~clutch.brick.MotorBusy(clutch.motor)
                    if (lastangle == prevangle) && (lastangle2==prevangle2)
                        result = true;
                        break;
                    end
                    prevangle = lastangle;
                    prevangle2 = lastangle2;
                    lastangle = clutch.brick.GetMotorAngle(clutch.motor);
                end
            end
        end
            
        function set(clutch, position)
            % position 1 = straight
            % position -1 = turn
            % position 0 = neutral
            while clutch.current_position ~= position
                switch position
                    case 1
                        %clutch.brick.MoveMotorAngleAbs(clutch.motor, clutch.run_pwr, clutch.setpoint_f, 1)
                        clutch.brick.MoveMotor(clutch.motor, clutch.polarity*clutch.run_pwr)
                    case -1
                        %clutch.brick.MoveMotorAngleAbs(clutch.motor, clutch.run_pwr, clutch.setpoint_r, 1)
                        clutch.brick.MoveMotor(clutch.motor, -1*clutch.polarity*clutch.run_pwr)
                    case 0
                        clutch.brick.MoveMotorAngleAbs(clutch.motor, clutch.run_pwr, clutch.setpoint_n, 1)
                end
                if clutch.waitForClutch(5)
                    clutch.current_position = position;
                else
                    % stop the clutch
                    clutch.brick.StopMotor(clutch.motor,1);
                    clutch.waitForClutch(5);

                    % disengage the clutch (move to neutral) and try again
                    clutch.brick.MoveMotorAngleAbs(clutch.motor, clutch.run_pwr, clutch.setpoint_n, 1)
                    clutch.waitForClutch(5);
                end
            end
        end
    end
end

