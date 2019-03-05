global key
InitKeyboard();

while 1
        pause(.1);
        switch key
            case 'uparrow'
                disp('Up pressed');
                
            case 'downarrow'
                disp('Down pressed');
                
            case 'leftarrow'
                disp('Left pressed');
                
            case 'rightarrow'
                disp('Right pressed');
                
            case 0
                disp('Nothing pressed');
                
            case 'q'
                break;
        end
end
CloseKeyboard();
                