function tracks = initializeTracks()
    % creazione di un array vuoto di tracce
    tracks = struct(...
        'id', {}, ...   % identificativo della traccia
        'bbox', {}, ...   % rettangolo costruito attorno all'oggetto a cui è associata la traccia
        'kalmanFilter', {}, ...   % filtro di Kalman per la predizione del centroide della bbox
        'overlappingGrade', {}, ...   % grado di overlapping (passato e presente) tra la bbox e l'area del parcheggio 
        'interestingCount', {}, ...   % contatore del numero di frame in cui l'oggetto è stato "interessante"
        'parkLot', {}, ...   % prima bbox rilevata dal Tracking
        'age', {}, ...   % età della traccia espressa in numero di frame
        'totalVisibleCount', {}, ...   % conteggio totale del numero di frame in cui l'oggetto è stato visibile
        'consecutiveInvisibleCount', {});   % conteggio del numero di frame consecutivi in cui l'oggetto NON è stato visibile
end