function [Cake] = cake(min_dist)

   cake_size = 2*min_dist + 1;
   Cake = zeros(cake_size);
   
   ii = abs(floor((1:cake_size) - cake_size/2));
   Cake2 = hypot(ii',ii);
   
   for i = 1:cake_size
       for j = 1:cake_size
           if (Cake2(i,j) > min_dist)
               Cake(i,j) = 1;
           end
       end
   end
   
   Cake = logical(Cake);
   
end

