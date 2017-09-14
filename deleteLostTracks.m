function [tr,freePl,busyPl,pl] = deleteLostTracks(tracks,freePlaces,busyPlaces,places)
    if isempty(tracks)
        tr = tracks;
        freePl = freePlaces;
        busyPl = busyPlaces;
        pl = places;
        return;
    end

    invisibleForTooLong = 20; % soglia di invisibilità massima
    ageThreshold = 8; % soglia di età minima

    % calcolo della frazione di frame in cui la traccia è stata visibile
    ages = [tracks(:).age];
    totalVisibleCounts = [tracks(:).totalVisibleCount];
    visibility = totalVisibleCounts ./ ages;

    % estrazione degli indici delle tracce da eliminare
    lostInds = (ages < ageThreshold & visibility < 0.6) | ...
        [tracks(:).consecutiveInvisibleCount] >= invisibleForTooLong;

    % estrazione delle tracce da eliminare
    lostTracks = tracks(lostInds);
    
    % analisi della storia della traccia, utilizzando le informazioni 
    % contenute nel vettore relativo al grado di overlapping della traccia,
    % al fine di capire se un posto occupato è diventato libero
    for i = 1:length(lostTracks) 
        if (lostTracks(i).interestingCount == lostTracks(i).age) && (lostTracks(i).overlappingGrade(lostTracks(i).age) < 0.15)
            freePlaces = freePlaces + 1;
 
            % controllo che il posto non sia già presente nel vettore dei posti
            presenceIndex = isAlreadyKnown(lostTracks(i).parkLot,places);
            if(presenceIndex == 0) % se NON è presente viene aggiungo al vettore
                newPlace = struct(...
                'bbox', lostTracks(i).parkLot, ...
                'isFree', 1);
                places(end + 1) = newPlace;
            else % se è presente, se ne cambio lo stato, diminuendo il numero di posti occupati
                busyPlaces = busyPlaces - 1;
                places(presenceIndex).isFree = 1;
            end
        end
        
        %TODO: POSTI CHE DA LIBERI DIVENTANO OCCUPATI
    end
            
    % eliminazione delle tracce perdute
    tracks = tracks(~lostInds);
    
    tr = tracks;
    freePl = freePlaces;
    busyPl = busyPlaces;
    pl = places;
    
end