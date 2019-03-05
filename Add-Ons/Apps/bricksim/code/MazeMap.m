classdef MazeMap < handle
    %======================================================================
    % class MazeMap
    %======================================================================
    % This class provides an object representation for a map of the robotic
    % maze.  The map consists of:
    % 1. a collection of equal-sized cells, each of which can contain 
    %    pickup/dropoff zones, stop strips, and walls
    % 2. A figure onto which the maze will be drawn
    % 3. A handle for a simple icon representing the vehicle
    % 4. Handles to a text log and status area on the map display
    %
    % Class properties
    %    width - the width of the maze (number of cells wide)
    %    height - the height of the maze (number of cells long)
    %    cell_size - the lenght of one edge of a cell measured in inches
    %    f    -  A handle to the figure window for this map
    %    tbox_log - a handle to the scrollable log window on the map 
    %            display
    %    tbox_state - A handle to the text area for vehicle status 
    %            information
    %    cell_array - the array of cells for the map
    %    veh -   a handle for the vehicle icon
    % 
    % Member Functions 
    %    MazeMap - a constructor for the class
    %    getFigure - returns the handle for the figure in which the maze is
    %            drawn.
    %    makeFigure - create the maze figure window with its map, status
    %            and log areas.
    %    geCellZoneType - for a given cell, returns the type of the
    %            specified zone.
    %    getCellWallType - for a given cell, returns the type of the
    %            specified wall.
    %    getCellStopType - for a given cell, returns the type of the
    %            specified stop.
    %    setCellZoneType - for a given cell, set the type of the
    %            specified zone.
    %    setCellStopType - for a given cell, set the type of the
    %            specified stop.
    %    locfrompos - for a specified x,y coordinate given in inches,
    %            return the cell index (x,y) for cell in which the point
    %            lies.
    %    getCellWallType - for a given cell, returns the type of the
    %            specified wall.
    %    setVehiclePosition - place the vehicle icon on the map at the
    %            coordinate specified (in inches)
    %    setVehicleDirection - Orient the vehicle icon in the specified
    %            direction (degrees).
    %    getClosestWallDistance - Determine the range and angle to the
    %            closest wall from the vector that begins at a specified 
    %            point and proceeds in a specific direction.
    %    doesLineSegmentIntersectWall - determine if a line segment
    %            specified by the given points intersects with any walls in
    %            the maze.
    %    updateLog - update the log text on the maze display window
    %    updateVehicleStateText - update the vehicle state text on the maze
    %            display window.
    %    init - init the maze structure from the specified file.
    %    delete - This function is automatically called when the MazeMap is
    %            cleared from memory.
    %
    % NOTE on Maze Coordinate System:
    %    Maze cell (1,1) corresponds to the top left cell in the maze.  The
    %    upper left corner of this cell is located at (0,0) inches.  As
    %    the x index for the maze cell increases, the x coordinate
    %    increases.  As the y index of the maze cell increases, however,
    %    the y coordinate decreases.
    %======================================================================
    % Revision History 
    %======================================================================
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
        width;          % the width of the map mesured in MapCells
        height;         % the height of the map measured in Map Cells
        cell_size;      % the cell size measured in inches
        f;              % a handle to the plot object related to this map
        tbox_log        % a handle to the log textbox within the map display
        tbox_state      % a handle to the state textbox
        cell_array = MazeCell();     % the array of cells for this map
        veh        = MazeVehicleIcon();
    end
    
    methods
        function mazemap = MazeMap(height, width, cell_size)
            % constructor for the MazeMap object.  This function creates 
            % the internal structure of the maze with a given height, width
            % and cell size, and displays the map in a new figure window.
            %
            % Notes::
            %   height - the maze length, measured in cells
            %   width  - the maze width, measured in cells
            %   cell_size - the size of a cell's side, measured in inches 
            %
            % Examples::
            %   m = MazeMap()
            %   m = MazeMap(6,3,24)
            if nargin == 0
                mazemap.height = 16;
                mazemap.width = 8;
                mazemap.cell_size = 12;
                return;
            else
                mazemap.height = height;
                mazemap.width = width;
                mazemap.cell_size = cell_size;
            end
            
            mazemap.makeFigure();
            
            % create the cell array
            for w = 1:mazemap.width
                for h = 1:mazemap.height
                    mazemap.cell_array(w,h) = MazeCell(mazemap.f, ...
                        (w-1)*mazemap.cell_size, ...
                        0 - (h-1)*mazemap.cell_size, mazemap.cell_size);
                end
            end
        end

        function fh = getFigure(m)
            % returns a handle to the figure on which the maze map is drawn
            %
            % Notes::
            %    fh - the figure handle for the window in which the maze is
            %         drawn.
            %
            % Example::
            %    fh = m.getFigure()
            fh = m.f;
        end
        
        function makeFigure(m)
            % creates the figure window on which the maze map will be
            % drawn.  The maze will be drawn on the left half of the figure
            % window while the status and log will be displayed on the
            % right half of the window.
            %
            % Notes::
            %   This function takes no input parameters and returs not
            %   results.  If successful, the figure handle for the MazeMap 
            %   object will be updated to point to a new figure window.
            %
            % Example::
            %   m.makeFigure()
            if isa(m.f, 'handle') && isvalid(m.f)
                % clear the contents of the current map figure
                clf(m.f);
                figure(m.f);
            else
                % create a new figure associated with this map
                m.f = figure('DockControls','off','Menubar','none',...
                    'Toolbar','none','Name','Maze Simulator Map',...
                    'NumberTitle','off');
            end
            
            % create the plot for the map - this will fill the left half of
            % the window and resize automatically with the window size.
            subplot('position', [.01 .01 .48 .98])
            axis equal
            axis off            
            
            % create the controls for the vehicle status and the scrolling
            % log text.
            m.tbox_log = uicontrol('style','edit',...
                 'units','normalized','position',[.51 .01 .48 .66],...
                 'HorizontalAlign','left',...
                 'min',0,'max',100,'enable','inactive');
            m.tbox_state = uicontrol('style','text',...
                 'units','normalized','position',[.51 .68 .48 .31],...
                 'HorizontalAlign','left',...
                 'enable','inactive');
        end

        function type = getCellZoneType(m, x, y, loc)
            % return the type of a specific cell zone
            %
            % Notes::
            %    (x,y) the x and y indices of the cell to be evaluated
            %    loc - the location of the zone within the cell
            %        (1=north, 2=south, 3=east, 4=west)
            %    type - the type of the specified zone
            %        (0=unknown, 1=normal, 2=pickup, 3=dropoff, 4=stop)
            %
            % Example::
            %    type = m.getCellZoneType(1,1,1)
            type = m.cell_array(x,y).getZoneType(loc);
        end
        
        function type = getCellWallType(m, x, y, loc)
            % return the type of a specific cell wall
            %
            % Notes::
            %    (x,y) the x and y indices of the cell to be evaluated
            %    loc - the location of the zone within the cell
            %        (1=north, 2=south, 3=east, 4=west)
            %    type - the type of the specified wall
            %        (0=unknown, 1=normal, 2=no wall)
            %
            % Example::
            %    type = m.getCellWallType(1,1,1)
            type = m.cell_array(x,y).getWallType(loc);
        end
        
        function type = getCellStopType(m, x, y, loc)
            % return the type of a specific cell stop zone
            %
            % Notes::
            %    (x,y) the x and y indices of the cell to be evaluated
            %    loc - the location of the zone within the cell
            %        (1=north, 2=south, 3=east, 4=west)
            %    type - the type of the specified zone
            %        (0=unknown, 1=normal, 2=pickup, 3=dropoff, 4=stop)
            %
            % Example::
            %    type = m.getCellStopType(1,1,1)
            type = m.cell_array(x,y).getStopType(loc);
        end
        
        function setCellZoneType(mm, xc, yc, loc, type)
            % set the type of a specific cell zone
            %
            % Notes::
            %    (x,y) the x and y indices of the cell to be evaluated
            %    loc - the location of the zone within the cell
            %        (1=north, 2=south, 3=east, 4=west)
            %    type - the type of the specified zone
            %        (0=unknown, 1=normal, 2=pickup, 3=dropoff, 4=stop)
            %
            % Example::
            %    m.getCellZoneType(1,1,1,1)
            mm.cell_array(xc,yc).setZoneType(loc, type)
        end
        
        function setCellStopType(mm, xc, yc, loc, type)
            % set the type of a specific cell stop zone
            %
            % Notes::
            %    (x,y) the x and y indices of the cell to be evaluated
            %    loc - the location of the zone within the cell
            %        (1=north, 2=south, 3=east, 4=west)
            %    type - the type of the specified zone
            %        (0=unknown, 1=normal, 2=pickup, 3=dropoff, 4=stop)
            %
            % Example::
            %    m.setCellStopType(1,1,1,4)
            mm.cell_array(xc,yc).setStopType(loc, type)
            switch loc 
                case 1 % north wall
                    if yc>1
                        % set the stop in the adjacent cell to the same
                        % type
                        mm.cell_array(xc,yc-1).setStopType(2, type)
                    end
                case 2 % south wall
                    if yc<mm.height
                        % set the wall in the adjacent cell to the same
                        % type
                        mm.cell_array(xc,yc+1).setStopType(1, type)
                    end
                case 3 % east wall
                    if xc<mm.width
                        % set the wall in the adjacent cell to the same
                        % type
                        mm.cell_array(xc+1,yc).setStopType(4, type)
                    end
                case 4 % west wall
                    if xc>1
                        % set the wall in the adjacent cell to the same
                        % type
                        mm.cell_array(xc-1,yc).setStopType(3, type)
                    end
            end
        end
        
        function [mx, my] = locfrompos(m,x,y)
            % return the index for the cell that contains the specified
            % point.
            %
            % Notes::
            %    (x,y) - the point to evaluate (coordinates given in
            %            inches)
            %    (mx,my) - the x,y index of the maze cell that contains the
            %            given point.
            %
            % Example::
            %    [xi,yi] = m.locfrompos(45,-40)
            mx = floor(x / m.cell_size)+ 1;
            my = -1*ceil(y / m.cell_size)+ 1;
        end

        function setCellWallType(mm, xc, yc, loc, type)
            % set the type of a specific cell wall
            %
            % Notes::
            %    (x,y) the x and y indices of the cell to be evaluated
            %    loc - the location of the zone within the cell
            %        (1=north, 2=south, 3=east, 4=west)
            %    type - the type of the specified wall
            %        (0=unknown, 1=normal, 2=no wall)
            %
            % Example::
            %    m.setCellWallType(1,1,1,2)
            mm.cell_array(xc,yc).setWallType(loc, type)
            switch loc 
                case 1 % north wall
                    if type == 1
                        % the current cell cant have loading/unloading zones
                        % on the north side of the cell
                        mm.cell_array(xc,yc).setZoneType(1, 1)
                        
                        % the current cell also cant have a stop along the
                        % wall
                        mm.cell_array(xc,yc).setStopType(1,1);
                    end
                    
                    if yc>1
                        % set the wall in the adjacent cell to the same
                        % type
                        mm.cell_array(xc,yc-1).setWallType(2, type)

                        if type == 1
                            % the adjacnt cell cant have loading/unloading zones
                            % on the south side of the cell
                            mm.cell_array(xc,yc-1).setZoneType(2, 1)

                            % the adjacent cell also cant have a stop along the
                            % wall
                            mm.cell_array(xc,yc-1).setStopType(2,1);
                        end
                    end
                case 2 % south wall
                    if type == 1
                        % the current cell cant have loading/unloading zones
                        % on the south sides of the cell
                        mm.cell_array(xc,yc).setZoneType(2, 1)

                        % the current cell also cant have a stop along the
                        % wall
                        mm.cell_array(xc,yc).setStopType(2,1);
                    end
                    
                    if yc<mm.height
                        % set the wall in the adjacent cell to the same
                        % type
                        mm.cell_array(xc,yc+1).setWallType(1, type)

                        if type == 1
                            % the adjacnt cell cant have loading/unloading zones
                            % on the north sides of the cell
                            mm.cell_array(xc,yc+1).setZoneType(1, 1)

                            % the adjacent cell also cant have a stop along the
                            % wall
                            mm.cell_array(xc,yc+1).setStopType(1,1);
                        end
                    end
                case 3 % east wall
                    if type == 1
                        % the current cell cant have loading/unloading zones
                        % on the east sides of the cell
                        mm.cell_array(xc,yc).setZoneType(3, 1)

                        % the current cell also cant have a stop along the
                        % wall
                        mm.cell_array(xc,yc).setStopType(3,1);
                    end
                    
                    if xc<mm.width
                        if type == 1
                            % the ajacent cell cant have loading/unloading zones
                            % on the west sides of the cell
                            mm.cell_array(xc+1,yc).setZoneType(4, 1)

                            % the ajacent cell also cant have a stop along the
                            % wall
                            mm.cell_array(xc+1,yc).setStopType(4,1);
                        end
                        
                        % set the wall in the adjacent cell to the same
                        % type
                        mm.cell_array(xc+1,yc).setWallType(4, type)
                    end
                case 4 % west wall
                    if type == 1
                        % the current cell cant have loading/unloading zones
                        % on the west sides of the cell
                        mm.cell_array(xc,yc).setZoneType(4, 1)
                        
                        % the current cell also cant have a stop along the
                        % wall
                        mm.cell_array(xc,yc).setStopType(4,1);
                    end
                    
                    if xc>1
                        % the adjacent cell cant have loading/unloading zones
                        % on the east sides of the cell
                        if type == 1
                            mm.cell_array(xc-1,yc).setZoneType(3, 1)
                            
                            % the current cell also cant have a stop along the
                            % wall
                            mm.cell_array(xc-1,yc).setStopType(3,1);
                        end
                        
                        % set the wall in the adjacent cell to the same
                        % type
                        mm.cell_array(xc-1,yc).setWallType(3, type)
                    end
            end                
        end
        
        function setVehiclePosition(m, x1, y1)
            % set the vehicle icon to a specified coordinate within the
            % maze.
            %
            % Note::
            %    (x,y) the coordinate at which to place the vehicle icon
            %
            % Example::
            %    m.setVehiclePosition(10,-12)
            m.veh.setPosition(x1,y1);
        end

        function setVehicleDirection(m, direction)
            % set the direction of the vehicle icon to specified angle
            %
            % Note::
            %    direction - the angular direction that the vehicle icon 
            %        should be oriented to.
            %
            % Example::
            %    m.setVehicleDirection(270)
            m.veh.setDirection(direction);
        end 
        
        function [distance, angle] = getClosestWallDistance(m, x, y, dir)
            %==============================================================
            % determine the range and angle to the closest wall from the
            % vector that begins at x,y in the angular direction dir.
            %
            % this algorithm is brute force, checking each wall in the maze
            % sequentially.  The vector length is chosen to be long enough
            % to traverse the entire maze.
            %
            % Notes::
            % x,y - the starting point of the vector in map coordinate
            %       inches
            % dir - the direction of the vector
            % distance - the distance to the wall from x,y in CENTIMETERS
            % angle - the angle between the vector direction and the wall
            %       in degrees.  This will always be between 0 and 90.  0
            %       degrees corresponds to the vector being tangent to the
            %       surface of the wall.  90 corresponds to the vector being
            %       perpendicular to the surface of the wall.
            %
            % Example::
            %    [d,a] = m.getClosestWallDistance(50,-47,275)
            CM_PER_INCH = 2.54;
            distance = 255;
            angle = 0;
            for cx = 1:m.width
                for cy = 1:m.height
                    for wall = 1:4
                        if m.getCellWallType(cx,cy,wall) == 1
                            switch wall
                                case 1 % north
                                    xw1 = (cx-1)*m.cell_size;
                                    xw2 = (cx-0)*m.cell_size;
                                    yw1 = -1*(cy-1)*m.cell_size;
                                    yw2 = -1*(cy-1)*m.cell_size;                                  
                                case 2 % south
                                    xw1 = (cx-1)*m.cell_size;
                                    xw2 = (cx-0)*m.cell_size;
                                    yw1 = -1*(cy-0)*m.cell_size;
                                    yw2 = -1*(cy-0)*m.cell_size;
                                case 3 % east
                                    xw1 = (cx-0)*m.cell_size;
                                    xw2 = (cx-0)*m.cell_size;
                                    yw1 = -1*(cy-1)*m.cell_size;
                                    yw2 = -1*(cy-0)*m.cell_size;
                                case 4 % west
                                    xw1 = (cx-1)*m.cell_size;
                                    xw2 = (cx-1)*m.cell_size;
                                    yw1 = -1*(cy-1)*m.cell_size;
                                    yw2 = -1*(cy-0)*m.cell_size;
                            end
                            out = lineSegmentIntersect([xw1 yw1 xw2 yw2], ...
                                [x y (x+(1000*cos(dir*pi()/180))) (y+(1000*sin(dir*pi()/180)))]);
                            if out.intAdjacencyMatrix == 1
                                d = CM_PER_INCH*sqrt(power(out.intMatrixX-x,2) + power(out.intMatrixY-y,2));
                                if (d<distance) 
                                    distance = d;
                                    angle_wall = 360*atan2(yw1-yw2,xw1-xw2)/(2*pi());
                                    angle = angle_wall - dir;
                                end
                            end
                        end
                    end
                end
            end
            % fix the angle result 
            angle = mod(angle,180.0);
            if angle>90
                angle = 180-angle;
            end
        end
        
        function result = doesLineSegmentIntersectWall(m, x1,y1, x2,y2)
            % determine if the points given intersect any walls within the 
            % maze.
            
            result = false;
            % if any point lies outside the maze, return true
            if (x1<=0) || (x1>=m.width*m.cell_size) || ...
               (x2<=0) || (x2>=m.width*m.cell_size) || ...
               (y1>=0) || (y1<=-1*m.height*m.cell_size) || ...
               (y2>=0) || (y2<=-1*m.height*m.cell_size) 
                result = true;
                return
            end
            
            % determine which cells the points are in
            [cx1,cy1] = m.locfrompos(x1,y1);
            [cx2,cy2] = m.locfrompos(x2,y2);
            
            % if both points are int he same cell, return false since they
            % cannot intersect a wall.
            if (cx1==cx2) && (cy1==cy2)
                return;
            end
            
            % if the points lie in different rows of the maze, determine if
            % the line segment intercepts a horizontal wall
            if cx2<cx1
                % two cells are aligned diagonally with c1 on the right
                xwall = (cx1-1)*m.cell_size;
                % calculate the position at which the line segment
                % crosses xwall using y = (x-x1)*(y2-y1)/(x2-x1) + y1
                ywall = (xwall - x1)*(y2-y1)/(x2-x1) + y1;
                [cxwall, cywall] = m.locfrompos(x1,ywall);
                if m.getCellWallType(cxwall,cywall,4) == 1
                    result = true;
                end
                return;
            elseif cx2==cx1
                % two cells are aligned vertically - determine if there
                % is a wall between them
                if (cy1<cy2) 
                    if m.getCellWallType(cx1,cy1,2) == 1
                        result = true;
                    end
                    return;
                elseif (cy1>cy2)
                    if m.getCellWallType(cx1,cy1,1) == 1
                        result = true;
                    end
                    return;
                end
            else
                % two cells are aligned diagonally with c1 on the left
                xwall = (cx1)*m.cell_size;
                % calculate the position at which the line segment
                % crosses xwall using y = (x-x1)*(y2-y1)/(x2-x1) + y1
                ywall = (xwall - x1)*(y2-y1)/(x2-x1) + y1;
                [cxwall, cywall] = m.locfrompos(x1,ywall);
                if m.getCellWallType(cxwall,cywall,3) == 1
                    result = true;
                end
                return;
            end
        end
        
        function updateLog(m,log)
            if ishandle(m.tbox_log) && isvalid(m.tbox_log)
                set(m.tbox_log,'String',[log]);
            end
        end
        
        function updateVehicleStateText(m,txt)
            if ishandle(m.tbox_state) && isvalid(m.tbox_state)
                set(m.tbox_state,'String',[txt]);
            end
        end
        
        function init(m, filename)
            % initialize the maze structure from an excel file. For each 
            % cell in the file, read the wall, stop and zone info
            % into a matrix.  
            %
            % Notes::
            %    filename - the filename for  the file to be used.
            %
            % Example::
            %    m.init('mazemaker3x5.xlsx');
            
            a = xlsread(filename);
            
            m.height = a(1,3);
            m.width = a(1,4);
            m.cell_size = a(1,5);
            m.makeFigure();
            
            % create the cell array
            m.cell_array = MazeCell();
            for w = 1:m.width
                for h = 1:m.height
                    m.cell_array(w,h) = MazeCell(m.f, (w-1)*m.cell_size, 0 - (h-1)*m.cell_size, m.cell_size);
                end
            end
            for r = 1:size(a,1)
                h = a(r,1);
                w = a(r,2);
                % walls north, south, east, west
                m.setCellWallType(w,h,1,a(r,6));
                m.setCellWallType(w,h,2,a(r,7));
                m.setCellWallType(w,h,3,a(r,8));
                m.setCellWallType(w,h,4,a(r,9));
                % stops north, south, east, west
                m.setCellStopType(w,h,1,a(r,10));
                m.setCellStopType(w,h,2,a(r,11));
                m.setCellStopType(w,h,3,a(r,12));
                m.setCellStopType(w,h,4,a(r,13));
                % zones north, south, east, west
                m.setCellZoneType(w,h,1,a(r,14));
                m.setCellZoneType(w,h,2,a(r,15));
                m.setCellZoneType(w,h,3,a(r,16));
                m.setCellZoneType(w,h,4,a(r,17));
            end
        end
        
        function delete(mazemap)
            % close the figure associated with this maze map. User code
            % should not need to call this function.
            if isa(mazemap.f, 'handle') && isvalid(mazemap.f)
                close(mazemap.f);
            end
        end
    end     
end

