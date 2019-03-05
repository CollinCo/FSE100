%==========================================================================
% simVehicle 
%==========================================================================
% This class provides simulated vehicle behavior for the simulator server
%
%==========================================================================
% Revision History 
%==========================================================================
% Version 1.2 201730   - Replaced string functions with older character 
%                        functions to support Matlab 2016.  Added support
%                        for "hidden" clutch motor on motor D.  Added
%                        getMotorPower, getMotorState and 
%                        getClutchDirection functions. 
% Version 1.1 20171030 - Removed double quotes for improved compatibility
%                        with older versions of MATLAB - Doug Sandy
% Version 1.0 20171028 - Beta Release - Doug Sandy
%
%==========================================================================
% Copyright Notice 
%==========================================================================
% COPYRIGHT (C) 2017, 
% ARIZONA STATE UNIVERSITY
% ALL RIGHTS RESERVED
%
classdef SimVehicle <handle
    properties (Constant = true)
        ANIMATE_MOTION = true; 
    end
    properties
        x;          % the x position relative to start
        y;          % the y position relative to start
        d;          % the angular direction of the vehicle
        mot = SimMotorState(); % array of motors connected to vehicle
        map;       % used for simulated sensor readings
        vi;         % the vehicle icon
        hitting_wall;
        config;     % the configuration of the vehicle
        log;        % a text log of all the events that occur during the simulation
        previously_red_floor;
        stopped_time;
        stopping_time;
        warning_number;
    end
    methods
        function v = SimVehicle()
            v.x = 0;
            v.y = 0;
            v.d = 270;
            
            % configure the motors
            v.mot(1) = SimMotorState();
            v.mot(2) = SimMotorState();
            v.mot(3) = SimMotorState();
            v.mot(3).setMinStop(-1000);
            v.mot(3).setMaxStop(1000);
            v.mot(3).max_rpm = 270;
            v.mot(4) = SimMotorState();   % hidden motor D for clutch
            v.mot(4).setMinStop(-1000);
            v.mot(4).setMaxStop(1000);
            
            v.init('vehicle_config.xlsx');
            v.hitting_wall = false;
            v.map = MazeMap();
            v.map.init('mazemaker.xlsx');
            v.x = v.map.cell_size-v.map.cell_size/2;
            v.y = -0.5*v.map.cell_size;
            v.vi = MazeVehicleIcon(v.map.f, v.x, v.y, v.d, v.config);
            v.log = [];
            v.previously_red_floor = false;
            v.stopped_time = 0;
            v.stopping_time = 0;
            v.warning_number = 1;
        end
        
        function init(v, filename)
            % initialize the vehicle configuration from the configuration
            % file specified as a parameter
            [~, ~, data] = xlsread(filename,'Sheet1','B2:B15');
            data(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),data)) = {''};
            %idx = cellfun(@ischar, data);
            %data(idx) = cellfun(@(x) string(x), data(idx), 'UniformOutput', false);        
            
            v.config.width     = data{1};      
            v.config.depth     = data{2};
            v.config.wheelbase = data{3};
            v.config.wheel_circumference = 6.926;
            % all positions are relative to the vehicle's pivot point
            pp_y      = data{4};
            pp_x      = data{5};
            v.config.back = pp_x-v.config.depth;
            v.config.front = v.config.depth + v.config.back;
            v.config.right = pp_y-v.config.width;
            v.config.left = v.config.width + v.config.right;
            
            v.config.color_y   = data{6}-pp_y;
            v.config.color_x   = pp_x-data{7};
            v.config.touch1_y  = data{8}-pp_y;
            v.config.touch1_x  = pp_x-data{9};
            v.config.touch2_y  = data{10}-pp_y;
            v.config.touch2_x  = pp_x-data{11};
            v.config.ussense_y = data{12}-pp_y;
            v.config.ussense_x = pp_x-data{13};
            if strcmp(data{14},'Toward Front')
                v.config.usonic_angle = 0;
            elseif strcmp(data{14},'Toward Back')
                v.config.usonic_angle = 180;
            elseif strcmp(data{14},'Toward Left Side')
                v.config.usonic_angle = 90;
            else
                v.config.usonic_angle = 270;
            end
            v.config.has_clutch = 0;
            v.config.clutch_dir = 0;
            v.config.drive_gear_ratio = 1.0;
        end
        
        function result = getInputResponse(v,port,~)
            %==============================================================
            % getInputResponse()
            %
            % returns the simulated input response from the specified port
            % using the specified mode.  Ports are "hard wired" to the
            % following:
            %   port 0 = bump sensor 1
            %   port 1 = bump sesnor 2
            %   port 2 = color sensor
            %   port 3 = ultrasonic sensor
            %
            result = 0;
            switch port
                case 1 
                    result = v.getBumpState(1);
                case 2
                    result = v.getBumpState(2);
                case 3
                    % NOTE - assumes mode 2
                    result = v.getColor();
                case 4
                    result = v.getUltrasonicDist();
            end
        end
        
        function result = isHittingWall(v)
            %==============================================================
            % getBumpState()
            %
            % returns true if the body of the vehicle is hitting a wall.
            %
            result = false;
            
            x1 = v.config.front; y1 = v.config.right; x2 = v.config.front; y2 = v.config.left;
            [x1,y1] = rotate_point(x1,y1,v.d); [x1,y1] = translate_point(x1,y1,v.x,v.y);
            [x2,y2] = rotate_point(x2,y2,v.d); [x2,y2] = translate_point(x2,y2,v.x,v.y);
            result = result | v.map.doesLineSegmentIntersectWall(x1,y1,x2,y2);

            x1 = v.config.back; y1 = v.config.right; x2 = v.config.back; y2 = v.config.left;
            [x1,y1] = rotate_point(x1,y1,v.d); [x1,y1] = translate_point(x1,y1,v.x,v.y);
            [x2,y2] = rotate_point(x2,y2,v.d); [x2,y2] = translate_point(x2,y2,v.x,v.y);
            result = result | v.map.doesLineSegmentIntersectWall(x1,y1,x2,y2);

            x1 = v.config.front; y1 = v.config.right; x2 = v.config.back; y2 = v.config.right;
            [x1,y1] = rotate_point(x1,y1,v.d); [x1,y1] = translate_point(x1,y1,v.x,v.y);
            [x2,y2] = rotate_point(x2,y2,v.d); [x2,y2] = translate_point(x2,y2,v.x,v.y);
            result = result | v.map.doesLineSegmentIntersectWall(x1,y1,x2,y2);

            x1 = v.config.front; y1 = v.config.left; x2 = v.config.back; y2 = v.config.left;
            [x1,y1] = rotate_point(x1,y1,v.d); [x1,y1] = translate_point(x1,y1,v.x,v.y);
            [x2,y2] = rotate_point(x2,y2,v.d); [x2,y2] = translate_point(x2,y2,v.x,v.y);
            result = result | v.map.doesLineSegmentIntersectWall(x1,y1,x2,y2);

        end
        
        function result = getBumpState(v, sensor_port)
            %==============================================================
            % getBumpState()
            %
            % Simulate reading the bump sensor. sensor_port specifies which 
            % bump sensor to read.  
            %
            % result = 1 if the sensor is pressed, otherwise 0.
            %
            result = 0;
            if sensor_port == 1
              y1 = v.config.touch1_y;
              x1 = v.config.touch1_x;
            else
              y1 = v.config.touch2_y;
              x1 = v.config.touch2_x;
            end
            [x1,y1] = rotate_point(x1,y1,v.d);
            [x1,y1] = translate_point(x1,y1,v.x,v.y);
            [x2,y2] = translate_point(x1,y1,1.0*cos(pi()*(v.d-180)/180),1.0*sin(pi()*(v.d-180)/180));
            if v.map.doesLineSegmentIntersectWall(x1,y1,x2,y2)
                result = 1;
            end
        end
            
        function result = getColor(v) 
            if v.isstop(v.x,v.y,v.d)
                result = 5;  % red color
            elseif v.ispickup(v.x,v.y,v.d)
                result = 4;  % yellow color
            elseif v.isdropoff(v.x,v.y,v.d)
                result = 3;  % green color
            else
                result = 7;  % brown color
            end
        end
        
        function result = isstop(v,xpos,ypos,dir)
            % determine if the vehicle's color sensor is over the red
            % color strip on the floor.  If so, return true, otherwise,
            % return false;
            result = false;

            % first, calculate the location of the center of the color sensor
            [nx,ny] = rotate_point(v.config.color_x, v.config.color_y, dir);
            [nx,ny] = translate_point(nx,ny,xpos,ypos);

            % determine which cell the color sensor is in
            [cx,cy] = v.maplocfrompos(nx,ny);
            if cx<1 || cx > v.map.width || cy<1 || cy> v.map.height
                return
            end

            result = false;
            if v.map.getCellStopType(cx,cy,1) == 4
                % maze has a stop zone on the north side -determine if the
                % color sensor lies within the area
                ylimit = -1*(cy-1)*v.map.cell_size - 0.75;
                if ny>ylimit
                    result = true;
                end
            elseif v.map.getCellStopType(cx,cy,2) == 4
                % maze has a picup zone on the south side - determine if the
                % color sensor lies within the area
                ylimit = -1*cy*v.map.cell_size + 0.75;
                if ny<ylimit
                    result = true;
                end
            elseif v.map.getCellStopType(cx,cy,3) == 4
                % maze has a picup zone on the east side - determine if the
                % color sensor lies within the area
                xlimit = cx*v.map.cell_size - 0.75;
                if nx>xlimit
                    result = true;
                end
            elseif v.map.getCellStopType(cx,cy,4) == 4
                % maze has a picup zone on the west side - determine if the
                % color sensor lies within the area
                xlimit = (cx-1)*v.map.cell_size + 0.75;
                if nx<xlimit
                    result = true;
                end
            end
        end
        
        function result = ispickup(v,xpos,ypos,dir)
            % determine if the vehicle's color sensor is over the yellow
            % color strip on the floor.  If so, return true, otherwise,
            % return false;
            result = false;
            % first, calculate the location of the center of the color sensor
            [nx,ny] = rotate_point(v.config.color_x, v.config.color_y, dir);
            [nx,ny] = translate_point(nx,ny,xpos,ypos);

            % determine which cell the color sensor is in
            [cx,cy] = v.maplocfrompos(nx,ny);
            if cx<1 || cx > v.map.width || cy<1 || cy> v.map.height
                return
            end

            result = false;
            if v.map.getCellZoneType(cx,cy,1) == 2
                % maze has a picup zone on the north side -determine if the
                % color sensor lies within the area
                ylimit = -1*(cy-1)*v.map.cell_size - 7.5;
                if ny>ylimit
                    result = true;
                end
            elseif v.map.getCellZoneType(cx,cy,2) == 2
                % maze has a picup zone on the south side - determine if the
                % color sensor lies within the area
                ylimit = -1*cy*v.map.cell_size + 7.5;
                if ny<ylimit
                    result = true;
                end
            elseif v.map.getCellZoneType(cx,cy,3) == 2
                % maze has a picup zone on the east side - determine if the
                % color sensor lies within the area
                xlimit = cx*v.map.cell_size - 7.5;
                if nx>xlimit
                    result = true;
                end
            elseif v.map.getCellZoneType(cx,cy,4) == 2
                % maze has a picup zone on the west side - determine if the
                % color sensor lies within the area
                xlimit = (cx-1)*v.map.cell_size + 7.5;
                if nx<xlimit
                    result = true;
                end
            end
        end

        function result = isdropoff(v,xpos,ypos,dir)
            % determine if the vehicle's color sensor is over the yellow
            % color strip on the floor.  If so, return true, otherwise,
            % return false;
            result = false;
            % first, calculate the location of the center of the color sensor
            [nx,ny] = rotate_point(v.config.color_x, v.config.color_y, dir);
            [nx,ny] = translate_point(nx,ny,xpos,ypos);

            % determine which cell the color sensor is in
            [cx,cy] = v.maplocfrompos(nx,ny);
            if cx<1 || cx > v.map.width || cy<1 || cy> v.map.height
                return
            end

            result = false;
            if v.map.getCellZoneType(cx,cy,1) == 3
                % maze has a picup zone on the north side -determine if the
                % color sensor lies within the area
                ylimit = -1*(cy-1)*v.map.cell_size - 7.5;
                if ny>ylimit
                    result = true;
                end
            elseif v.map.getCellZoneType(cx,cy,2) == 3
                % maze has a picup zone on the south side - determine if the
                % color sensor lies within the area
                ylimit = -1*cy*v.map.cell_size + 7.5;
                if ny<ylimit
                    result = true;
                end
            elseif v.map.getCellZoneType(cx,cy,3) == 3
                % maze has a picup zone on the east side - determine if the
                % color sensor lies within the area
                xlimit = cx*v.map.cell_size - 7.5;
                if nx>xlimit
                    result = true;
                end
            elseif v.map.getCellZoneType(cx,cy,4) == 3
                % maze has a picup zone on the west side - determine if the
                % color sensor lies within the area
                xlimit = (cx-1)*v.map.cell_size + 7.5;
                if nx<xlimit
                    result = true;
                end
            end
        end

        function dist = getUltrasonicDist(v)
            %==============================================================
            % getUltrasonicDist()
            %
            % query the maze to determine what the ultrasonic distance is
            % to the closest wall.  This function is intended to mimic
            % reading the ultrasonic sensor from the EV3 brick.
            %
            % dist - the distance (in centimeters) to the closest maze 
            % wall in the direction of the ultrasonic sensor.
            % 
            
            % take three readings at slightly different angles to account
            % for the sonic dispersion of the sensor within hte maze
            y1 = v.config.ussense_y;
            x1 = v.config.ussense_x;
            [x1,y1] = rotate_point(x1,y1,v.d);
            [x1,y1] = translate_point(x1,y1,v.x,v.y);
            [dw(1), a(1)] = v.map.getClosestWallDistance(x1,y1,v.config.usonic_angle+v.d+2);
            [dw(2), a(2)] = v.map.getClosestWallDistance(x1,y1,v.config.usonic_angle+v.d);
            [dw(3), a(3)] = v.map.getClosestWallDistance(x1,y1,v.config.usonic_angle+v.d-2);
            
            % if the angle between the the wall and the direction of the ultrasonic sensor
            % is greater than 45 degrees, adjust the distance accordingly
            % this impact has not been precisely coordinated with the
            % sensor characteristics but it is known that readings increase
            % for angles beyond 45 degrees
            for i=1:3
                if a(i)<45
                    dw(i) = power(dw(i), 1+(45-a(i))/180);
                end
            end
                       
            dist = sum(dw)/3.0;
            
            % truncate the sensor reading within the range 3:255
            dist = min(255.0,max(3.0,dist));
        end
        
        function result = getTestMotorResponse(v,nos)
            %==============================================================
            % getTestMotorResponse
            %
            % for the specified input bitfield, test the corresponding
            % motors to determine if they are in the busy state.  If any is
            % busy, return 1.  Otherwise, return 0;
            %
            % nos - is a bitfield corresponding to the output ports to test
            %   01 = test port "A"
            %   02 = test port "B"
            %   03 = test port "C"
            %   04 = test port "D" (hidden from users but used for clutch)
            %
            % result = 1 if any motors are in the "busy" state.  Otherwise,
            %          returns 0.
            result = 0;
            for i=1:4
                if bitget(nos,i)==1 
                    if v.config.has_clutch ~= 1
                        if v.mot(i).isBusy()
                            result = 1;
                        end
                    else 
                        if (i==1) 
                            % return busy state for motor a and b
                            if v.mot(1).isBusy() || v.mot(2).isBusy()
                                result = 1;
                            end
                        elseif i==2
                            % return busy state for motor d
                            if v.mot(i).isBusy()
                                result = 1;
                            end
                        else
                            % return busy state for motor c
                            v.mot(3).stopMotor()
                        end
                    end
                end
            end
        end

        function stopMotors(v,nos)
            %==============================================================
            % stopMotors
            %
            % for the specified input bitfield, stop the corresponding
            % motors.
            %
            % nos - is a bitfield corresponding to the output ports to test
            %   01 = test port "A"
            %   02 = test port "B"
            %   03 = test port "C"
            %   04 = test port "D"  - Hidden from users used for clutch
            %
            for i=1:3
                if bitget(nos,i)==1 
                    if v.config.has_clutch ~= 1
                        v.mot(i).stopMotor();
                    else 
                        if (i==1) 
                            % stop motors A and B
                            v.mot(1).stopMotor();
                            v.mot(2).stopMotor();
                        elseif i==2
                            % stop the clutch motor
                            v.mot(4).stopMotor()
                        else
                            v.mot(3).stopMotor()
                        end
                    end
                end
            end
        end

        function setMotorPower(v,nos,power)
            %==============================================================
            % setMotorPower
            %
            % for the specified input bitfield, set the power for the 
            % corresponding motors.
            %
            % nos - is a bitfield corresponding to the output ports
            %   01 = test port "A"
            %   02 = test port "B"
            %   03 = test port "C"
            %   04 = test port "D"  - Hidden motor used for clutch
            %
            for i=1:3
                if v.config.has_clutch ~= 1
                    if bitget(nos,i)==1 
                        v.mot(i).setPower(power);
                    end
                else
                    if bitget(nos,i)==1 
                        if i == 1
                            % set the power for motor A 
                            v.mot(i).setPower(power);
                            % set the power for motor B based on the clutch
                            % direction
                            v.mot(2).setPower(power*v.getClutchDirection());
                        elseif i == 2
                            % set the power for motor D - the clutch motor 
                            v.mot(4).setPower(power);
                        else
                            % set the power for motor C
                            v.mot(i).setPower(power);
                        end
                    end
                end
            end
        end
        
        function motorSpeedStep(v,nos,power,step1,step2,step3)
            %==============================================================
            % setMotorPower
            %
            % for the specified input bitfield, set the speed step profile
            % for the corresponding motors.
            %
            % nos - is a bitfield corresponding to the output ports
            %   01 = test port "A"
            %   02 = test port "B"
            %   03 = test port "C"
            %   04 = test port "D" - hidden motor used for clutch
            % power - the steady state power for the speed profile
            % step1 - the number of motor steps in the acceleration ramp
            % step2 - the number of steps in the steady-state power phase
            % step3 - the number of steps in the deceleration ramp
            for i=1:3
                if v.config.has_clutch ~= 1
                    if bitget(nos,i)==1 
                        v.mot(i).startProfileMove(power,step1,step2,step3);
                    end
                else
                    if bitget(nos,i)==1 
                        if i == 1
                            % set the profile for motor A 
                            v.mot(1).startProfileMove(power,step1,step2,step3);
                            % set the profile for motor B based on the clutch
                            % direction
                            v.mot(2).startProfileMove(power*v.getClutchDirection(),step1,step2,step3);
                        elseif i == 2
                            % set the profile for motor D - the clutch motor 
                            v.mot(4).startProfileMove(power,step1,step2,step3);
                        else
                            % set the profile for motor C
                            v.mot(3).startProfileMove(power,step1,step2,step3);
                        end
                    end
                end
            end
        end

        function motorClearCount(v,nos)
            %==============================================================
            % motorClearCount
            %
            % for the specified input bitfield, clear the angular position count
            % for the corresponding motors.
            %
            % nos - is a bitfield corresponding to the output ports
            %   01 = test port "A"
            %   02 = test port "B"
            %   03 = test port "C"
            %   04 = test port "D" - hidden motor D used for clutch
            for i=1:3
                if v.config.has_clutch ~= 1
                    if bitget(nos,i)==1 
                        v.mot(i).clearCount();
                    end
                else
                    if bitget(nos,i)==1 
                        if i == 1
                            % clear the count for motors A and B
                            v.mot(1).clearCount();
                            v.mot(2).clearCount();
                        elseif i == 2
                            % clear the count for motor D - the clutch motor 
                            v.mot(4).clearCount();
                        else
                            % clear the count for motor C
                            v.mot(3).clearCount();
                        end
                    end
                end
            end
        end
        
        function result = getMotorCount(v,no)
            %==============================================================
            % getMotorCount
            %
            % for the specified motor, return the value of the angular position
            %
            % no - the number of the motor to access
            % result - the angular position of the motor
            if (no<0) || (no>2)
                result = 0;
            else
                if (v.config.has_clutch==1) && (no == 1)
                    % return the position of the clutch
                    result = v.mot(4).getCount();
                else
                    % return the position of the specified motor
                    result = v.mot(no+1).getCount();
                end
            end
        end
        
        function result = getMotorPower(v,no)
            %==============================================================
            % getMotorPower
            %
            % for the specified motor, return the current power value
            %
            % no - the number of the motor to access
            % result - the power of the motor
            if (no<0) || (no>2)
                result = 0;
            else
                if (v.config.has_clutch==1) && (no == 1)
                    % return the position of the clutch
                    result = v.mot(4).power;
                else
                    % return the position of the specified motor
                    result = v.mot(no+1).power;
                end
            end
        end
        
        function startMotors(v,nos)
            %==============================================================
            % stopMotors
            %
            % for the specified input bitfield, start the corresponding
            % motors.
            %
            % nos - is a bitfield corresponding to the output ports to test
            %   01 = test port "A"
            %   02 = test port "B"
            %   03 = test port "C"
            %   04 = test port "D"
            %
            for i=1:3
                if v.config.has_clutch ~= 1
                    if bitget(nos,i)==1 
                        v.mot(i).startMotor();
                    end
                else
                    if bitget(nos,i)==1 
                        if i == 1
                            % start motors A and B
                            v.mot(1).startMotor();
                            v.mot(2).startMotor();
                        elseif i == 2
                            % start motor D - the clutch motor 
                            v.mot(4).startMotor();
                        else
                            % start motor C
                            v.mot(3).startMotor();
                        end
                    end
                end
            end
        end
        
        function state = getMotorState(v,no)
            %==============================================================
            % getMotorState
            %
            % for the specified motor, return the current state
            %
            % no - the number of the motor to access
            % result - the power of the motor
            if (no<0) || (no>2)
                state = MotorState.STOPPED;
            else
                if (v.config.has_clutch==1) && (no == 1)
                    % return the state of the clutch
                    state = v.mot(4).state;
                else
                    % return the state of the specified motor
                    state = v.mot(no+1).state;
                end
            end
        end
            
        function dir = getClutchDirection(v)
            % return a direction multiplier based on the position of the 
            % hidden clutch motor. 
            % 
            % if the clutch engaged, it will either return 1 (forward) or
            % negative 1 for reverse.  If the clutch is disengaged, this
            % function will return 0
            %
            dir = 0.0;
            ct =  v.mot(4).getCount();
            clutch_range = v.mot(4).max_stop - v.mot(4).min_stop;
            if 100*(ct-v.mot(4).min_stop)/clutch_range > 75
                % clutch is witin 25% of the max stop - set direction
                dir = double(-1*v.config.clutch_dir);
            elseif 100*(ct-v.mot(4).min_stop)/clutch_range < 25
                % clutch is witin 25% of the max stop - set reverse direction
                dir = double(v.config.clutch_dir);
            end
        end
                
        function [cx, cy] = maplocfrompos(v,x,y)
            % Return the map cell coordinate corresponding to the given
            % point.
            %
            % (x,y) - the position on the map expressed in inches
            % cx, cy - the map index for the cell in which the point lies
            cx = floor(x / v.map.cell_size)+ 1;
            cy = -1*ceil(y / v.map.cell_size)+ 1;
        end
        
        function updateState(v,dt)
            %==============================================================
            % Update the state of the vehicle - its position, and motor
            % speeds.
            %
            % NOTE: Motor references are explicit to motors 1 and 2 since
            % they are always used to determine position.
            if v.getColor() == 5
                % vehicle is over red floor
                v.previously_red_floor = true;
                if v.mot(1).state == MotorState.STOPPED && v.mot(2).state == MotorState.STOPPED
                    v.stopping_time = v.stopping_time + dt;
                else
                    v.stopped_time = max(v.stopped_time, v.stopping_time);
                    v.stopping_time = 0.0;
                end
            else
                % vehicle is not over red floor
                if v.previously_red_floor && (v.stopped_time<2.0)
                    warnstr = sprintf('%05i - WARNING the vehicle may have failed to stop at stop sign.',v.warning_number);
                    v.warning_number = v.warning_number + 1;
                    v.log = [{warnstr}, v.log];
                    v.map.updateLog(v.log);
                end
                v.previously_red_floor = false;
                v.stopped_time = 0;
                v.stopping_time = 0;
            end
                
            for i=1:4
                a_old(i) = v.mot(i).angle;
                p_old(i) = v.mot(i).power;
                s_old(i) = v.mot(i).state;
                v.mot(i).updateState(dt);
            end
            x_old = v.x;
            y_old = v.y;
            d_old = v.d;
            v.updatePosition(dt);
            % check to see if a wall has been hit - if so, keep the vehicle
            % and motors in thier current states
            if v.isHittingWall()
                v.x = x_old;
                v.y = y_old;
                v.d = d_old;
                for i=1:4
                    v.mot(i).angle = a_old(i);
                    v.mot(i).power = p_old(i);
                    v.mot(i).state = s_old(i);
                end
                if ~v.hitting_wall
                    warnstr = sprintf('%05i - WARNING the vehicle has collided with a wall. Position may no longer be accurate.',v.warning_number);
                    v.warning_number = v.warning_number + 1;
                    v.log = [{warnstr}, v.log];
                    v.map.updateLog(v.log);
                    v.hitting_wall = true;
                end
            else
                v.hitting_wall = false;
            end
         
            % updatee the map to show the new location of the vehicle
            v.vi.setPosition(v.x,v.y);
            v.vi.setDirection(v.d);
            pause(.001);
        end
        
        function updateVehicleStateText(v)
            %==============================================================
            % create an array of cell information for motor and sensor
            % states that can be used to update the vehicle state on the
            % map display.
            %
            color = [{'none'} {'black'} {'blue'} {'green'} {'yellow'} {'red'} {'white'} {'brown'}];
            if v.getMotorState(0) ~= MotorState.STOPPED 
                txt = [{sprintf('Motor A Power   : %7.0f Angle %12.0f:',v.getMotorPower(0),v.getMotorCount(0))}];
            else
                txt = [{sprintf('Motor A Power   : STOPPED Angle %12.0f:',v.getMotorCount(0))}];
            end
            if v.getMotorState(1) ~= MotorState.STOPPED 
                txt = [txt, {sprintf('Motor B Power   : %7.0f Angle %12.0f:',v.getMotorPower(1),v.getMotorCount(1))}];
            else
                txt = [txt {sprintf('Motor B Power   : STOPPED Angle %12.0f:',v.getMotorCount(1))}];
            end
            if v.getMotorState(2) ~= MotorState.STOPPED 
                txt = [txt, {sprintf('Motor C Power   : %7.0f Angle %12.0f:',v.getMotorPower(2),v.getMotorCount(2))}];
            else
                txt = [txt {sprintf('Motor C Power   : STOPPED Angle %12.0f:',v.getMotorCount(2))}];
            end
            txt = [txt,...
                   {sprintf('Input 1 (Touch) : %i', v.getBumpState(1))},...
                   {sprintf('Input 2 (Touch) : %i', v.getBumpState(2))},...
                   {sprintf('Input 3 (Color) : %s',char(color(min(v.getColor()+1,8))))},...
                   {sprintf('Input 4 (Usonic): %0.1f',v.getUltrasonicDist())}];
            v.map.updateVehicleStateText(txt);
        end
            
            
        function updatePosition(v,dt)
            %==============================================================
            % update the position of the vehicle given a specific timestep
            %
            % motor indicies are explicitly 1 and 2 since these motors are
            % always used to calculate position.
            
            if v.mot(1).state == MotorState.STOPPED
                pwr1 = 0;
            else
                pwr1 = v.mot(1).power;
            end
            if v.mot(2).state == MotorState.STOPPED
                pwr2 = 0;
            else
                pwr2 = v.mot(2).power;
            end
            
            % take care of some easy cases
            % 1 - both wheels are stopped
            if (pwr1 == 0) && (pwr2 == 0)
                return;
            end
            % 2 - both motors are running in the same direction at the same
            % speed
            ips1 = (v.config.wheel_circumference*v.config.drive_gear_ratio*v.mot(1).max_rpm/60)*pwr1/100;
            ips2 = (v.config.wheel_circumference*v.config.drive_gear_ratio*v.mot(2).max_rpm/60)*pwr2/100;
            if ips1 == ips2
                rot_per_sec = (1.0/60.0)*v.mot(1).max_rpm*(pwr1/100);
                distance = v.config.wheel_circumference*v.config.drive_gear_ratio*dt*rot_per_sec;
                dx = distance*cos(v.d*pi/180);
                dy = distance*sin(v.d*pi/180);
                [v.x, v.y] = translate_point(v.x,v.y,dx,dy);
            end
            % 3 - both motors are running in the opposite directions at the same
            % speed.  In this case, the vehicle will pivot around the point
            % midway between the two motors.  Assume that motor 1 is the 
            % left motor and motor 2 is the right motor.  In this case,
            % motor1 positive will result in clockwise rotation. Motor 2
            % positive will result in counterclockwise rotation.
            if ips1 == -1*ips2
                circumference_of_pivot = v.config.wheelbase*pi();
                rot_per_sec = (1/60)*v.mot(1).max_rpm*(pwr1/100);
                distance = v.config.wheel_circumference*v.config.drive_gear_ratio*dt*rot_per_sec;
                pivot_degrees = -360*distance/(circumference_of_pivot);
                v.d = v.d + pivot_degrees;
            end
            % 4 - both motors are running in the same direction but at different
            % speeds.  In this case, the two wheels will sweep arcs with a
            % shared center point and radii that are related to the ratio
            % of their speeds.
            % if s1, s2 are the speeds of the motors (s1>s2)
            % and w is the wheelbase of the vehicle
            % then:
            % r1 = r2 + w
            % and s2/s1 = r2/r1
            %
            if (ips1 * ips2 >= 0) && (ips1 ~= ips2)
                rad2 = -1*ips2*v.config.wheelbase/(ips2-ips1);
                rad1 = rad2+v.config.wheelbase;
                ips_avg = (ips1+ips2)/2;
                rad_avg = (rad1+rad2)/2;
                cir_avg = 2.0*pi*rad_avg;
                center_x = cos((v.d-90)*pi/180)*rad_avg + v.x;
                center_y = sin((v.d-90)*pi/180)*rad_avg + v.y;
                rotation_degrees = -360*(ips_avg*dt/cir_avg);
                xc = v.x-center_x;
                yc = v.y-center_y;
                v.x = xc*cos(rotation_degrees*pi/180)-yc*sin(rotation_degrees*pi/180)+center_x;
                v.y = yc*cos(rotation_degrees*pi/180)+xc*sin(rotation_degrees*pi/180)+center_y;
                v.d = v.d + rotation_degrees;
            end
            % 5 - motors are running in different directions and at different
            % speeds.  The motion will be a combination of #4 above followed
            % by #2 above
            if (ips1 * ips2 < 0) && (ips1 ~= -1*ips2)
                % first perform the gate turn around the slower axle
                dps1 = ips1 + ips2;
                rad2 = 0;
                rad1 = rad2+v.config.wheelbase;
                ips_avg = (dps1)/2;
                rad_avg = (rad1+rad2)/2;
                cir_avg = 2.0*pi*rad_avg;
                center_x = cos((v.d-90)*pi/180)*rad_avg + v.x;
                center_y = sin((v.d-90)*pi/180)*rad_avg + v.y;
                rotation_degrees = -360*(ips_avg*dt/cir_avg);
                xc = v.x-center_x;
                yc = v.y-center_y;
                v.x = xc*cos(rotation_degrees*pi/180)-yc*sin(rotation_degrees*pi/180)+center_x;
                v.y = yc*cos(rotation_degrees*pi/180)+xc*sin(rotation_degrees*pi/180)+center_y;
                v.d = v.d + rotation_degrees;
                
                % next, pivot around the center of the wheelbase
                circumference_of_pivot = v.config.wheelbase*pi();
                rot_per_sec = (1/60)*v.mot(1).max_rpm*(-1*pwr2/100);
                distance = v.config.wheel_circumference*v.config.drive_gear_ratio*dt*rot_per_sec;
                pivot_degrees = -360*distance/(circumference_of_pivot);
                v.d = v.d + pivot_degrees;
            end
        end       
    end    
end

function [xn, yn] = translate_point(x,y, ox, oy)
    % translate the specified point by the given x and y displacements
    xn = x+ox;
    yn = y+oy;
end

function [xn, yn] = rotate_point(x,y, angle)
    % rotate the specified point around the origin by the angle given
    xn = x * cos(angle*pi/180.0) - y * sin(angle*pi/180.0);
    yn = x * sin(angle*pi/180.0) + y * cos(angle*pi/180.0);
end
