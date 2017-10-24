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
        
        noGapRadiusInside = 15;
        noGapRadiusOutside = 9;
       
        if (~isempty(tracks(ind).twoStepCentroid) && ~isempty(tracks(ind).oneStepCentroid))
            if (tracks(ind).overlappingGrade(end-2) >= 0.33)
                close = areClose(tracks(ind).twoStepCentroid,tracks(ind).oneStepCentroid,noGapRadiusInside);
                if (close == 1)
                    tracks(ind).oneStepCentroid = tracks(ind).twoStepCentroid;
                else
                    predictedCentroid = [2*tracks(ind).twoStepCentroid(1) - tracks(ind).oneStepCentroid(1), ...
                                         2*tracks(ind).twoStepCentroid(2) - tracks(ind).oneStepCentroid(2)];
                    tracks(ind).oneStepCentroid = tracks(ind).twoStepCentroid;
                    tracks(ind).twoStepCentroid = predictedCentroid;
                end
            else
                close = areClose(tracks(ind).twoStepCentroid,tracks(ind).oneStepCentroid,noGapRadiusOutside);
                if (close == 1)
                    tracks(ind).oneStepCentroid = tracks(ind).twoStepCentroid;
                else
                    predictedCentroid = [2*tracks(ind).twoStepCentroid(1) - tracks(ind).oneStepCentroid(1), ...
                                         2*tracks(ind).twoStepCentroid(2) - tracks(ind).oneStepCentroid(2)];
                    tracks(ind).oneStepCentroid = tracks(ind).twoStepCentroid;
                    tracks(ind).twoStepCentroid = predictedCentroid;
                end
            end
            
        else
            tracks(ind).oneStepCentroid = tracks(ind).twoStepCentroid;
            tracks(ind).twoStepCentroid = (tracks(ind).kalmanFilter.State([1,3]))';
        end
        
    end
    
    tr = tracks;
end