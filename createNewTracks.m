function [tr, ni] = createNewTracks(tracks,unassignedDetections,centroids,bboxes,nextId,rect,scaleFactor,panic)
     if (panic == 0)  
        centroids = centroids(unassignedDetections, :); % estrazione dei centroidi relativi agli oggetti rilevati
        bboxes = bboxes(unassignedDetections, :); % estrazione delle bounding box relative agli oggetti rilevati

        for i = 1:size(centroids, 1)

            centroid = centroids(i,:);
            bbox = bboxes(i, :);

            % creazione di un oggetto "filtro di Kalman" per la predizione del centroide (posizione) della traccia
            kalmanFilter = configureKalmanFilter('ConstantVelocity', ...
                centroid, [200, 50], [100, 25], 100);

            % creazione della nuova traccia
            newTrack = struct(...
                'id', nextId, ...   % identificativo della traccia
                'bbox', bbox, ...   % rettangolo costruito attorno all'oggetto a cui è associata la traccia
                'kalmanFilter', kalmanFilter, ...   % filtro di Kalman per la predizione del centroide della bbox
                'oneStepCentroid', [], ...   % centroide di due frame precedenti
                'twoStepCentroid', centroid, ...   % centroide del frame precedente
                'overlappingGrade', zeros(1,1,'double'), ...   % grado di overlapping (passato e presente) tra la bbox e l'area del parcheggio 
                'interestingCount', 0, ...   % contatore del numero di frame in cui l'oggetto è stato "interessante"
                'parkLot', bbox, ...   % prima bbox rilevata dal Tracking
                'age', 1, ...   % età della traccia espressa in numero di frame
                'totalVisibleCount', 1, ...   % conteggio totale del numero di frame in cui l'oggetto è stato visibile
                'consecutiveInvisibleCount', 0);   % conteggio del numero di frame consecutivi in cui l'oggetto NON è stato visibile

            % aggiornamento del vettore relativo al grado di overlapping della traccia
            newTrack.overlappingGrade(newTrack.age) = overlappingGrade(bbox * scaleFactor,rect); 

            % aggioramento del conteggio di "interesse" della traccia
            if (newTrack.overlappingGrade(newTrack.age) > 0.65)
                newTrack.interestingCount = ...
                    newTrack.interestingCount + 1;
            end

            % aggiunta della nuova traccia al vettore di tracce
            tracks(end + 1) = newTrack;

            % aumento dell'ID per la prossima traccia
            nextId = nextId + 1;
        end

        tr = tracks;
        ni = nextId;
     else
         tr = tracks;
         ni = nextId;
     end
end