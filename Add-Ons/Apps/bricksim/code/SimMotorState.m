classdef SimMotorState < handle
    % SimMotorState a simulation of the EV3 motor state.  The state
    % transition matrix is shown below
    %
    % Current  | Description             | Event                | Next
    % State    |                         |                      |
    % ====================================================================
    % START    | Initial State           | Immediate            | STOPPED
    % --------------------------------------------------------------------
    % STOPPED  | Motor is stopped        | Start Command Recvd  | RUNNING  
    %          | Status is "not busy"    |---------------------------------
    %          |                         | Speed Step Recvd     | START_R1 
    %          |                         | 
    %----------------------------------------------------------------------
    % RUNNING  | Motor is running at     | Stop Command Recvd   | STOPPED
    %          | constant power level.   |---------------------------------
    %          | Status is "not busy"    | Speed Step Recvd     | START_R1
    %          |                         |
    %          | Status is "not busy"    |
    % ---------------------------------------------------------------------
    % START_R1 | Initialize motor ramp   | Immediate            | R1
    %          | for constant slope over |                      |
    %          | a specific number of    |                      |
    %          | steps.                  |                      |
    %          | Status is "busy"        |                      |
    % ---------------------------------------------------------------------
    % R1       | ramping motor power up  | steps count for ramp | STEADY
    %          | Status is "busy"        | reached              |
    %          |                         |---------------------------------
    %          |                         | Stop Command Recvd   | STOPPED
    %          |                         |---------------------------------
    %          |                         | Speed Step Recvd     | START_R1
    %----------------------------------------------------------------------
    % STEADY   | running motor at const  | steps count for      | START_R2
    %          | power. Status is "busy" | steady is reached    |
    %          |                         |---------------------------------
    %          |                         | Stop Command Recvd   | STOPPED
    %          |                         |---------------------------------
    %          |                         | Speed Step Recvd     | START_R1
    %----------------------------------------------------------------------
    % START_R2 | Initialize motor ramp   | Immediate            | R2
    %          | for constant slope over |                      |
    %          | a specific number of    |                      |
    %          | steps.                  |                      |
    %          | Status is "busy"        |                      |
    % ---------------------------------------------------------------------
    % R1       | ramping motor power down| steps count for ramp | STOPPED
    %          | Status is "busy"        | reached              |
    %          |                         |---------------------------------
    %          |                         | Stop Command Recvd   | STOPPED
    %          |                         |---------------------------------
    %          |                         | Speed Step Recvd     | START_R1
    %----------------------------------------------------------------------
    %==========================================================================
    % Revision History 
    %==========================================================================
    % Version 1.1 20171106 - Bug Fix - when motor angle is cleared,
    %                 recalculate the motor stops relative to the new 
    %                 position
    % Version 1.0 20171028 - Beta Release - Doug Sandy
    %
    %==========================================================================
    % Copyright Notice 
    %==========================================================================
    % COPYRIGHT (C) 2017, 
    % ARIZONA STATE UNIVERSITY
    % ALL RIGHTS RESERVED
    %
    properties
        power;
        angle;
        state;
        event;
        max_rpm;        % 100% velocity in rpm
        r1_slope;       % acceleration during r1 phase expressed in degrees/sec^2
        r2_slope;       % acceleration during r2 phase expressed in degrees/sec^2
        steady_power;
        r1_end_angle;
        steady_end_angle;
        r2_end_angle;
        has_min_stop;   % true if the motor has a minimum angle stop
        has_max_stop;   % true if the motor has a maximum angle stop
        max_stop;       % the value for the minimum angle stop
        min_stop;       % the value for the maximum angle stop
    end
    
    methods
        function sms = SimMotorState()
            % constructor
            sms.state = MotorState.STOPPED;
            sms.event = MotorMsgEvent.NONE;
            sms.power = 0;
            sms.angle = 0;
            sms.max_rpm = 170;
            sms.has_min_stop = false;
            sms.has_max_stop = false;
        end
        
        function reset(sms)
            sms.state = MotorState.STOPPED;
            sms.event = MotorMsgEvent.NONE;
            sms.power = 0;
            sms.angle = 0;
            sms.max_rpm = 170;
        end
        
        function startMotor(sms)
            % if the motor is not busy, create a start event.  Otherwise,
            % do nothing.
            if ~sms.isBusy()
                sms.event = MotorMsgEvent.START_RUNNING;
            end
        end
        
        function stopMotor(sms)
            % create a start motor stop event.  This is processed
            % immediately.
            %sms.event = MotorMsgEvent.STOP;
            sms.state = MotorState.STOPPED;
            sms.power = 0;
        end
        
        function setPower(sms, p)
            % if the motor is not busy, set the motor power.  Otherwise,
            % do nothing.
            if ~sms.isBusy()
                sms.power = p;
            end
        end

        function clearCount(sms)
            % if the motor is not busy, clear the angle to 0 degrees.
            % Otherwise, do nothing.
            if ~sms.isBusy()
                % move the motor stops relative to the new angle position
                da = -sms.angle;
                sms.min_stop = sms.min_stop + da;
                sms.max_stop = sms.max_stop + da;
                
                % reset the angle
                sms.angle = 0;
            end
        end

        function setMinStop(sms, stopangle) 
           if stopangle>sms.angle
               return
           end
           sms.min_stop = stopangle;
           sms.has_min_stop = true;
        end
        
        function setMaxStop(sms, stopangle) 
           if stopangle<sms.angle
               return
           end
           sms.max_stop = stopangle;
           sms.has_max_stop = true;
        end

        function clearStops(sms) 
           sms.has_max_stop = false;
           sms.has_min_stop = false;
        end

        function startProfileMove(sms,p,s1,s2,s3)
            % if the motor is not busy, clear the angle to 0 degrees.
            % Otherwise, do nothing.
            sms.steady_power = p;
            max_speed = sms.max_rpm * 360.0/60.0;
            if p>=0
                sms.r1_slope = max_speed*max_speed*(p*p/(100*100) - sms.power*sms.power/(100*100))/(2*s1);
                sms.r2_slope = max_speed*max_speed*(-p*p/(100*100))/(2*s3);
                sms.r1_end_angle = sms.angle + s1;
                sms.steady_end_angle = sms.r1_end_angle + s2;
                sms.r2_end_angle = sms.steady_end_angle + s3;
            else
                sms.r1_slope = -1*max_speed*max_speed*(p*p/(100*100) - sms.power*sms.power/(100*100))/(2*s1);
                sms.r2_slope = -1*max_speed*max_speed*(-p*p/(100*100))/(2*s3);
                sms.r1_end_angle = sms.angle - s1;
                sms.steady_end_angle = sms.r1_end_angle - s2;
                sms.r2_end_angle = sms.steady_end_angle - s3;
            end
            sms.event = MotorMsgEvent.START_RAMP;
        end
        
        function angle = getCount(sms)
            % return the current angular position of the motor
            angle = sms.angle;
        end

        function busy = isBusy(sms)
            % return true if the motor is currently executing a profiled
            % move command.
            busy = false;
            switch sms.state
                case MotorState.R1
                    busy = true;
                case MotorState.STEADY
                    busy = true;
                case MotorState.R2
                    busy = true;
            end
        end
        
        function updateState(sms, timestep)
            % update the state of the motor's speed and position based
            % on the lego mindstorm motor finite state machine.
            switch sms.state
                case MotorState.STOPPED
                    switch sms.event
                        case MotorMsgEvent.START_RUNNING
                            sms.state = MotorState.RUNNING;
                        case MotorMsgEvent.START_RAMP
                            sms.state = MotorState.R1;
                    end
                case MotorState.RUNNING
                    sms.angle = sms.angle + sms.max_rpm*(360.0/60.0)*(sms.power/100)*timestep;
                    if (sms.has_min_stop) && (sms.angle<sms.min_stop)
                        sms.angle = sms.min_stop;
                    elseif (sms.has_max_stop) && (sms.angle>sms.max_stop)
                        sms.angle = sms.max_stop;
                    end                  
                    switch sms.event
                        case MotorMsgEvent.STOP
                            sms.state = MotorState.STOPPED;
                        case MotorMsgEvent.START_RAMP
                            sms.state = MotorState.R1;
                    end
                case MotorState.R1
                    % update the angular position of the motor assuming
                    % constant acceleration over the time step
                    sms.angle = sms.angle + ...
                        sms.max_rpm*(360.0/60.0)*(sms.power/100)*timestep + ...
                        0.5*sms.r1_slope*timestep*timestep;
                    
                    if (sms.has_min_stop) && (sms.angle<sms.min_stop)
                        sms.angle = sms.min_stop;
                    elseif (sms.has_max_stop) && (sms.angle>sms.max_stop)
                        sms.angle = sms.max_stop;
                    else
                        % update the speed/power of the motor
                        sms.power = sms.power + 100*(sms.r1_slope*timestep)*(60/360)/sms.max_rpm;
                        if sms.steady_power >= 0 && sms.power>sms.steady_power
                            degrees_since_steady = sms.angle - sms.r1_end_angle;
                            avg_power_since_steady = (sms.power+sms.steady_power)/2.0;
                            degrees_at_steady = sms.steady_power*(degrees_since_steady/avg_power_since_steady);
                            sms.power = sms.steady_power;
                            sms.angle = sms.r1_end_angle+degrees_at_steady;
                            sms.state = MotorState.STEADY;
                        elseif sms.steady_power<0.0 && sms.power<sms.steady_power
                            degrees_since_steady = sms.angle - sms.r1_end_angle;
                            avg_power_since_steady = (sms.power+sms.steady_power)/2.0;
                            degrees_at_steady = sms.steady_power*(degrees_since_steady/avg_power_since_steady);
                            sms.power = sms.steady_power;
                            sms.angle = sms.r1_end_angle+degrees_at_steady;
                            sms.state = MotorState.STEADY;
                        end
                    end

                    switch sms.event
                        case MotorMsgEvent.STOP
                            sms.state = MotorState.STOPPED;
                        case MotorMsgEvent.START_RAMP
                            sms.state = MotorState.R1;
                    end
                case MotorState.STEADY
                    % update the angular position of the motor assuming
                    % constant velocity over the time step
                    sms.angle = sms.angle + sms.max_rpm*(360.0/60.0)*(sms.steady_power/100)*timestep;
                    if (sms.has_min_stop) && (sms.angle<sms.min_stop)
                        sms.angle = sms.min_stop;
                    elseif (sms.has_max_stop) && (sms.angle>sms.max_stop)
                        sms.angle = sms.max_stop;
                    else
                        if sms.steady_power>0 && sms.angle > sms.steady_end_angle
                            da = sms.angle - sms.steady_end_angle;
                            time_past_steady = da/(sms.max_rpm*(360.0/60.0)*(sms.steady_power/100)); 
                            sms.angle = sms.steady_end_angle + ...
                                sms.max_rpm*(360.0/60.0)*(sms.power/100)*time_past_steady + ...
                                0.5*sms.r2_slope*time_past_steady*time_past_steady;
                            % update the speed/power of the motor
                            sms.power = sms.steady_power + 100*(sms.r2_slope*time_past_steady)*(60/360)/sms.max_rpm;
                            %sms.angle = sms.steady_end_angle;
                            sms.state = MotorState.R2;
                        elseif sms.steady_power<0 && sms.angle < sms.steady_end_angle
                            da = sms.angle - sms.steady_end_angle;
                            time_past_steady = da/(sms.max_rpm*(360.0/60.0)*(sms.steady_power/100)); 
                            sms.angle = sms.steady_end_angle + ...
                                sms.max_rpm*(360.0/60.0)*(sms.power/100)*time_past_steady + ...
                                0.5*sms.r2_slope*time_past_steady*time_past_steady;
                            % update the speed/power of the motor
                            sms.power = sms.steady_power + 100*(sms.r2_slope*time_past_steady)*(60/360)/sms.max_rpm;
                            %sms.angle = sms.steady_end_angle;
                            sms.state = MotorState.R2;
                        end
                    end
                    switch sms.event
                        case MotorMsgEvent.STOP
                            sms.state = MotorState.STOPPED;
                        case MotorMsgEvent.START_RAMP
                            sms.state = MotorState.R1;
                    end
                case MotorState.R2
                    % update the angular position of the motor assuming
                    % constant acceleration over the time step
                    sms.angle = sms.angle + ...
                        sms.max_rpm*(360.0/60.0)*(sms.power/100)*timestep + ...
                        0.5*sms.r2_slope*timestep*timestep;
                    if (sms.has_min_stop) && (sms.angle<sms.min_stop)
                        sms.angle = sms.min_stop;
                    elseif (sms.has_max_stop) && (sms.angle>sms.max_stop)
                        sms.angle = sms.max_stop;
                    else
                        % update the speed/power of the motor
                        sms.power = sms.power + 100*(sms.r2_slope*timestep)*(60/360)/sms.max_rpm;
                        if sms.steady_power >= 0 && sms.power<=0
                            sms.power = 0;
                            sms.angle = sms.r2_end_angle;
                            sms.state = MotorState.STOPPED;
                        elseif sms.steady_power<0.0 && sms.power>=0
                            sms.power = 0;
                            sms.angle = sms.r2_end_angle;
                            sms.state = MotorState.STOPPED;
                        end
                    end
                    switch sms.event
                        case MotorMsgEvent.STOP
                            sms.state = MotorState.STOPPED;
                        case MotorMsgEvent.START_RAMP
                            sms.state = MotorState.R1;
                    end
            end
            % clear any events
            sms.event = MotorMsgEvent.NONE;
        end
    end    
end


