classdef MazeZone < handle
    %======================================================================
    % class MazeZone
    %======================================================================
    % This class provides an object representation for a wall within a 
    % maze cell.
    %
    % Class properties
    %    x1,y1 - the coordinate of one of the zone's corners
    %    x2,y2 - the coordinate of the opposite of the zone's corners
    %    rh    - a handle to the rectangle graphics object that represents 
    %            the zone on the map.
    %    type  - the type of zone 
    %            (0=unknown, 1 = normal, 2 = pickup, 3 = dropoff, 4 = stop)
    %    f - a handle to the graphics figure onto which the zonew will be
    %           drawn
    % 
    % Member Functions 
    %    MazeZone - Constructor - creates an instance of the MazeZone class
    %    setType  - set the type of the zone
    %    getType  - get the type of the zone
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
    properties
        x1;          
        y1;
        x2;
        y2;
        rh;
        type;      % unknown = 0, normal = 1, pickup=2, dropoff=3, stop=4
        f;
    end
    
    methods
        function mazezone = MazeZone(f, x1, y1, x2, y2)
            % Constructor - creates an instance of the MazeZone class
            %
            % Notes::
            %    f - a handle for the figure window in which the zone will
            %        be drawn
            %    x1,y1 - the coordinate in the map coordinate system for
            %        the first corner of the zone.
            %    x2,y2 - the coordinate in the map coordinate system for
            %        the opposite corner of the zone.
            %
            % Example::
            %    z = MazeZone(f,0, -24, 24, -16.5)
            if nargin == 0
                mazezone.x1 = 0;
                mazezone.y1 = 0;
                mazezone.x2 = 0;
                mazezone.y2 = 0;
                mazezone.type = 0;
                return;
            else
                mazezone.f = f;
                mazezone.x1 = x1;
                mazezone.y1 = y1;
                mazezone.x2 = x2;
                mazezone.y2 = y2;
                mazezone.type = 0;
            end
            
            if isa(mazezone.f, 'handle') &&isvalid(mazezone.f)
                figure(mazezone.f);
                mazezone.rh = rectangle( 'Position', ...
                    [mazezone.x1 mazezone.y2 mazezone.x2-mazezone.x1 mazezone.y1-mazezone.y2] );
            end
            mazezone.setType(0);
        end
        
        function setType(mz, type)
            % set the type of the zone
            %
            % Notes::
            %    type - the new type for the zone.
            %           unknown = 0, normal = 1, pickup=2, dropoff=3, 
            %           stop=4
            %
            % Example::
            %    z.setType(1)
            switch type
                case 0
                    % unknown
                    if isa(mz.rh, 'handle') && isvalid(mz.rh)
                        mz.rh.FaceColor = [.85,.85,.85];
                        mz.rh.EdgeColor = 'none';
                    end
                    mz.type = type;
                case 1
                    % normal
                    if isa(mz.rh, 'handle') && isvalid(mz.rh)
                        mz.rh.FaceColor = 'none';
                        mz.rh.EdgeColor = 'none';
                    end
                    mz.type = type;
                case 2
                    % pickup (yellow curb)
                    if isa(mz.rh, 'handle') && isvalid(mz.rh)
                        mz.rh.FaceColor = 'yellow';
                        mz.rh.EdgeColor = 'none';
                    end
                    mz.type = type;
                case 3
                    % dropoff (green curb)
                    if isa(mz.rh, 'handle') && isvalid(mz.rh)
                        mz.rh.FaceColor = 'green';
                        mz.rh.EdgeColor = 'none';
                    end
                    mz.type = type;
                case 4
                    % stop (red)
                    if isa(mz.rh, 'handle') && isvalid(mz.rh)
                        mz.rh.FaceColor = 'red';
                        mz.rh.EdgeColor = 'none';
                    end
                    mz.type = type;
            end
        end

        function type = getType(mz)
            % get the type of the zone
            %
            % Notes::
            %    type - the type for the zone.
            %           unknown = 0, normal = 1, pickup=2, dropoff=3, 
            %           stop=4
            %
            % Example::
            %    type = z.getType()
            type = mz.type;
        end
    end     
end
