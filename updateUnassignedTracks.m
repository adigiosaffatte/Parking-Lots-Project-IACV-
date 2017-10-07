function tr = updateUnassignedTracks(tracks,unassignedTracks)
    for i = 1:length(unassignedTracks)
        ind = unassignedTracks(i); % estrazione dell'ID della traccia non assegnata
        tracks(ind).age = tracks(ind).age + 1; % aggiornamento dell'et? della traccia
        tracks(ind).consecutiveInvisibleCount = tracks(ind).consecutiveInvisibleCount + 1; % aggiornamento del contatore di invisibilt? della traccia
        tracks(ind).overlappingGrade(tracks(ind).age) = tracks(ind).overlappingGrade(tracks(ind).age - 1); % aggiornamento del vettore relativo al grado di overlapping della traccia
        
        % aggiornamento del conteggio di "interesse" della traccia
        if (tracks(ind).interestingCount > 0)
            tracks(ind).interestingCount = tracks(ind).interestingCount + 1;
        end
        
        %Se sono sui bordi cancello la traks
        if (tracks(ind).bbox(1)<=5 || tracks(ind).bbox(2)<=5 ||...
            tracks(ind).bbox(1)+tracks(ind).bbox(3)>=380 || ...
            tracks(ind).bbox(2)+tracks(ind).bbox(4)>=282)
                tracks(ind).consecutiveInvisibleCount = 500;
        end
    end
    
    tr = tracks;
end