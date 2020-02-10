program PL2C;
var n, sum;

procedure result(n);
sum := sum + n;

procedure result;
write(sum);

begin
   n := 10;
   sum := 0;
   while n > 0 do
      begin      
	   result(n);
	   n := n - 1
      end;
   result
end.
