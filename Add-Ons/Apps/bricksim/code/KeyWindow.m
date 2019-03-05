classdef KeyWindow < handle
    %======================================================================
    % class KeyWindow
    %======================================================================
    % This class provides a figure window that accepts key presses from the
    % user.  When the window is active, the key being pressed can be accessed
    % through member data 'key'.
    %
    % Class properties
    %   key - a charcter value of the last key that was pressed in the
    %         user enter window.
    %   h - a handle to the figure that accepts user key entry
    %
    % Member Functions 
    %   KeyWindow() - the constructor for the KeyWindow class.  Use this 
    %         function to create a new key window object.
    %   delete() - delete the KeyWindow function and the associated user
    %         entry window.  This function will only be called when both 
    %         the user entry window and the KeyWindow object have gone out
    %         of scope.  Users should not need to call this function.
    %   close() - Close the user entry window associated with a particular
    %         instance of the KeyWindow class.  This function should always
    %         be called by the user before a KeyWindow object goes out of
    %         scope, otherwise, the associated user entry window will 
    %         remain on the screen.
    %   updateKey() - a callback function that is automatically called
    %         whenever a user types a key in the user entry window.  Users
    %         should not need to call this function directly.
    %   clearKey() - a callback function that is automatically called
    %         whenever a user releases a key in the user entry window.  
    %         Users should not need to call this function directly.
    %
    %======================================================================
    % Example:
    %======================================================================
    %    % initialize the KeyWindow and open the figure
    %    k = KeyWindow()
    %
    %    % Loop to do something based on key presses
    %    while true
    %       switch k.key
    %          case 'q'
    %             % break out of the loop
    %             break;
    %          % other keys ...
    %       end
    %    end
    %    % close the keypress window
    %    k.close()
    %
    %======================================================================
    % Revision History 
    %======================================================================
    % Version 1.0 20171027 - Beta Release - Doug Sandy
    %     Note: this version of the KeyWindow was based off of a set of
    %     non-class functions for key control created for ASU by an unknown
    %     author.  Updates were made in order to encapsulate all the
    %     functions into one class structure.
    %
    %======================================================================
    % Copyright Notice 
    %======================================================================
    % COPYRIGHT (C) 2017, 
    % ARIZONA STATE UNIVERSITY
    % ALL RIGHTS RESERVED
    %
    
    properties
        key;    % the key that has been pressed 
        h;      % a handle to the figure window
    end
    
    methods
        function kw = KeyWindow()
            %--------------------------------------------------------------
            % Construct an instance of this class
            kw.key = 0;
            text(1) = {'Click on this window and press any key to control your robot.'};
            text(2) = {'The key currently being pressed is in the "key" member property.'};
            kw.h = figure;
            set(kw.h, 'KeyPressFcn',@kw.updateKey);
            set(kw.h, 'KeyReleaseFcn',@kw.clearKey);
            textbox = annotation(kw.h, 'textbox',[0,0,1,1]);
            set(textbox,'String', text);
        end
        
        function delete(kw)
            %--------------------------------------------------------------
            % Delete the class object and its associated figure window.
            % This function is automatically called by matlab when both the
            % KeyWindow and its associated figure go out of scope.  This
            % function should not be called directly by user code.
            if isa(kw.h,'handle') && isvalid(kw.h)
                close(kw.h);
            end
        end

        function close(kw)
            %--------------------------------------------------------------
            % close the Figure window associated with a specific instance
            % of the KeyWindow class.  user code should call this before
            % the KeyWindow object goes out of scope in order to guarantee
            % that the associated window gets closed.
            if isa(kw.h,'handle') && isvalid(kw.h)
                close(kw.h);
            end
        end

        
        function updateKey(kw, src, evt)
            %--------------------------------------------------------------
            % Callback function. This function is called whenever a user
            % presses a key when the KeyWindow Figure has the input focus.
            kw.key = evt.Key;
        end
        
        function clearKey(kw, src, evt)
            %--------------------------------------------------------------
            % Callback function. This function is called whenever a user
            % releases a key when the KeyWindow Figure has the input focus.
            kw.key = 0;
        end
    end
end

