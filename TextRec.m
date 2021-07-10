% This function recognizes the number of the 
% ruler in the pictures and outputs this information in meters

function [End_Scale] = TextRec(imagesAll,N)

% Crop image and binarize
for i = 1:N
    I = imagesAll{i};
    Cropped_image_TextRec = imcrop(I,[1300 1045 400 15]);
    R = rgb2gray(Cropped_image_TextRec);
    Icorrected = imtophat(R,strel('disk',15));
    I = imbinarize(Icorrected);

    % Text recognition for every single image
    results = ocr(I);
    word = string(results.Words);
    
    % Separate the recognized according to string and integer
    expression1 = '\d+';
    matchInt = regexp(word,expression1,'match');
    % identify the empty cells and delete
    empties = find(cellfun(@isempty,matchInt)); 
    matchInt(empties) = [];
    scale = str2double(matchInt);  
    expression2 = '[^-0-9\/]+';
    matchStr = regexp(word,expression2,'match');
    empties = find(cellfun(@isempty,matchStr)); 
    matchStr(empties) = []; 
    unit = matchStr;
   
    
    % Store strings and integers 
    units{i} = unit;
    scales{i} = scale;
end

     
    % check if cells are still valid otherwise correct
     if class(matchInt) == "cell" 
         matchInt = matchInt{1,1};
         matchInt = str2double(matchInt);
         for i = 1:N
         scale = matchInt;
         scales{i} = scale;
         end
     end   
     if class(matchStr) == "cell" 
         matchStr = matchStr{1,1};
         for i = 1:N
         unit = matchStr;
         units{i} = unit;
         end
     end

   % delete empty cells
   scales(cellfun(@(cell) any(isnan(cell(:))),scales))={''};
   scales2 = scales(~cellfun('isempty', scales'));


 

 % This part takes exactly what occurs the most in the cell with the
 % integer
 setMatch  = @(s,c) struct('int', s, 'count', c) ;
 match     = setMatch('', 0) ;
 hashtable = java.util.Hashtable() ;
 for k = 1 : length(scales2)
     if isempty(scales2{k}), continue ;  end
     if hashtable.containsKey(scales2{k})
         count = hashtable.get(scales2{k}) ;
         if count >= match.count,  match = setMatch(scales2{k}, count+1) ;  end
         hashtable.put(scales2{k}, count+1) ; 
     else
         if match.count == 0,  match = setMatch(scales2{k}, 1) ;  end
         hashtable.put(scales2{k}, 1) ; 
     end
 end

 
 z = struct2cell(match(1));
 End_Scale = cell2mat(z(1));
 
units2 = units(cellfun('isclass', units', "string")) ;

 % This part takes exactly what occurs the most in the cell with the
 % string
 setMatch2  = @(s,c) struct('string', s, 'count', c) ;
 match2     = setMatch2('', 0) ;
 hashtable2 = java.util.Hashtable() ;
 for k = 1 : length(units2)
     if isempty(units2{k}), continue ;  end
     if hashtable2.containsKey(units2{k})
         count = hashtable2.get(units2{k}) ;
         if count >= match2.count,  match2 = setMatch2(units2{k}, count+1) ;  end
         hashtable2.put(units2{k}, count+1) ; 
     else
         if match2.count == 0,  match2 = setMatch2(units2{k}, 1) ;  end
         hashtable2.put(units2{k}, 1) ; 
     end
 end

 w = struct2cell(match2(1));
 End_unit = string(w(1));

% check if unit is "km"
pat = "km";
TF = contains(End_unit,pat);
% convert in meter
if TF 
End_Scale = End_Scale*1000;
end
end



