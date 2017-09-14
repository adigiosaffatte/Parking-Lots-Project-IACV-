function [assignments, unassignedTracks, unassignedDetections] = detectionToTrackAssignment(tracks,centroids)
    % ritorna gli assegnamenti effettuati (oggetto->traccia)
    % ritorna le tracce non assegnate a nessun oggetto
    % ritorna gli oggetti non assegnati a nessuna traccia

    nTracks = length(tracks); % numero totale di tracce
    nDetections = size(centroids, 1); % numero di oggetti rilevati nel frame corrente

    % calcolo del costo di assegnazione di ogni oggetto ad ogni traccia
    cost = zeros(nTracks, nDetections);
    for i = 1:nTracks
        cost(i, :) = distance(tracks(i).kalmanFilter, centroids);
    end
    
    costOfNonAssignment = 10; % costo del NON assegnare un oggetto ad una traccia
    
    % si risolve il problema di assegnamento oggetti a tracce minimizzando il costo totale
    [assignments, unassignedTracks, unassignedDetections] = ...
        assignDetectionsToTracks(cost, costOfNonAssignment);
end
