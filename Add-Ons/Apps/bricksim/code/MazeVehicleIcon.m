classdef MazeVehicleIcon < handle
    %======================================================================
    % class MazeVehicleIcon
    %======================================================================
    % This class provides behavior for a vehicle icon to be drawn on the 
    % map of the robotic maze.  The icon is implemented using a patch
    % graphics object and is represented by a "pointy rectangle" with the
    % point facing in the forward direction of the vehicle.
    %
    % Class properties
    %    x1,y1 - the map coordinate on which the origin of the vehicle icon
    %            is placed.
    %    direction - the angular direction that the vehicle icon faces
    %    ph    - a handle to the patch object of the vehicle icon
    %    f     - a handle to the maze map window on which the icon is drawn
    %    config - configuration information for the vehicle that the patch
    %            represents
    %    patch_x,patch_y - matrices for the patch vertices
    % 
    % Member Functions 
    %    MazeVehicleIcon - constructor for the class.  Creates an instance
    %            of the class.
    %    draw - draw the icon at the current coordinate and direction
    %    setPosition - sets the position of the icon relative to the map
    %            coordinate system.
    %    setDirection - sets the angular direction that the icon faces
    %    delete - deletes the icon.  Called automatically when the obecect
    %            is cleared from memory.
    %
    % Helper Functions::
    %    patch_translate - translate the patch coordinates to a new 
    %        positionthe.
    %    patch_rotate - rotates the patch coordinates to the direction 
    %        specified
    %======================================================================
    % Revision History 
    %======================================================================
    % Version 1.1 20171105 - typecast inputs to patch_translate to double
    %                  in order to avoid rounding errors when integers are 
    %                  passed as parameters.
    % Version 1.0 20171028 - Beta Release - Doug Sandy
    %
    %======================================================================
    % Copyright Notice 
    %======================================================================
    % COPYRIGHT (C) 2017, 
    % ARIZONA STATE UNIVERSITY
    % ALL RIGHTS RESERVED
    %
    properties
        x1;          
        y1;
        direction;
        ph;
        f;
        config;
        patch_y;
        patch_x;
    end
    
    methods
        function v = MazeVehicleIcon(f, x1, y1, direction, config)
            % Constructor.  Creates an instance of the class.
            %
            % Notes::
            %     f     - a handle to the window in which the icon will be
            %             drawn
            %     x1,y1 - the position relative to the map coordinate
            %             system at which the icon will be located.
            %     direction - the direction that the icon will face.
            %     config - information about the vehicle configuration.
            %
            % Examples::
            %   v = MazeVehicleIcon();
            %   v = MazeVehicleIcon(f, 12, -12, 270, config)
            if nargin == 0
                v.x1 = 0;
                v.y1 = 0;
                v.direction = 0;
                config.front = 1.0;
                config.back = -4.0;
                config.left = 3.0;
                config.right = -3.0;
                return;
            else
                v.f = f;
                v.x1 = x1;
                v.y1 = y1;
                v.direction = direction;
                v.config = config;
            end
            
            % create the patch verticies to match the vehicle size
            v.patch_x = [config.back, (config.back+3*config.front)/4, ...
                config.front, (config.back+3*config.front)/4, ...
                config.back, config.back];
            v.patch_y = [config.right, config.right, ...
                (config.right+config.left)/2, config.left, ...
                config.left, config.right];
            
            % draw the icon
            v.draw();
        end
        
        function draw(v)
            % draw the icon at the current coordinate and direction
            %
            % Example::
            %    v.draw()
            if isa(v.f,'handle') && isvalid(v.f) 
                %figure(v.f);
                
                if ~isa(v.ph,'handle') || ~isvalid(v.ph) 
                    % if the patch has never been created, make the patch
                    figure(v.f);
                    [x,y] = patch_rotate(v.patch_x,v.patch_y,v.direction);
                    [x,y] = patch_translate(x,y,v.x1,v.y1);
                    v.ph = patch( x, y, 'blue');
                else
                    % if the patch already exists, just update its points
                    [x,y] = patch_rotate(v.patch_x,v.patch_y,v.direction);
                    [x,y] = patch_translate(x,y,v.x1,v.y1);
                    set(v.ph,{'XData','YData'},{x, y});
                end
            end
        end

        function setPosition(v, x1, y1)
            % sets the position of the icon relative to the map
            % coordinate system.
            %
            % Notes::
            %    x1,y1 - coordinate at which to place the icon relative to
            %       the map coordinate system.
            %
            % Example::
            %    v.setPosition(50,-40)
            v.x1 = x1;
            v.y1 = y1;
            v.draw();
        end

        function setDirection(v, direction)
            % sets the angular direction that the icon faces
            %
            % Notes::
            %    direction - angle to set the vehicle direction to face
            %
            % Example::
            %    v.setDirection(270)
            v.direction = direction;
            v.draw();
        end
    
        function delete(v)
            % deletes the icon.  Called automatically when the obecect
            % is cleared from memory.
            if isa(v.f,'handle') && isvalid(v.f) 
                figure(v.f);

                if isa(v.ph,'handle') && isvalid(v.ph) 
                    delete(v.ph);
                end
            end
        end
    end     
end

function [xn, yn] = patch_translate(x,y, ox, oy)
    % translate the patch coordinates to the new origin specified
    xn = double(x)+double(ox);
    yn = double(y)+double(oy);
end

function [xn, yn] = patch_rotate(x,y, angle)
    % rotate the patch coordinates to face the direction specified
    xn = x * cos(angle*pi/180.0) - y * sin(angle*pi/180.0);
    yn = x * sin(angle*pi/180.0) + y * cos(angle*pi/180.0);
end
