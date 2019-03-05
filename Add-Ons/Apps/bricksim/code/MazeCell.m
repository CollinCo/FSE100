classdef MazeCell < handle
    %======================================================================
    % class MazeCell
    %======================================================================
    % This class provides an object representation for a single cell of the
    % robot maze.  A cell is a square region that may have walls at right 
    % angles on any of its sides. Cells may also have feasures on the floor
    % including stop strips, loading curbs and unloading curbs.
    %
    % The Maze Cell contains an array of four walls (N, S, E, W), four 
    % possible stop strips (N, S, E, W) and four possible loading/unloading
    % zones (N,S,E,W).  Maze cells are contained within a MazeMap object.
    %
    % Class Constants
    %    STOPWIDTH - the width of stop strips in inches
    %    ZONEWIDTH - the width of loading/unloading zones in inches
    %
    % Class properties
    %    size - the lengh of the side of the cell (in inches)          
    %    xpos - the x position of the left edge of the cell relative to the
    %           maze coordinate system (in inches)
    %    ypos - the y position of the upper edge of the cell relative to
    %           maze coordinate system (in inches)
    %    walls = the array of walls associated with this cell. 
    %           {1=North, 2=South, 3=East, 4=West)
    %    stops = the array of stop strip information for this cell.
    %           {1=North, 2=South, 3=East, 4=West)
    %    zones = the array of loading/unloading zones for this cell.
    %           {1=North, 2=South, 3=East, 4=West)
    %    f - a handle to the graphics figure onto which this cell will be
    %           drawn
    % 
    % Member Functions 
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
    properties (Constant = true)
        STOPWIDTH = 1.5;
        ZONEWIDTH = 7.5;
    end
    properties
        size;          
        xpos;
        ypos;
        walls = MazeWall();
        stops = MazeZone();
        zones = MazeZone();
        f;
    end
    
    methods
        function mazecell = MazeCell(f, x, y, cell_size)
            % Constructor for MazeCell class
            %
            if nargin == 0
                % defaults if no arguments are given
                mazecell.size = 24;
                mazecell.xpos = 0;
                mazecell.ypos = 0;
                return;
            else
                mazecell.f = f;
                mazecell.xpos = x;
                mazecell.ypos = y;
                mazecell.size = cell_size;
            end
          
            % create the zones
            % north wall
            x1 = mazecell.xpos;
            x2 = mazecell.xpos+mazecell.size;
            y1 = mazecell.ypos;
            y2 = mazecell.ypos-mazecell.ZONEWIDTH;
            mazecell.zones(1) = MazeZone(mazecell.f, x1, y1, x2, y2); 
            % south wall
            x1 = mazecell.xpos;
            x2 = mazecell.xpos + mazecell.size;
            y1 = mazecell.ypos - mazecell.size+mazecell.ZONEWIDTH;
            y2 = mazecell.ypos - mazecell.size;
            mazecell.zones(2) = MazeZone(mazecell.f, x1, y1, x2, y2);
            % east wall
            x1 = mazecell.xpos + mazecell.size - mazecell.ZONEWIDTH;
            x2 = mazecell.xpos + mazecell.size;
            y1 = mazecell.ypos;
            y2 = mazecell.ypos - mazecell.size;
            mazecell.zones(3) = MazeZone(mazecell.f, x1, y1, x2, y2);
            % west wall
            x1 = mazecell.xpos;
            x2 = mazecell.xpos + mazecell.ZONEWIDTH;
            y1 = mazecell.ypos;
            y2 = mazecell.ypos - mazecell.size;
            mazecell.zones(4) = MazeZone(mazecell.f, x1, y1, x2, y2);

            % create the stops
            % north wall
            x1 = mazecell.xpos;
            x2 = mazecell.xpos+mazecell.size;
            y1 = mazecell.ypos+mazecell.STOPWIDTH/2;
            y2 = mazecell.ypos-mazecell.STOPWIDTH/2;
            mazecell.stops(1) = MazeZone(mazecell.f, x1, y1, x2, y2); 
            % south wall
            x1 = mazecell.xpos;
            x2 = mazecell.xpos + mazecell.size;
            y1 = mazecell.ypos - mazecell.size+mazecell.STOPWIDTH/2;
            y2 = mazecell.ypos - mazecell.size-mazecell.STOPWIDTH/2;
            mazecell.stops(2) = MazeZone(mazecell.f, x1, y1, x2, y2);
            % east wall
            x1 = mazecell.xpos + mazecell.size - mazecell.STOPWIDTH/2;
            x2 = mazecell.xpos + mazecell.size + mazecell.STOPWIDTH/2;
            y1 = mazecell.ypos;
            y2 = mazecell.ypos - mazecell.size;
            mazecell.stops(3) = MazeZone(mazecell.f, x1, y1, x2, y2);
            % west wall
            x1 = mazecell.xpos - mazecell.STOPWIDTH/2;
            x2 = mazecell.xpos + mazecell.STOPWIDTH/2;
            y1 = mazecell.ypos;
            y2 = mazecell.ypos - mazecell.size;
            mazecell.stops(4) = MazeZone(mazecell.f, x1, y1, x2, y2);

            % create the walls
            % north wall
            x1 = mazecell.xpos;
            x2 = mazecell.xpos+mazecell.size;
            y1 = mazecell.ypos;
            y2 = mazecell.ypos;
            mazecell.walls(1) = MazeWall(mazecell.f, x1, y1, x2, y2); 
            % south wall
            x1 = mazecell.xpos;
            x2 = mazecell.xpos + mazecell.size;
            y1 = mazecell.ypos - mazecell.size;
            y2 = mazecell.ypos - mazecell.size;
            mazecell.walls(2) = MazeWall(mazecell.f, x1, y1, x2, y2);
            % east wall
            x1 = mazecell.xpos + mazecell.size;
            x2 = mazecell.xpos + mazecell.size;
            y1 = mazecell.ypos;
            y2 = mazecell.ypos - mazecell.size;
            mazecell.walls(3) = MazeWall(mazecell.f, x1, y1, x2, y2);
            % west wall
            x1 = mazecell.xpos;
            x2 = mazecell.xpos;
            y1 = mazecell.ypos;
            y2 = mazecell.ypos - mazecell.size;
            mazecell.walls(4) = MazeWall(mazecell.f, x1, y1, x2, y2);
        end
        
        function setZoneType(mc, loc, type)
            % set the corresponding zone type to the specified value
            %
            % loc - is the location of the zone within the cell
            %     (1=N,2=S,3=E,4=W)
            % type - the type of zone
            %     (0=unknown, 1=regular floor, 2=pickup, 3=dropoff, 4=stop)
            switch type
                case 0
                    mc.zones(loc).setType(type)
                case 1
                    mc.zones(loc).setType(type)
                case 2
                    for i=1:4
                        mc.zones(i).setType(1)
                    end
                    mc.zones(loc).setType(type)
                case 3
                    for i=1:4
                        mc.zones(i).setType(1)
                    end
                    mc.zones(loc).setType(type)
            end          
        end
        
        function setStopType(mc, loc, type)
            % set the corresponding stop type to the specified value
            %
            % loc - is the location of the stop zone within the cell
            %     (1=N,2=S,3=E,4=W)
            % type - the type of zone
            %     (0=unknown, 1=regular floor, 2=pickup, 3=dropoff, 4=stop)
            mc.stops(loc).setType(type)
        end

        function setWallType(mc, loc, type)
            % set the corresponding wall type to the specified value
            %
            % loc - is the location of the wall within the cell
            %     (1=N,2=S,3=E,4=W)
            % type - the type of zone
            %     (0=unknown, 1=wall present, 2=wall not present)
            mc.walls(loc).setType(type)
        end
        
        function type = getZoneType(mc, loc)
            % returns the zone type for the specified zone within the cell
            %
            % loc - is the location of the zone within the cell
            %     (1=N,2=S,3=E,4=W)
            % type - the type of zone
            %     (0=unknown, 1=regular floor, 2=pickup, 3=dropoff, 4=stop)
            type = mc.zones(loc).getType();
        end
        
        function type = getStopType(mc, loc)
            % returns the stop type for the specified zone within the cell
            %
            % loc - is the location of the zone within the cell
            %     (1=N,2=S,3=E,4=W)
            % type - the type of zone
            %     (0=unknown, 1=regular floor, 2=pickup, 3=dropoff, 4=stop)
            type = mc.stops(loc).getType();
        end

        function type = getWallType(mc, loc)
            % returns the wall type for the specified wall within the cell
            %
            % loc - is the location of the wall within the cell
            %     (1=N,2=S,3=E,4=W)
            % type - the type of zone
            %     (0=unknown, 1=wall present, 2=wall not present)
            type = mc.walls(loc).getType();
        end
    end     
end
