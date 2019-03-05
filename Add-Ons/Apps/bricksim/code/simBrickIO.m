%==========================================================================
% simBrickIO TCPIP interface between MATLAB and the simulated brick
%==========================================================================
%
% Methods::
%  simBrickIO   Constructor, initialises and opens the client connection
%  delete       Destructor, closes the client connection
%
%  open         Open a connection to the brick simulator
%  close        Close the connection to the brick simulator
%  read         Read data from the brick simulator through tcpip socket
%  write        Write data to the brick through tcpip socket
%
% Example::
%     simBrick = simBrickIO()
%
% Notes::
%     This API was based off of the Arizona State University Lego Mindstorm
%     interface for the FSE100 course. Not all functions have been 
%     implemented - only those most relevant to robotic code development
%
%==========================================================================
% Example::
%==========================================================================
%    b = SimBrickIO()
%
%==========================================================================
% Revision History 
%==========================================================================
% Version 1.0 20171028 - Beta Release - Doug Sandy
%
%==========================================================================
% Copyright Notice 
%==========================================================================
% COPYRIGHT (C) 2017, 
% ARIZONA STATE UNIVERSITY
% ALL RIGHTS RESERVED
%
classdef simBrickIO 
    properties
        % connection handle
        handle;     % the tcpip connection handle
        opened;
    end
    
    methods
        function brickIO = simBrickIO()
            % simBrickIO.simBrickIO Create a simBrickIO object
            %
            % brick = simBrickIO() is an object method which
            % initialises and opens a simulation connection between MATLAB
            % and the simulated brick using serial functions.
            %
            brickIO.opened = false;
            
            % create the tcpip client connection handle
            brickIO.handle = tcpip('LOCALHOST', 30000, 'NetworkRole', 'client'); 

            % open the conneciton handle
            brickIO.open;
        end
        
        function delete(brickIO)
            % simBrickIO.delete Delete the simBrickIO object
            %
            % closes the simulator connection

            % delete the bt handle 
            brickIO.close;
        end
        
        function open(brickIO)
            % Open the simBrickIO object
            %
            % opens the connection to the simulated brick
            % using fopen.

            % open the communicaions socket
            fopen(brickIO.handle);
            pause(1)
            
            % get the simulator version
            fprintf(brickIO.handle, 'GET version');
            pause(1);
            
            % Receive lines of data from server - just discard what is
            % received.
            while (get(brickIO.handle, 'BytesAvailable') > 0)
                brickIO.opened = true;
                brickIO.handle.BytesAvailable 
                fscanf(brickIO.handle); 
            end
        end

        function close(brickIO)
            % Close the simBrickIO object
            %
            % closes the bluetooth connection the brick using fclose.
            
            % send a quit message to the simulation server
            fprintf(brickIO.handle, 'SET end');
            pause(1);
            
            % close the handle
            fclose(brickIO.handle);
            delete(brickIO.handle);
            clear brickIO.handle;
        end
        
        function rmsg = read(brickIO)
            % Read data from the simBrickIO object
            %
            % rmsg = simBrickIO.read() reads data from the brick through
            % tcpip via fread and returns the data as an array of strings.
            
            % read the remaining bytes
            rmsg = fscanf(brickIO.handle);
        end
        
        function write(brickIO,wmsg)
            % Write data to the simBrickIO object
            %
            % writes data to the brick through tcpip.
            %
            % Notes::
            % - wmsg is the data to be written to the brick via bluetooth
            %   in uint8 format.
            fprintf(brickIO.handle,wmsg);
        end
    end 
end
