classdef MotorMsgEvent
    %======================================================================
    % class MotorMsgEvent
    %======================================================================
    % This class provides an enumeration of events that can cause 
    % SimMotorState state machine changes.
    %
    %======================================================================
    % Revision History 
    %======================================================================
    % Version 1.0 20171027 - Beta Release - Doug Sandy
    %
    %======================================================================
    % Copyright Notice 
    %======================================================================
    % COPYRIGHT (C) 2017, 
    % ARIZONA STATE UNIVERSITY
    % ALL RIGHTS RESERVED
    %    
    enumeration
        START_RUNNING;
        START_RAMP;
        STOP;
        NONE;
    end
end