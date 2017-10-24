function [assignments, unassignedTracks, unassignedDetections] = detectionToTrackAssignment(tracks,centroids,bboxes)
    % ritorna gli assegnamenti effettuati (oggetto->traccia)
    % ritorna le tracce non assegnate a nessun oggetto
    % ritorna gli oggetti non assegnati a nessuna traccia

    nTracks = length(tracks); % numero totale di tracce
    nDetections = size(centroids, 1); % numero di oggetti rilevati nel frame corrente

    % calcolo del costo di assegnazione di ogni oggetto ad ogni traccia
    cost = zeros(nTracks, nDetections);
    
        for i = 1:nTracks
            if (~isempty(tracks(i).twoStepCentroid) && ~isempty(tracks(i).oneStepCentroid))
                predictedCentroid = [2*tracks(i).twoStepCentroid(1) - tracks(i).oneStepCentroid(1), ...
                                     2*tracks(i).twoStepCentroid(2) - tracks(i).oneStepCentroid(2)];
                cost(i, :) = distance(predictedCentroid, centroids);
            else
                predictedCentroid = tracks(i).kalmanFilter.State([1,3]);
                cost(i, :) = distance(predictedCentroid', centroids);
            end
        end
   
    %13
    costOfNonAssignment = 13; % costo del NON assegnare un oggetto ad una traccia
    
    % si risolve il problema di assegnamento oggetti a tracce minimizzando il costo totale
    [assignments, unassignedTracks, unassignedDetections] = ...
        assignDetectionsToTracks(cost, costOfNonAssignment);
end
