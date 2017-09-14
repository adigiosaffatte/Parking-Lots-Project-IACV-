clear all;
clc;
close all;

% caricamento del video (31814 frames) avente dimensioni 384 (larghezza) x 288 (altezza)
videoSource = vision.VideoFileReader('appa_park.wmv','ImageColorSpace','Intensity','VideoOutputDataType','uint8');

firstFrame = step(videoSource); % estrazione di un frame dal video
frameSize = size(firstFrame); % dimensioni del frame (altezza x larghezza)

textPosition = [85 8]; % posizione in cui piazzare il testo
firstTextedFrame = insertText(firstFrame,textPosition,'Selezionare la zona da monitorare', ...
'Font','Calibri','FontSize',15,'TextColor','w','BoxOpacity',0); % aggiunta del testo al frame

scaleFactor = 3; % fattore di scala per ingrandire il frame
firstTextedFrame = imresize(firstTextedFrame, scaleFactor); % ingrandimento del frame
figure(); % creazione di una figura per visualizzare il frame
set(gcf,'numbertitle','off','name','Parking Lots Project'); % titolo della figura
imshow(firstTextedFrame); % visualizzazione del frame

rect = getrect(); % estrazione tramite input utente dell'area rettangolare da monitorare
rect = adjust(rect,frameSize,scaleFactor); % regolarizzazione rettangoli anomali
rectArea = rect(3) * rect(4); % calcolo dell'area del rettangolo

minimumArea = 7500; % area minima monitorabile
minimumSize = 60; % altezza/larghezza minima monitorabile 
invalidRectTextPosition = [65 8]; % posizione in cui piazzare il testo
while (rectArea < minimumArea) || (rect(3) < minimumSize) || (rect(4) < minimumSize)
    
    invalidRectTextedFrame = insertText(firstFrame,invalidRectTextPosition,'Area selezionata troppo piccola: riprovare', ...
    'Font','Calibri','FontSize',15,'TextColor','w','BoxOpacity',0); % aggiunta del testo al frame
    invalidRectTextedFrame = imresize(invalidRectTextedFrame, scaleFactor); % ingrandimento del frame
    imshow(invalidRectTextedFrame); % visualizzazione del frame
    
    rect = getrect(); % estrazione tramite input utente dell'area rettangolare da monitorare
    rect = adjust(rect,frameSize,scaleFactor); % regolarizzazione rettangoli anomali
    rectArea = rect(3) * rect(4); % calcolo dell'area del rettangolo
    
end

% oggetto responsabile della Background Subtraction con GMM
foregroundDetector = vision.ForegroundDetector('NumGaussians', 5, 'NumTrainingFrames', ...
                     30, 'MinimumBackgroundRatio', 0.7, 'LearningRate',0.005);

% oggetto responsabile dell'analisi dei pixel rilevati come foreground
blobAnalyser = vision.BlobAnalysis('BoundingBoxOutputPort', true, 'AreaOutputPort', true, ...
               'CentroidOutputPort', true, 'MinimumBlobArea', minimumArea * 0.1);

% inizializzazione delle tracce per il Tracking
tracks = initializeTracks();     

nextId = 1; % ID della "prossima" track
freePlaces = 0; % contatore dei posti liberi
busyPlaces = 0; % contatotre dei posti occupati
places = initializePlaces(); % inizializzazione della struttura relativa alle posizioni dei posti
frameCount = 0; % contatore del numero di frame

while ~isDone(videoSource)
    
    nextFrame = step(videoSource); % estrazione di un frame dal video

    % riconoscimento degli oggetti in movimento tramite Background Subtraction (GMM)
    [centroids, bboxes, mask] = detectObjects(nextFrame,foregroundDetector,blobAnalyser);
    
    % predizione della nuova posizione delle tracce
    tracks = predictNewLocationsOfTracks(tracks);
    
    % assegnamento degli oggetti rilevati alle tracce
    [assignments, unassignedTracks, unassignedDetections] = detectionToTrackAssignment(tracks,centroids);
    
    % aggiornamento delle tracce assegnate 
    tracks = updateAssignedTracks(tracks,assignments,centroids,bboxes,rect,scaleFactor);
    % aggiornamento delle tracce NON assegnate
    tracks = updateUnassignedTracks(tracks,unassignedTracks);
    % eliminazione delle tracce perdute
    [tracks,freePlaces,busyPlaces,places] = deleteLostTracks(tracks,freePlaces,busyPlaces,places);
    % creazione delle tracce nuove
    [tracks, nextId] = createNewTracks(tracks,unassignedDetections,centroids,bboxes,nextId,rect,scaleFactor);
    
    minVisibleCount = 8; % valore minimo di visibilità affinchè una traccia venga considerata affidabile
    if ~isempty(tracks)
        reliableTrackInds = [tracks(:).totalVisibleCount] > minVisibleCount; % estrazione degli indici delle tracce affidabili
        reliableTracks = tracks(reliableTrackInds); % estrazione delle tracce affidabili
        if ~isempty(reliableTracks)
            bboxes = cat(1, reliableTracks.bbox); % estrazione delle bounding boxes associate alle tracce affidabili
        end
    end
    
    nextFrame = insertShape(nextFrame,'rectangle',bboxes); % inserimento rettangoli attorno alle tracce affidabili
    placesTextPosition = [30 8]; % posizione del testo indicante il numero di parcheggi liberi/occupati
    nextFrame = insertText(nextFrame,placesTextPosition,sprintf('Posti liberi: %d           Posti occupati: %d          Frame: %d',freePlaces,busyPlaces,frameCount), ...
    'Font','Calibri','FontSize',15,'TextColor','w','BoxOpacity',0); % aggiunta del testo al frame
    nextFrame = imresize(nextFrame, scaleFactor); % ingrandimento del frame
    nextFrame = insertShape(nextFrame,'FilledRectangle',rect,'Color','yellow','Opacity',0.1); % evidenziamento area da monitorare
    freeCircles = circlesFromFreePlaces(places,scaleFactor); % ottenimento dei centroidi relativi ai posti liberi
    nextFrame = insertShape(nextFrame,'FilledCircle',freeCircles,'Color','green'); % inserimento di cerchietti verdi in corrispondenza dei posti liberi
    
    % TODO: STESSA COSA PER I POSTI OCCUPATI (evidenziati però in rosso)
    %busyCircles = circlesFromBusyPlaces(places,scaleFactor);
    %nextFrame = insertShape(nextFrame,'FilledCircle',busyCircles,'Color','red');
    
    imshow(nextFrame); % visualizzazione del frame
    frameCount = frameCount + 1; % aumento del contatore di frame
end

release(videoSource); % rilascio dell'oggetto video