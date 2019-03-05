n = input('enter # of rows ');
for row = 1:n
    for spaces = 1:n - row
        fprintf(' ');
    end
    for stars = 1:row
        fprintf('* ');
    end
    fprintf('\n');
end

        