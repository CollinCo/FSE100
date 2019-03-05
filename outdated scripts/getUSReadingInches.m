function [ultra] = getUSReadingInches(brick,usPort)
%Returns output of ultrasonic sensor
    %   Input is brick object & Ultrasonic port 
    %   Output is rounded
    %ultra = brick.UltrasonicDist(usport);
    ultra = 0;
    ultraArray = [0 0 0 0 0 0 0 0 0];
    % Take 9 readings from Ultrasonic sensor
    for a = 1:10    
        %ultraArray(a) = a;
        ultraArray(a) =round(brick.UltrasonicDist(4));
        %pause(1);
        fprintf('A = %i\n',ultraArray(a));
    end
    
    % bubble Sorts readings from ultrasonic sensor
    temp = 0;
    for a = 1:9
        for b = a + 1:10
          if(ultraArray(a) > ultraArray(b))
              temp = ultraArray(a);
              ultraArray(a) = ultraArray(b);
              ultraArray(b) = temp;
          end
        end
    end
    
    for a = 1:10    
        %ultraArray(a) = a;
        %pause(1);
        fprintf('Sorted %i = %i\n',a, ultraArray(a));
    end
    
    ultra = round(ultraArray(5)/2.54);
    round(ultra);
    fprintf('Arr(5) from cent to inches %i\n',ultra);
end
