function tr = predictNewLocationsOfTracks(tracks)
        for i = 1:length(tracks)
            if (~isempty(tracks(i).twoStepCentroid) && ~isempty(tracks(i).oneStepCentroid))
                bbox = tracks(i).bbox;

                % predizione della posizione delle tracce (predizione del centroide)
                predictedCentroid = predict(tracks(i).kalmanFilter);
                predictedCentroid = [2*tracks(i).twoStepCentroid(1) - tracks(i).oneStepCentroid(1), ...
                                     2*tracks(i).twoStepCentroid(2) - tracks(i).oneStepCentroid(2)];

            else
                bbox = tracks(i).bbox;
                predictedCentroid = predict(tracks(i).kalmanFilter);
            end
            
            % shifting della bounding box della traccia al fine di avere
                % come nuovo centroide quello appena predetto
                predictedCentroid = int32(predictedCentroid) - bbox(3:4) / 2;
                tracks(i).bbox = [predictedCentroid, bbox(3:4)];
        end
        
        tr = tracks;
end