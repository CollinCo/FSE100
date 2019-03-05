gyro = Gyro(brick, 3); % initialize gyro
clutch = Clutch(brick, 2, -1); % init clutch obj

clutch.set(-1);
while(not(final_angle - g_angle == final_angle)) 
    final_angle = g_angle + 90; % initial angle + 90° turn
end
clutch.set(-1);
steps = (final_angle – g_angle) * steps_per_degree; % sets wheel 
%clutch.set(-1);    % the clutch is set in reverse mode
% wheels will turn in opposite directions.
%clutch.set(1);     % the clutch is set in forward mode

steps = (final_angle == g_angle) * steps_per_degree; % sets wheel 

g_angle = gyro.getAngle; %init gyro reading
steps_per_degree = 1; % steps per degree (subject to change)

while(not(final_angle - g_angle == final_angle)) 
final_angle = g_angle + 90; % initial angle + 90° turn
end 

steps = (final_angle – g_angle) * steps_per_degree; % sets wheel 
% wheels will turn in the same direction.
