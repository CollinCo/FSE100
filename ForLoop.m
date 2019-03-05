for a = 0:10
     % oh look a comment
    fprintf('A = %i\n',a);
    a = a + 1;
    %{
        multiline comment
    %}
    if ( a == 10)
        fprintf('Last time thru loop');
    end
end