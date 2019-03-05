%==========================================================================
% simBrickServer
%==========================================================================
% This file contains functions to support the Lego Mindstorm Brick
% simulator.  To use this simulator:
%
% 1. Open a separate matlab window
% 2. Type "simBrickServer" in the matlab command window
%
% The server will begin running and waiting for a TCP connection from a
% SimBrick.  
%
% When you wish to close the simulator:
% 1. Using the mouse, click anywhere in the matlab command window.
% 2. Type "Ctrl-C" to interrupt the simulator operation
% 3. Close the instance of Matlab that was running the simulator.
%
%==========================================================================
% Example::
%==========================================================================
%    simBrickServer()
%
%==========================================================================
% Revision History 
%==========================================================================
% Version 1.2 201730   - Replaced string functions with older character 
%                        functions to support Matlab 2016.  Added support
%                        for hidden clutch motor and a variety of vehicle
%                        configuration commands (for instructor use).
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
function simBrickServer()
% This is the main simulator entry point.  It loops continuously until
% interrupted by Ctrl-C.
%
    while -1
        % attempt to open a new TCPIP session
        session();
    end
end

function session()
% Establish and manage a TCPIP session with a SimBrick object.  Upon entry
% the connection is established.  Upon exit, the connection has been shut
% down.
    
    t = tcpip('0.0.0.0', 30000, 'NetworkRole', 'server');
    
    % Open connection to the client. 
    fprintf('Waiting to Establish Connection\n');
    fopen(t); 
    fprintf('Connection Established\n');

    v = SimVehicle();
    
    % Pause for the communication delay, if needed. 
    pause(1) 
    close_req = false;

    % Receive lines of data from server 
    while ~close_req
        dt = 0.05;
        running_speed = 0;
        if (v.mot(1).power~=0) && (v.mot(1).state~=MotorState.STOPPED)
            running_speed = v.config.wheelbase*v.config.drive_gear_ratio*(v.mot(1).max_rpm/60)*abs(v.mot(1).power)/100.0;
        end
        if (v.mot(2).power~=0) && (v.mot(2).state~=MotorState.STOPPED)
            running_speed = max(running_speed,v.config.wheelbase*v.config.drive_gear_ratio*(v.mot(1).max_rpm/60)*abs(v.mot(1).power)/100.0);
        end
        % the simulation time step must be not allow the vehicle to move
        % more than .25 inches (if using bump sensors).  
        if (running_speed>0) 
            dt = min(0.1,0.25/running_speed);
        end
        pause(dt);
        v.updateState(dt);
        v.updateVehicleStateText();

        if (get(t, 'BytesAvailable') > 0) 
            DataReceived = strsplit(strtrim(fscanf(t)))';
            if size(DataReceived,1) < 2
                continue;
            end
            if (strcmp(DataReceived(1),'GET')) 
                if (strcmp(DataReceived(2),'inputReadSI'))
                    % opINPUT_READSI
                    if size(DataReceived,1) ~= 4
                        sendDirectErrorResponse(t);
                    else
                        % read the specified input and
                        % return the response
                        port = str2double(DataReceived(3));
                        mode = str2double(DataReceived(4));
                        sendInputReadResponse(t,v.getInputResponse(port,mode));
                        %fprintf('read sensor\n');
                    end                                   
                elseif (strcmp(DataReceived(2),'motorBusy'))
                    % Motor busy
                    if size(DataReceived,1) ~= 3
                        sendDirectErrorResponse(t);
                    else
                        nos = uint8(str2double(DataReceived(3)));
                        sendDirectResponseUint8(t,v.getTestMotorResponse(nos));
                        %fprintf('output ready\n');
                    end
                elseif (strcmp(DataReceived(2),'motorGetCount'))
                    % motor get count
                    if size(DataReceived,1) ~= 3
                        sendDirectErrorResponse(t);
                    else
                        no = uint8(str2double(DataReceived(3)));
                        sendDirectResponseInt32(t,v.getMotorCount(no));
                        %fprintf('output get count\n');
                    end
                end
            elseif (strcmp(DataReceived(1),'SET')) 
                if (strcmp(DataReceived(2),'motorStop'))
                    if size(DataReceived,1) ~= 4
                        sendDirectErrorResponse(t);
                    else
                        nos = uint8(str2double(DataReceived(3)));
                        v.stopMotors(nos);
                    end
                    %fprintf('stop outputs\n');
                elseif (strcmp(DataReceived(2),'motorPower')) 
                    % set the power level for specified outputs
                    if size(DataReceived,1) ~= 4
                        sendDirectErrorResponse(t);
                    else
                        nos = uint8(str2double(DataReceived(3)));
                        power = str2double(DataReceived(4));
                        v.setMotorPower(nos,power);
                    end
                    %fprintf('set output power\n');
                elseif (strcmp(DataReceived(2),'motorStart')) 
                    % start specified outputs
                    if size(DataReceived,1) ~= 3
                        sendDirectErrorResponse(t);
                    else
                        nos = uint8(str2double(DataReceived(3)));
                        v.startMotors(nos);
                    end
                    %fprintf('start outputs\n');
                elseif (strcmp(DataReceived(2),'motorStepSpeed')) 
                    % start output speed step profile
                    if size(DataReceived,1) ~= 7
                        sendDirectErrorResponse(t);
                    else
                        nos = uint8(str2double(DataReceived(3)));
                        power = str2double(DataReceived(4));
                        step1 = str2double(DataReceived(5));
                        step2 = str2double(DataReceived(6));
                        step3 = str2double(DataReceived(7));
                        v.motorSpeedStep(nos,power,step1,step2,step3);
                    end
                    %fprintf('output speed step\n');
                elseif (strcmp(DataReceived(2),'motorClrCount')) 
                    % clear the counter for specified outputs
                    if size(DataReceived,1) ~= 3
                        sendDirectErrorResponse(t);
                    else
                        nos = uint8(str2double(DataReceived(3)));
                        v.motorClearCount(nos);
                    end
                    %fprintf('output clear count\n');
                elseif (strcmp(DataReceived(2),'simulateClutch')) 
                    % set whether or not the simulated vehicle 
                    % includes a clutch.
                    if size(DataReceived,1) ~= 4
                        sendDirectErrorResponse(t);
                    else
                        has_clutch = uint8(str2double(DataReceived(3)));
                        clutch_direction = int8(str2double(DataReceived(4)));
                        v.config.has_clutch = has_clutch;
                        v.config.clutch_dir = clutch_direction;
                    end
                    %fprintf('output clear count\n');
                elseif (strcmp(DataReceived(2),'motorRange')) 
                    % set the range of travel for a specified motor
                    if size(DataReceived,1) ~= 5
                        sendDirectErrorResponse(t);
                    else
                        no = uint8(str2double(DataReceived(3)));
                        minr = int32(str2double(DataReceived(4)));
                        maxr = int32(str2double(DataReceived(5)));
                        v.mot(no+1).has_min_stop = true;
                        v.mot(no+1).min_stop = minr;
                        v.mot(no+1).has_max_stop = true;
                        v.mot(no+1).max_stop = maxr;
                        v.mot(no+1).angle = (minr+maxr)/2;
                    end
                elseif (strcmp(DataReceived(2),'driveGearRatio')) 
                    % set the drive gear rtio for the vehicle
                    if size(DataReceived,1) ~= 4
                        sendDirectErrorResponse(t);
                    else
                        num = str2double(DataReceived(3));
                        denom = str2double(DataReceived(4));
                        v.config.drive_gear_ratio = num/denom;
                    end
                elseif (strcmp(DataReceived(2),'effectiveWheelbase')) 
                    % set the wheelbase for turning
                    if size(DataReceived,1) ~= 3
                        sendDirectErrorResponse(t);
                    else
                        v.config.wheelbase = str2double(DataReceived(3));
                    end
                elseif (strcmp(DataReceived(2),'end')) || ...
                    (strcmp(DataReceived(2),'disconnect'))
                    % clear the counter for specified outputs
                    if size(DataReceived,1) ~= 2
                        sendDirectErrorResponse(t);
                    else
                        % stop specified outputs
                        fprintf('Closing Connection\n');
                        close_req = true;
                        break;
                    end
                end
            end
        end
    end
    % Disconnect and clean up the server connection. 
    fclose(t); 
    delete(t); 
    clear t;
end

function sendDirectErrorResponse(t)
    fprintf(t,'RESP ERROR');
end

function sendDirectResponseUint32(t,s)
    fprintf(t,sprintf('RESP %i',uint32(s)));
end

function sendDirectResponseInt32(t,s)
    fprintf(t,sprintf('RESP %i',int32(s)));
end

function sendDirectResponseUint8(t,c)
    fprintf(t,sprintf('RESP %i',uint8(c)));
end

function sendInputReadResponse(t, v)
    fprintf(t,sprintf('RESP %f',v));
end

