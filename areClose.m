function close = areClose(firstCentroid, secondCentroid, radius)

    x1 = firstCentroid(1);
    y1 = firstCentroid(2);
    
    x2 = secondCentroid(1);
    y2 = secondCentroid(2);

    if ( abs(x1 - x2) <= radius && abs(y1 - y2) <= radius)
        close = 1;
    else
        close = 0;
    end
end