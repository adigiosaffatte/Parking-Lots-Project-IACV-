
function overlapGrade = overlappingGrade(rectOverlap,rectBase)
% restituisce il grado (in percentuale) di overlapping del primo rettangolo
% "rectOverlap" con il secondo "rectBase".

topLeftCornerOverlap = [rectOverlap(1), rectOverlap(2)];
topRightCornerOverlap = [rectOverlap(1) + rectOverlap(3), rectOverlap(2)];
bottomLeftCornerOverlap = [rectOverlap(1), rectOverlap(2) + rectOverlap(4)];
bottomRightCornerOverlap = [rectOverlap(1) + rectOverlap(3), rectOverlap(2) + rectOverlap(4)];

topLeftCornerBase = [rectBase(1), rectBase(2)];
topRightCornerBase = [rectBase(1) + rectBase(3), rectBase(2)];
bottomLeftCornerBase = [rectBase(1), rectBase(2) + rectBase(4)];
bottomRightCornerBase = [rectBase(1) + rectBase(3), rectBase(2) + rectBase(4)];

if (topLeftCornerOverlap(1) >= topRightCornerBase(1)) || ...
        (topRightCornerOverlap(1) <= topLeftCornerBase(1)) || ...
        (topLeftCornerOverlap(2) >= bottomRightCornerBase(2)) || ...
        (bottomLeftCornerOverlap(2) <= topLeftCornerBase(2))
    
    overlapGrade = 0.0;
    
else
    
    voidArea = 0;
    firstRoundSuccess = false;
    pivot = bottomLeftCornerOverlap;
    follower = topLeftCornerOverlap;
    
    if follower(1) < topLeftCornerBase(1)
        voidArea = voidArea + (pivot(2) - follower(2)) * (topLeftCornerBase(1) - follower(1));
        pivot = [topLeftCornerBase(1),follower(2)];
        firstRoundSuccess = true;
    else
        pivot = follower;
    end
    
    follower = topRightCornerOverlap;
    
    if follower(2) < topLeftCornerBase(2)
        voidArea = voidArea + (follower(1) - pivot(1)) * (topLeftCornerBase(2) - follower(2));
        pivot = [follower(1),topLeftCornerBase(2)];
    else
        pivot = follower;
    end
    
    follower = bottomRightCornerOverlap;
    
    if follower(1) > topRightCornerBase(1)
        voidArea = voidArea + (follower(2) - pivot(2)) * (follower(1) - topRightCornerBase(1));
        pivot = [topRightCornerBase(1),follower(2)];
    else
        pivot = follower;
    end
    
    follower = bottomLeftCornerOverlap;
    
    if follower(2) > bottomRightCornerBase(2)
        if firstRoundSuccess
            voidArea = voidArea + (pivot(1) - bottomLeftCornerBase(1)) * (follower(2) - bottomRightCornerBase(2));
        else
            voidArea = voidArea + (pivot(1) - follower(1)) * (follower(2) - bottomRightCornerBase(2));
        end
    end
    
    totalArea = rectOverlap(3) * rectOverlap(4);
    overlapGrade = 1 - (double(voidArea) / double(totalArea));
    
end

end