function tr = updateUnassignedTracks(tracks,unassignedTracks)
    for i = 1:length(unassignedTracks)
        ind = unassignedTracks(i); % estrazione dell'ID della traccia non assegnata
        tracks(ind).age = tracks(ind).age + 1; % aggiornamento dell'età della traccia
        tracks(ind).consecutiveInvisibleCount = tracks(ind).consecutiveInvisibleCount + 1; % aggiornamento del contatore di invisibiltà della traccia
        tracks(ind).overlappingGrade(tracks(ind).age) = tracks(ind).overlappingGrade(tracks(ind).age - 1); % aggiornamento del vettore relativo al grado di overlapping della traccia
        
        % aggiornamento del conteggio di "interesse" della traccia
        if (tracks(ind).interestingCount > 0)
            tracks(ind).interestingCount = tracks(ind).interestingCount + 1;
        end
    end
    
    tr = tracks;
end