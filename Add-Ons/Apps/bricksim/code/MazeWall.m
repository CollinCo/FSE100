classdef MazeWall < handle
    %======================================================================
    % class MazeWall
    %======================================================================
    % This class provides an object representation for a wall within a 
    % maze cell.
    %
    % Class properties
    %    x1,y1 - the coordinate of one of the wall corners
    %    x2,y2 - the coordinate of the other wall corner
    %    lh    - a handle to the line graphics object that represents the
    %            wall on the map.
    %    type  - the type of wall (0=unknown, 1 = present, 2 = absent)
    %    f - a handle to the graphics figure onto which this wall will be
    %           drawn
    % 
    % Member Functions 
    %    MazeWall - Constructor - creates an instance of the MazeWall class
    %    setType  - set the type of the wall
    %    getType  - get the type of the wall
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
        lh;
        type;      % unknown = 0, present = 1, absent = 2
        f;
    end
    
    methods
        function mazewall = MazeWall(f, x1, y1, x2, y2)
            % Constructor - creates an instance of the MazeWall class
            % 
            % Notes::
            %    f - a handle for the figure window in which the wall will
            %        be drawn
            %    x1,y1 - the coordinate in the map coordinate system for
            %        the first corner of the wall.
            %    x2,y2 - the coordinate in the map coordinate system for
            %        the second corner of the wall.
            %
            % Example::
            %    w = MazeWall(f,0,0,0,24)
            if nargin == 0
                %mazewall.f = gcf;
                mazewall.x1 = 0;
                mazewall.y1 = 0;
                mazewall.x2 = 0;
                mazewall.y2 = 0;
                mazewall.type = 0;
                return;
            else
                mazewall.f = f;
                mazewall.x1 = x1;
                mazewall.y1 = y1;
                mazewall.x2 = x2;
                mazewall.y2 = y2;
                mazewall.type = 0;
            end
            
            if isa(mazewall.f, 'handle') && isvalid(mazewall.f) 
                figure(mazewall.f);
                mazewall.lh = line( [mazewall.x1 mazewall.x2] , [mazewall.y1 mazewall.y2] );
            end
            mazewall.setType(0);
        end
        
        function setType(mw, type)
            % Set the type of the wall
            %
            % Notes::
            %    type - the new type for the wall.
            %           unknown = 0, present = 1, absent = 2
            %
            % Example::
            %    w.setType(1)
            switch type
                case 0
                    % unknown
                    if isa(mw.lh, 'handle') && isvalid(mw.lh)
                        mw.lh.Color = 'black';
                        mw.lh.LineStyle = '--';
                        mw.lh.LineWidth = 0.5;
                    end
                    mw.type = type;
                case 1
                    % present
                    if isa(mw.lh, 'handle') && isvalid(mw.lh)
                        mw.lh.Color = 'black';
                        mw.lh.LineStyle = '-';
                        mw.lh.LineWidth = 2;
                    end
                    mw.type = type;
                case 2
                    % absent
                    if isa(mw.lh, 'handle') && isvalid(mw.lh)
                        mw.lh.Color = 'none';
                        mw.lh.LineStyle = '-';
                        mw.lh.LineWidth = 0.5;
                    end
                    mw.type = type;
            end
        end

        function type = getType(mw)
            % Get the type of the wall
            %
            % Notes::
            %    type - the type for the wall.
            %           unknown = 0, present = 1, absent = 2
            %
            % Example::
            %    type = w.getType()
            type = mw.type;
        end
    end     
end
