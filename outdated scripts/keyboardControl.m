function keyboardControl (brick, gyro)
%KEYBOARDCONTROL Robot keyboard control

    disp('keyboard control called');

    global key
    InitKeyboard();

    while 1
            pause(.1);
            switch key
                case 'uparrow'
                    clutch.set(1); % sets clutch to forward
                    brick.MoveMotorAngleRel('A', 50, 3, 'Brake');
                    disp('Up pressed');

                case 'downarrow'
                    clutch.set(1); % sets clutch to forward
                    brick.MoveMotorAngleRel('A', -50, 3, 'Brake');
                    disp('Down pressed');

                case 'leftarrow'
                    clutch.set(-1); % sets clutch to turn
                    brick.MoveMotorAngleRel('A', 50, 3, 'Brake');
                    disp('Left pressed');

                case 'rightarrow'
                    clutch.set(-1); % sets clutch to turn
                    brick.MoveMotorAngleRel('A', -50, 3, 'Brake');
                    disp('Right pressed');

                case 0
                    disp('Nothing pressed');

                case 'q'
                    disp('keyboard break');
                    break;
            end
    end
    CloseKeyboard();
                
end

