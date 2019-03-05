% Gyro interface for lego mindstorm EV3
%
% Methods::
% Gyro               Constructor, intializes the physical device
% calibrate          Recalibrates the gyro, sets the angle to zero
% getAngle           returns the angle of the gyro
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

classdef Gyro < handle
    properties
        % a handle for the mindstorm control brick that the gyro is 
        % connected to
        brick;
        % the port number that the gyro is connected to
        gyro_port;
        
        % if the gyro is an older version, this is set to 1.
        config_as_older_version;
    end
    
    methods
        % ================================================================
        % Gyro()
        %
        % create a new gyro object and calibrate it to 0 degrees.
        %
        % input parameters:
        %    brick - a handle for the EV3 brick that the gyro is connected
        %            to.
        %    gyroport - the port number that the gyro sensor is connected
        %            to.
        %    old/new - (optional argument), if this is "old", then the 
        %            gyro will be calibrated as if it is an older version
        %            lego EV3 gyro.  The older calibration mode applies to
        %            gyros that have serial numbers that end in N1, N2 or
        %            N3.
        %
        % returns:
        %    a handle to the newly created & configured gyro object.
        %
        function gyro = Gyro(brick, gyroport, varargin) 
             % check for case of zero input arguments - this is an error
             if nargin == 0
                fprintf('Error - gyro object cannot be created without parmeters\n');
                return;
             end
             gyro.config_as_older_version = 0;
             if nargin >= 3
                 gyro.config_as_older_version = varargin{1};
             end
             % initialize the gyro's properties
             gyro.brick = brick;
             gyro.gyro_port = gyroport;
             
             % perform calibration of the gyro
             gyro.calibrate();
        end
        
        % ================================================================
        % calibrate()
        %
        % calibrates the gyro to zero degrees and eliminates angular drift.
        % This function works for all new gyros.  Gyros with serial numbers
        % that end with "N2" or "N3" cannot be calibrated this way.
        %
        % input parameters:
        %    gyro - a handle for the gyro object.  This is not a required
        %           parameter if the function is called by using the object
        %           dot notation (gyro.calibrate()).
        %
        % returns:
        %    nothing.
        %
        function calibrate(gyro)
            % make sure robot is stopped
            pause(1);
                        
            if gyro.config_as_older_version == 1
                % read the gyro as a angle
                gyro.brick.GyroAngle(gyro.gyro_port);
                pause(.1);
                
                % read the gyro as a rate
                gyro.brick.GyroRate(gyro.gyro_port);
                pause(.1);

                % read the gyro as an angle
                gyro.brick.GyroAngle(gyro.gyro_port);
                pause(3);                
            else
                % read the gyro as a gyro
                gyro.getAngle();
                pause(.1);

                % send a calibration command
                gyro.brick.inputReadSI(gyro.gyro_port,4);
                disp(gyro.brick.inputDeviceGetName(gyro.gyro_port-1))
                disp(gyro.brick.inputDeviceSymbol(gyro.gyro_port-1))
                pause(3);
            end
            
            % clear any buffered values
            count = 0;
            while ((gyro.getAngle()~=0)||(count<4))
                count = count +1;
            end
        end
        
        % ================================================================
        % getAngle()
        %
        % returns the gyro's current rotation in degrees.
        %
        % input parameters:
        %    gyro - a handle for the gyro object.  This is not a required
        %           parameter if the function is called by using the object
        %           dot notation (gyro.calibrate()).
        %
        % returns:
        %    The gyro's current angular rotation.
        %
        function angle = getAngle(gyro)
            % get the gyro angular position
            for i=1:9 
                a(i) = gyro.brick.GyroAngle(gyro.gyro_port);
            end
            a = sort(a);
            angle = a(5); 
        end 
        
        function msg = test(gyro)
            msg = 0;
            %cmd = Command();
            %cmd.addHeaderDirect(42,0,0);
            %cmd.addDirectCommand(153);  % 0x99 = input_device
            %cmd.LC0(4);                 % CMD = 4 (CAL_DEFAULT)
            %cmd.LC0(Device.Gyro);       % gyro device type
            %cmd.LC0(Device.GyroAng);    % gyro angle mode
            %cmd = Command();
            %cmd.addHeaderDirect(42,0,0);
            %cmd.addDirectCommand(153);  % 0x99 = input_device
            %cmd.LC0(0);                 % Layer 0
            cmd = Command();
            cmd.addHeaderDirectReply(42,1,0);
            cmd.opINPUT_DEVICE_GET_NAME(0,gyro.gyro_port-1,-1,0)
            cmd.addLength();
            gyro.brick.send(cmd);
            msg = gyro.brick.receive();
        end
    end
end

