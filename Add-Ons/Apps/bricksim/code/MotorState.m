classdef MotorState
    %======================================================================
    % class MotorState
    %======================================================================
    % This class provides an enumeration of SimMotorState finite state
    % machine states.
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
        STOPPED;
        RUNNING;
        START_R1;
        R1;
        STEADY;
        START_R2;
        R2;
    end
end