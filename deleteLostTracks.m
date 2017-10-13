function [tr,freePl,busyPl,pl] = deleteLostTracks(tracks,freePlaces,busyPlaces,places)
    if isempty(tracks)
        tr = tracks;
        freePl = freePlaces;
        busyPl = busyPlaces;
        pl = places;
        return;
    end

    invisibleForTooLong = 30; % soglia di invisibilit? massima
    ageThreshold = 18; % soglia di et? minima

    % calcolo della frazione di frame in cui la traccia ? stata visibile
    ages = [tracks(:).age];
    totalVisibleCounts = [tracks(:).totalVisibleCount];
    visibility = totalVisibleCounts ./ ages;

    % estrazione degli indici delle tracce da eliminare in quanto rumore o macchine ferme
    lostInds = (ages < ageThreshold & visibility < 0.6) | ...
        [tracks(:).consecutiveInvisibleCount] >= invisibleForTooLong;
    
    % estrazione degli indici delle tracce da eliminare in quanto macchine ferme
    lostVisTracks = [tracks(:).consecutiveInvisibleCount] >= invisibleForTooLong;

    % estrazione delle tracce da eliminare
    lostTracks = tracks(lostVisTracks);
    
    % analisi della storia della traccia, utilizzando le informazioni 
    % contenute nel vettore relativo al grado di overlapping della traccia,
    % al fine di capire se un posto occupato ? diventato libero
    for i = 1:length(lostTracks) 
         if (lostTracks(i).interestingCount == lostTracks(i).age) && ...
            (lostTracks(i).overlappingGrade(lostTracks(i).age) < 0.19)
            freePlaces = freePlaces + 1;
 
            % controllo che il posto non sia gi? presente nel vettore dei posti
            presenceIndex = isAlreadyKnown(lostTracks(i).parkLot,places);
            if(presenceIndex == 0) % se NON ? presente viene aggiungo al vettore
                newPlace = struct(...
                'bbox', lostTracks(i).parkLot, ...
                'isFree', 1);
                places(end + 1) = newPlace;
            else % se ? presente, se ne cambio lo stato, diminuendo il numero di posti occupati
                busyPlaces = busyPlaces - 1;
                places(presenceIndex).isFree = 1;
            end
         end
         if (lostTracks(i).interestingCount >0) && (lostTracks(i).overlappingGrade(lostTracks(i).age) > 0.75) ...
            && (lostTracks(i).overlappingGrade(1) < 0.75)
            % controllo che il posto non sia gi? presente nel vettore dei posti
            presenceIndex = isAlreadyKnown(lostTracks(i).bbox,places);
            
            if (presenceIndex == 0) || (places(presenceIndex).isFree==1)
                busyPlaces = busyPlaces + 1;

                if(presenceIndex == 0) % se NON ? presente viene aggiungo al vettore
                    newPlace = struct(...
                    'bbox', lostTracks(i).bbox, ...
                    'isFree', 0);
                    places(end + 1) = newPlace;
                else % se ? presente, se ne cambio lo stato, diminuendo il numero di posti liberi
                    freePlaces = freePlaces - 1;
                    places(presenceIndex).isFree = 0;
                end
            end
        end
    end
    
    % eliminazione delle tracce perdute
    tracks = tracks(~lostInds);
    
    tr = tracks;
    freePl = freePlaces;
    busyPl = busyPlaces;
    pl = places;
    
end