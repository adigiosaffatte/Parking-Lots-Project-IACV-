function tr = updateAssignedTracks(tracks,assignments,centroids,bboxes,rect,scaleFactor)
    numAssignedTracks = size(assignments, 1); % numero di tracce assegnate
    for i = 1:numAssignedTracks
        trackIdx = assignments(i, 1); % estrazione dell'ID della traccia
        detectionIdx = assignments(i, 2); % estrazione dell'ID dell'oggetto
        centroid = centroids(detectionIdx, :); % estrazione del centroide dell'oggetto
        bbox = bboxes(detectionIdx, :); % estrazionde della bounding box dell'oggetto
        overlapGrade = overlappingGrade(bbox * scaleFactor,rect); % calcolo del grado di overlapping per l'oggetto
        if overlapGrade > 0
           edrfghydcfghjfgh=0;
        else
            d
        end
        
        % correzione della stima della posizione della traccia utilizzando
        % la nuova rilevazione
        correct(tracks(trackIdx).kalmanFilter, centroid);

        % sostituzione della bounding box predetta con quella
        % effettivamente trovata
        tracks(trackIdx).bbox = bbox;

        % aggiornamento dell'et� della traccia
        tracks(trackIdx).age = tracks(trackIdx).age + 1;

        % aggiornamento della visibilit� della traccia
        tracks(trackIdx).totalVisibleCount = ...
            tracks(trackIdx).totalVisibleCount + 1;
        tracks(trackIdx).consecutiveInvisibleCount = 0;
        
        % aggiornamento del vettore relativo al grado di overlapping della traccia
        tracks(trackIdx).overlappingGrade(tracks(trackIdx).age) = overlapGrade; 
        
        % aggiornamento del conteggio di "interesse" della traccia
        if (tracks(trackIdx).interestingCount > 0) || (overlapGrade > 0.65)
            tracks(trackIdx).interestingCount = ...
                tracks(trackIdx).interestingCount + 1;
        end
        
    end
    
    tr = tracks;
end