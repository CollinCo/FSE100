function keyboardControl (brick, clutch)
%KEYBOARDCONTROL Robot keyboard control

    disp('keyboard control called');

    global key
    InitKeyboard();

    while 1
            pause(.1);
            switch key
                case 'uparrow'
                    clutch.set(1); % sets clutch to forward
                    brick.MoveMotorAngleRel('A', -50, 100, 'Brake');
                    disp('Up pressed');

                case 'downarrow'
                    clutch.set(1); % sets clutch to forward
                    brick.MoveMotorAngleRel('A', 50, 100, 'Brake');
                    disp('Down pressed');

                case 'leftarrow'
                    clutch.set(-1); % sets clutch to turn
                    brick.MoveMotorAngleRel('A', -50, 100, 'Brake');
                    disp('Left pressed');

                case 'rightarrow'
                    clutch.set(-1); % sets clutch to turn
                    brick.MoveMotorAngleRel('A', 50, 100, 'Brake');
                    disp('Right pressed');
                    
                case 'z'
                    brick.MoveMotorAngleRel('C', 50, 100, 'Brake');
                    disp('z pressed');
                    
                case 'x'
                    brick.MoveMotorAngleRel('C', -50, 100, 'Brake');
                    disp('z pressed');
                    

                case 0
                    disp('Nothing pressed');

                case 'q'
                    disp('keyboard break');
                    break;
            end
    end
    brick.StopAllMotors();
    CloseKeyboard();
                
end