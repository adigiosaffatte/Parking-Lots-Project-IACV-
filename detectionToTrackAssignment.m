function [assignments, unassignedTracks, unassignedDetections] = detectionToTrackAssignment(tracks,centroids,bboxes)
    % ritorna gli assegnamenti effettuati (oggetto->traccia)
    % ritorna le tracce non assegnate a nessun oggetto
    % ritorna gli oggetti non assegnati a nessuna traccia

    nTracks = length(tracks); % numero totale di tracce
    nDetections = size(centroids, 1); % numero di oggetti rilevati nel frame corrente

    % calcolo del costo di assegnazione di ogni oggetto ad ogni traccia
    cost = zeros(nTracks, nDetections);
    if nDetections>0
        for i = 1:nTracks
            trackCentroid =  predict(tracks(i).kalmanFilter);
            overlap = zeros(nDetections,1);
            for j = 1:nDetections
               overlap(j) = max(...
                                overlappingGradeOLD(tracks(i).bbox,bboxes(j,:)),...
                                overlappingGradeOLD(bboxes(j,:),tracks(i).bbox));
            end
            cost(i, :) = distance(trackCentroid, centroids) - overlap*10;
        end
    end
    costOfNonAssignment = 13; % costo del NON assegnare un oggetto ad una traccia
    
    % si risolve il problema di assegnamento oggetti a tracce minimizzando il costo totale
    [assignments, unassignedTracks, unassignedDetections] = ...
        assignDetectionsToTracks(cost, costOfNonAssignment);
end
