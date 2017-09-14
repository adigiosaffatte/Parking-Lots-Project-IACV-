function index = isAlreadyKnown(parkLot,places)
    % ritorna 1 se un posto, identificato da una bounding box, è già
    % presente nel vettore dei posti, altrimenti 0

    maxOverlap = 0;
    
    for i = 1:length(places)
        overlap = overlappingGrade(parkLot,places(i).bbox);
        if(overlap > maxOverlap)
            maxOverlap = overlap;
            index = i;
        end
    end
    
    if(maxOverlap < 0.65)
        index = 0;
    end
end