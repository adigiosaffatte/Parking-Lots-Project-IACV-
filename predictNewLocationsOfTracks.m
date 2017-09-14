function tr = predictNewLocationsOfTracks(tracks)
        for i = 1:length(tracks)
            bbox = tracks(i).bbox;

            % predizione della posizione delle tracce (predizione del centroide)
            predictedCentroid = predict(tracks(i).kalmanFilter);

            % shifting della bounding box della traccia al fine di avere
            % come nuovo centroide quello appena predetto
            predictedCentroid = int32(predictedCentroid) - bbox(3:4) / 2;
            tracks(i).bbox = [predictedCentroid, bbox(3:4)];
        end
        
        tr = tracks;
end