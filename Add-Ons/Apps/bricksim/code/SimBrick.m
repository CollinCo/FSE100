%==========================================================================
% SimBrick - Brick interface to Lego Minstorms EV3 brick simulator
%==========================================================================
%
% This API was based off of the Arizona State University Lego Mindstorm
% interface for the FSE100 course. Not all functions have been implemented
% - only those most relevant to robotic code development
%
%==========================================================================
% Methods:
%==========================================================================
% Primary API Calls::
% SimBrick           Constructor, establishes communications
% ColorColor         Returns the color value of the specified color sensor
% GetMotorAngle      Returns the position counter of the specified motor(s)
% MotorBusy          Return the state of a specified motor 
% MoveMotor          Move one or more motors with a specified NOS and power
% MoveMotorAngleAbs  Move motor(s) to an absolute position using a profiled
%                    speed step
% MoveMotorAngleRel  Move motor(s) to a specific location relative to the
%                    current position using a profiled speed step
% ResetMotorAngle    Clear the position counter of the specified motor(s)
% StopAllMotors      Stops all the motors
% StopMotor          Stops motor at a layer, NOS and brake
%                    (multiple motors at once are not supported)
% TouchPressed       Returns the state of a specified touch sensor
% UltrasoundDist     Returns the distance reported by the specified
% WaitForMotor       Wait for a specified motor to stop moving. 
%
% Deprecated or low-level API functions:
% motorClrCount      Clear the position counter of the specified motor(s) 
%                    This function is deprecated and should not be used for
%                    new code.
% motorGetCount      Returns the position counter of the specified motor(s)
%                    This function is deprecated and should not be used for
%                    new code.
% motorPower         Sets motor output power at a NOS and speed
% motorStart         Starts motor at a NOS and speed
% motorStepSpeed     Moves motor(s) to set position with NOS, speed, ramp up 
%                    angle, constant angle, ramp down angle and brake
%
% Helper Functions (not intended for user code)
% delete             Destructor, closes connection
% send               Send data to the brick
% receive            Receive data from the brick
% inputReadSI        Reads a connected sensor at a NO, type and mode in SI 
%                    units
% makenos            Convert text name for motors to bitfield code.
%
%==========================================================================
% Example::
%==========================================================================
%    b = SimBrick()
%
%==========================================================================
% Revision History 
%==========================================================================
% Version 1.2 201730   - Replaced string functions (split, strip) with 
%                        older character functions to support Matlab 2016 
% Version 1.1 20171030 - Removed "makenos" from MoveMotor function which
%                        caused MoveMotor not to function.
%                      - Removed double quotes for improved compatibility
%                        with older versions of MATLAB - Doug Sandy
% Version 1.0 20171027 - Beta Release - Doug Sandy
%
%==========================================================================
% Copyright Notice 
%==========================================================================
% COPYRIGHT (C) 2017, 
% ARIZONA STATE UNIVERSITY
% ALL RIGHTS RESERVED
%
classdef SimBrick < handle
    
    properties
        conn;  % handle to the SimBrickIO connection
    end

    methods
        function brick = SimBrick(varargin) 
             % Create a Brick object
             %
             % Notes::
             % The brick simulator function (simBrickServer) must be running 
             % in another Matlab window or this function will fail.
             
             brick.conn = simBrickIO();  % connect to the simulator
        end
        
        function delete(brick)
            % delete(b) closes the connection to the brick and is called
            % automatically when the SimBrick object is cleared from memory
            fprintf('Disconnecting...');
            
            % send disconnect command
            brick.send('SET end');
            brick.conn.close();
            pause(5);
            fprintf('Complete.\n');
        end
        
        function send(brick, cmd)
            % send a command to the brick through the
            % SimBrickIO connection handle.
            %
            % cmd - a character array command to send to the simulator
            %
            % Example::
            %           b.send(cmd)
            
            % send the message through the SimBrickIO write function
            brick.conn.write(cmd);
        end
       
        function rmsg = receive(brick)
            % Receive data from the simulator
            %
            % rmsg = the received data from the simulator 
            %
            % Example::
            %           rmsg = b.receive()
 
            % read the message through the SimBrickIO read function
            rmsg = brick.conn.read();
        end
        
        function reading = inputReadSI(brick,no,mode)
            % Return the value read from the specified input sensor - value
            % will be expressed in SI units
            % 
            % no - is the input port number
            % mode - can be any number.  This is not currently used by the
            %      simulator.
            %
            % Example::
            %            reading = b.inputReadSI(1,1)
            
            cmd = sprintf('GET inputReadSI %i %i',no,mode);
            brick.send(cmd);
            
            % receive the response and convert it to a numeric result
            msg = strsplit(strtrim(brick.receive()));
            reading = str2double(msg(end));
        end
        
        function reading = TouchPressed(brick, SensorPort)
            % Return the current value of the specified touch sensor port
            % 
            % no - is the sensor port number.
            % reading - the current state of the touch sensor. Pressed = 1.
            %      Not pressed = 0;
            %
            % Example::
            %            touch1 = b.TouchPressed(0)
            %            touch2 = b.TouchPressed(1)
            reading = brick.inputReadSI(SensorPort, 0);
        end
                
        function reading = ColorColor(brick, SensorPort)
            % Return the current value of the specified color sensor port
            % 
            % no - is the sensor port number.
            % reading - the current color detected by the color sensor
            %      according to the following table:
            %      0 = none
            %      1 = black
            %      2 = blue
            %      3 = green
            %      4 = yellow
            %      5 = red
            %      6 = white
            %      7 = brown
            %
            % Example::
            %            reading = b.ColorColor(3)
            reading = brick.inputReadSI(SensorPort, 0);
        end
        
        function reading = UltrasonicDist(brick, SensorPort)
            % Return the current value of the specified ultrasonic sensor
            % 
            % no - is the input port number.
            %
            % reading - the distance detected by the ultrasonic sensor.  
            %      (in centimeters)
            %
            % Example::
            %            distcm = b.UltrasonicDist(2)
            reading = brick.inputReadSI(SensorPort, 0);
        end
                
        function StopMotor(brick,nos,~)
            % Stops one or motors specified by nos - the second parameter
            % for the acutual mindstorm brick API is 'brake'. The simulator
            % does not use thsi parameter but user code should still 
            % provide it for portability.
            %
            % Notes::
            % - nos - a character array that specifies which motor port or 
            %         ports this command should be applied to.  'A' is for
            %         the motor connected to port 'A'.  'B' is for the 
            %         motor connected to port 'B', etc. To apply this 
            %         command to more than one motor port, more than one
            %         port may be specified (e.g. 'AB').
            % - ~ (parameter not used) - brake value: 0=Coast,  1=Brake
            %
            % Examples::
            %           b.StopMotor('A',0)
            %           b.StopMotor('AB',0)
            cmd = sprintf('SET motorStop %i %i',makenos(nos),0);
            brick.send(cmd);
        end
                
        function StopAllMotors(brick, ~)
            % Stops all motors. The first parameter for the acutual 
            % mindstorm brick API is 'brake'.  The simulator
            % does not use thsi parameter but user code should still 
            % provide it for portability.
            %
            % - ~ (parameter not used) - brake value: 0=Coast,  1=Brake
            %
            % Examples::
            %           b.StopAllMotors(0)

            brick.StopMotor('ABCD', 0);
        end
        
        function motorPower(brick,nos,power)
            % Sets one or more motor's (specified by nos) output powers to
            % the specified value.  Motors will not acutally run unless
            % they have been started.  
            %
            % Notes::
            % - nos - a character array that specifies which motor port or 
            %         ports this command should be applied to.  'A' is for
            %         the motor connected to port 'A'.  'B' is for the 
            %         motor connected to port 'B', etc. To apply this 
            %         command to more than one motor port, more than one
            %         port may be specified (e.g. 'AB').
            % - power - the value to set the output power to.  This value
            %         should be in the range [+/-0:100].
            %
            % Examples::
            %           b.motorPower('A',100)
            %           b.motorPower('AB',50)
            cmd = sprintf('SET motorPower %i %i',makenos(nos),power);
            brick.send(cmd);
        end
        
        function motorStart(brick,nos)
            % Starts one or motors specified by nos
            %
            % Notes::
            % - nos - a character array that specifies which motor port or 
            %         ports this command should be applied to.  'A' is for
            %         the motor connected to port 'A'.  'B' is for the 
            %         motor connected to port 'B', etc. To apply this 
            %         command to more than one motor port, more than one
            %         port may be specified (e.g. 'AB').
            %
            % Examples::
            %           b.StartMotor('A',0)
            %           b.StartMotor('AB',0)
            cmd = sprintf('SET motorStart %i',makenos(nos));
            brick.send(cmd);
        end
        
        function MoveMotor(brick, nos, power)
            % Starts one or motors to run at a specified power, or changes
            % the power of one or more motors that are already running.
            %
            % Notes::
            % - nos - a character array that specifies which motor port or 
            %         ports this command should be applied to.  'A' is for
            %         the motor connected to port 'A'.  'B' is for the 
            %         motor connected to port 'B', etc. To apply this 
            %         command to more than one motor port, more than one
            %         port may be specified (e.g. 'AB').
            % - power - the value to set the output power to.  This value
            %         should be in the range [+/-0:100].
            %
            % Examples::
            %           b.MoveMotor('A',100)
            %           b.MoveMotor('AB',50)
            brick.motorPower(nos, power);
            brick.motorStart(nos);
        end
        
        function state = MotorBusy(brick,nos)
            % Test a motor or motors to see if they are ready to accept
            % further commands.  Motors that are running a speed or angular
            % profile will return 1 (busy), otherwise motors will return 0.
            % If multiple motors are specified, all motors must be ready to
            % accept commands for this function to return 0 (not busy).
            %
            % Notes::
            % - nos - a character array that specifies which motor port or 
            %         ports this command should be applied to.  'A' is for
            %         the motor connected to port 'A'.  'B' is for the 
            %         motor connected to port 'B', etc. To apply this 
            %         command to more than one motor port, more than one
            %         port may be specified (e.g. 'AB').
            %
            % Examples::
            %           state = b.MotorBusy('A')
            %           state = b.MotorBusy('AB')
            cmd = sprintf('GET motorBusy %i',makenos(nos));
            brick.send(cmd);
            % receive the command
            msg = brick.receive();
            % motor state is the final byte
            msg = strsplit(strtrim(msg));
            state = int8(str2double(msg(end)));
        end
        
        function motorStepSpeed(brick,nos,speed,step1,step2,step3,~)
            % Execute a profiled move function on the specified motor or 
            % motors. During the move, the motors will be busy and unable
            % to accept further commands except for STOP.
            %
            % The profiled move is the shape of a trapazoid.  In the
            % initial phase, the motor speed will exhibit a constant
            % acceleration until it has reached the speed specified.  The
            % number of steps (degrees) the motor takes to execute the
            % acceleration ramp is specified by the 'step1' parameter.
            %
            % The second phasee of the profiled move is a constant-velocity
            % phase.  During this phase, the motor runs at the speed
            % specified for an angular distance specified by 'step2'.
            %
            % In the final phase, the motor speed will exhibit a constant
            % deceleration until it has stopped.  The number of steps 
            % (degrees) the motor takes to execute the deceleration ramp 
            % is specified by the 'step3' parameter.
            %
            % The last parameter for the acutual mindstorm brick API is 
            % 'brake'.  The simulator does not use thsi parameter but user 
            % code should still provide it for portability.
            %
            % Notes::
            % - nos - a character array that specifies which motor port or 
            %         ports this command should be applied to.  'A' is for
            %         the motor connected to port 'A'.  'B' is for the 
            %         motor connected to port 'B', etc. To apply this 
            %         command to more than one motor port, more than one
            %         port may be specified (e.g. 'AB').
            % - speed is the output speed with [+-0..100] range.
            % - step1 is the steps used to ramp up.
            % - step2 is the steps used for constant speed.
            % - step3 is the steps used for ramp down.
            % - ~ (brake) is [0..1] (0=Coast,  1=Brake).
            %
            % Examples::
            %           b.outputStepSpeed('A',50,50,360,50,0)
            %           b.outputStepSpeed('AB',50,50,360,50,0)
            cmd = sprintf('SET motorStepSpeed %i %i %i %i %i %1',makenos(nos),...
                speed, step1, step2, step3, 0);
            brick.send(cmd);
        end
        
        function MoveMotorAngleRel(brick, nos, speed, angle, ~)
            % Execute a profiled move to the specified relative position.
            %
            % The profiled move will accelerate for 1/3 of the distance,
            % run at constant speed for 1/3 of the distance, and decelerate
            % for the final 1/3 of the distance.  The speed parameter 
            % specifies the output power of the motor for the constant 
            % speed portion of the move.
            %
            % The last parameter for the acutual mindstorm brick API is 
            % 'brake'.  The simulator does not use thsi parameter but user 
            % code should still provide it for portability.
            %
            % Notes::
            % - nos - a character array that specifies which motor port or 
            %         ports this command should be applied to.  'A' is for
            %         the motor connected to port 'A'.  'B' is for the 
            %         motor connected to port 'B', etc. To apply this 
            %         command to more than one motor port, more than one
            %         port may be specified (e.g. 'AB').
            % - speed is the output speed with [+/-0..100] range.
            % - angle is the distance to move relative to the current 
            %         position (may be negative)
            % - ~ (brake) is [0..1] (0=Coast,  1=Brake).
            %
            % Examples::
            %           b.MoveMotorAngleRel('A',50,360,0)
            %           b.MoveMotorAngleRel('AB',50,360,0)
            if(angle<0)
               speed = -1*speed;
            end
            angle = abs(angle);
            if angle>0 
                brick.motorStepSpeed(nos, speed, angle/3, angle/3, angle/3, 0);
            end
        end
        
        function MoveMotorAngleAbs(brick, nos, speed, angle, ~)
            % Execute a profiled move to the specified absolute position.
            %
            % The profiled move will accelerate for 1/3 of the distance,
            % run at constant speed for 1/3 of the distance, and decelerate
            % for the final 1/3 of the distance.  The speed parameter 
            % specifies the output power of the motor for the constant 
            % speed portion of the move.
            %
            % The last parameter for the acutual mindstorm brick API is 
            % 'brake'.  The simulator does not use thsi parameter but user 
            % code should still provide it for portability.
            %
            % Notes::
            % - nos - a character array that specifies which motor port or 
            %         ports this command should be applied to.  'A' is for
            %         the motor connected to port 'A'.  'B' is for the 
            %         motor connected to port 'B', etc. To apply this 
            %         command to more than one motor port, more than one
            %         port may be specified (e.g. 'AB').
            % - speed is the output speed with [+/-0..100] range.
            % - angle is the final position for the motor after the move
            % - ~ (brake) is [0..1] (0=Coast,  1=Brake).
            %
            % Examples::
            %           b.MoveMotorAngleAbs('A',50,360,0)
            %           b.MoveMotorAngleAbs('AB',50,360,0)            
            brick.StopMotor(nos, 'Coast'); % Motor locks up if Hard brake.
                
            tacho = brick.motorGetCount(nos);
            
            diff = angle - tacho;
            if (diff~=0) 
                brick.MoveMotorAngleRel(nos, speed, diff, 0);
            end
        end
        
        function ResetMotorAngle(brick, nos)
            % Clear output position counter to 0 for the specified motor(s)
            %
            % Notes::
            % - nos - a character array that specifies which motor port or 
            %         ports this command should be applied to.  'A' is for
            %         the motor connected to port 'A'.  'B' is for the 
            %         motor connected to port 'B', etc. To apply this 
            %         command to more than one motor port, more than one
            %         port may be specified (e.g. 'AB').
            %
            % Examples::
            %            b.ResetMotorAngle('A')
            %            b.ResetMotorAngle('AB')
            brick.motorClrCount(nos);
        end
        
        function motorClrCount(brick,nos)
            % Clear output position counter to 0 for the specified motor(s)
            %
            % Notes::
            % - nos - a character array that specifies which motor port or 
            %         ports this command should be applied to.  'A' is for
            %         the motor connected to port 'A'.  'B' is for the 
            %         motor connected to port 'B', etc. To apply this 
            %         command to more than one motor port, more than one
            %         port may be specified (e.g. 'AB').
            %
            % Examples::
            %            b.motorClrCount('A')
            %            b.motorClrCount('AB')
            cmd = sprintf('SET motorClrCount %i',makenos(nos));
            brick.send(cmd);
        end
        
        function angle = GetMotorAngle(brick, nos)
            % Get the anglar position count for the specified motor.
            % NOTE: unlike other motor functions, this function can only 
            % be used for a single motor.
            %
            % Notes::
            % 
            % - nos - a character array that specifies which motor port or 
            %         ports this command should be applied to.  'A' is for
            %         the motor connected to port 'A'.  'B' is for the 
            %         motor connected to port 'B', etc. 
            % - angle is the returned angular position.
            %
            % Example::
            %           angle = b.GetMotorAngle('A')
            %           angle = b.GetMotorAngle('B')
            
            angle = brick.motorGetCount(nos);
        end
        
        function tacho = motorGetCount(brick,nos)
            % Get the anglar position count for the specified motor.
            % NOTE: unlike other motor functions, this function can only 
            % be used for a single motor.
            %
            % Notes::
            % 
            % - nos - a character array that specifies which motor port or 
            %         ports this command should be applied to.  'A' is for
            %         the motor connected to port 'A'.  'B' is for the 
            %         motor connected to port 'B', etc. 
            % - tacho is the returned angular position.
            %
            % Example::
            %           tacho = b.outputGetCount('A')
            %           tacho = b.outputGetCount('B')
            num = 0;
            switch nos
                case 'A'
                    num = 0;
                case 'B'
                    num = 1;
                case 'C'
                    num = 2;
                case 'D' 
                    num = 3;
            end
            cmd = sprintf('GET motorGetCount %i',num);
            brick.send(cmd);
            % receive the command
            msg = strsplit(strtrim(brick.receive()));
            tacho = str2double(msg(end));
        end
        
        function WaitForMotor(brick, nos)
            % Wait for a specified motor to be stopped and ready for 
            % commands. Care should be taken when using this command
            % because program control will not return unil the motor is
            % ready and stopped.
            % NOTE: unlike other motor functions, this function can only 
            % be used for a single motor.
            %
            % Notes::
            % - nos - a character array that specifies which motor port or 
            %         ports this command should be applied to.  'A' is for
            %         the motor connected to port 'A'.  'B' is for the 
            %         motor connected to port 'B', etc. 
            %
            % Example::
            %           tacho = b.WaitForMotro('A')
            %           tacho = b.WaitForMotor('B')
            
            while(brick.MotorBusy(nos)==1)
                pause(0.1);
            end
            lastangle = brick.GetMotorAngle(nos);
            while(lastangle ~= brick.GetMotorAngle(nos))
                lastangle = brick.GetMotorAngle(nos);
                pause(0.1);
            end
            %pause(0.5);
        end
        
    end
end


function out = makenos(input)
    % Convert a character array description of motor ports to a bitfield 
    % representation.  
    %
    % Notes::
    % - input - a character array that specifies which motor port or 
    %         ports this command should be applied to.  'A' is for
    %         the motor connected to port 'A'.  'B' is for the 
    %         motor connected to port 'B', etc. To apply this 
    %         command to more than one motor port, more than one
    %         port may be specified (e.g. 'AB').
    % - out - a bitfield representation of the motor ports.  
    %         b3..b1
    %         b0 = 1 if motor 'A' was referenced
    %         b1 = 1 if motor 'B' was referenced
    %         b2 = 1 if motor 'C' was referenced
    %         b3 = 1 if motor 'D' was referenced
    out = 0;
    if ismember(input, 'ABCD')
       if ismember('A', input)
           out = bitor(out, 1);
       end
       if ismember('B', input)
           out = bitor(out, 2);
       end
       if ismember('C', input)
           out = bitor(out, 4);
       end
       if ismember('D', input)
           out = bitor(out, 8);
       end
    end
end


