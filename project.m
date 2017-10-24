clear;
clc;
close all;

%% INIT

w = warning ('off','all');
% caricamento del video (30060 frames) avente dimensioni 384 (larghezza) x 288 (altezza)
videoSource = vision.VideoFileReader('appa_park.mp4','ImageColorSpace','Intensity','VideoOutputDataType','uint8');
indexGood = [1:300,1430:1870,5400:5700,6400:6800,9600:9950,15400:15990,17060:17480,24960:25500,27490:27850,29400:30060]; % Frame interessanti
         
 % 500:1200 Trim
 % 100:800 TrimTrim
 % 1:300,1430:1870,5400:5700,6400:6800,9600:9950,17060:17480,24960:25600,27490:27850,29400:30060
             
 
jump = 1; %Flag che indica se saltare ai flag interessanti

firstFrame = step(videoSource); % estrazione di un frame dal video
frameSize = size(firstFrame); % dimensioni del frame (altezza x larghezza)

textPosition = [85 8]; % posizione in cui piazzare il testo
firstTextedFrame = insertText(firstFrame,textPosition,'Selezionare la zona da monitorare', ...
'FontSize',13,'TextColor','w','BoxOpacity',0); % aggiunta del testo al frame

scaleFactor = 3; % fattore di scala per ingrandire il frame
firstTextedFrame = imresize(firstTextedFrame, scaleFactor); % ingrandimento del frame
figure(1); % creazione di una figura per visualizzare il frame
set(gcf,'numbertitle','off','name','Parking Lots Project','Visible','off'); % titolo della figura
imshow(firstTextedFrame); % visualizzazione del frame

%% SELECT RECTANGLE TO MONITOR



% park area params
minimumArea = 665;
minimumSize = 60;
maximumArea = 3100; % area massima monitorabile
initXsize = 200;
initYsize = 50;
invalidRectTextPosition = [65 8]; % posizione in cui piazzare il testo

parkShape = impoly(gca,[frameSize(2)/2-initXsize,frameSize(1)/2-initYsize; ... 
                        frameSize(2)/2-initXsize,frameSize(1)/2+initYsize; ...
                        frameSize(2)/2+initXsize,frameSize(1)/2+initYsize; ...
                        frameSize(2)/2+initXsize,frameSize(1)/2-initYsize;]);
api = iptgetapi(parkShape);
fcn = makeConstrainToRectFcn('impoly',get(gca,'XLim'),get(gca,'YLim'));
api.setPositionConstraintFcn(fcn);
api.setColor('yellow');
parkShape.wait;

props = regionprops(parkShape.createMask);
validRegion = 0;
while(~validRegion)
    if size(props,1) > 1 
        tmp_textPos = [invalidRectTextPosition(1)-30 invalidRectTextPosition(2)];
        invalidRectTextedFrame = insertText(firstFrame,tmp_textPos,'Area selezionata non ?? un quadrilatero, riprovare', ...
         'FontSize',13,'TextColor','w','BoxOpacity',0); % aggiunta del testo al frame
    else
        if (props.Area) < minimumArea
          invalidRectTextedFrame = insertText(firstFrame,invalidRectTextPosition,'Area selezionata troppo piccola, riprovare', ...
           'FontSize',13,'TextColor','w','BoxOpacity',0); % aggiunta del testo al frame
        else
            if min(props.BoundingBox(3:4)) < minimumSize
                invalidRectTextedFrame = insertText(firstFrame,invalidRectTextPosition,'Area selezionata troppo schiacciata, riprovare', ...
                    'FontSize',13,'TextColor','w','BoxOpacity',0); % aggiunta del testo al frame
            else
                validRegion = 1;
            end
        end
    end
    old_pos = getPosition(parkShape);
    if ~validRegion
        invalidRectTextedFrame = imresize(invalidRectTextedFrame, scaleFactor); % ingrandimento del frame
        figure(1);
        imshow(invalidRectTextedFrame);
        % the previous impoly object has been torn down, I have to setup a
        % new one, equal to the old one
        parkShape = impoly(gca,old_pos);
        api = iptgetapi(parkShape);
        fcn = makeConstrainToRectFcn('impoly',get(gca,'XLim'),get(gca,'YLim'));
        api.setPositionConstraintFcn(fcn);
        api.setColor('yellow');
        parkShape.wait;
        props = regionprops(parkShape.createMask);
    end
end
parkingAreaPoly = getPosition(parkShape);
[tmpX,tmpY]=poly2ccw(parkingAreaPoly(:,1),parkingAreaPoly(:,2));
parkingAreaPoly = [tmpX,tmpY];
delete(parkShape);
% parkingArea_rearranged contains the same values of parkingAreaPoly, 
% but rearranged to be compatible with insertShape function
parkingArea_rearranged = zeros([1 8]);
% rearrange values of the position
% in order to fit insertShape() requirements
for i = 1:4
    parkingArea_rearranged(2*i-1) = parkingAreaPoly(i,1);
    parkingArea_rearranged(2*i)   = parkingAreaPoly(i,2);
end
firstTextedFrame = insertShape(firstTextedFrame,'FilledPolygon',parkingArea_rearranged,'Opacity',0.1);
figure(1);
imshow(firstTextedFrame);

%% INIT:
%   FOREGROUND DETECTOR OBJECT 
%   BLOB ANALYZER
%   TRACKS

% oggetto responsabile della Background Subtraction con GMM
foregroundDetector = vision.ForegroundDetector('NumGaussians', 2, 'NumTrainingFrames', ...
                     30, 'MinimumBackgroundRatio', 0.54, 'LearningRate',0.0145);

% oggetto responsabile dell'analisi dei pixel rilevati come foreground
% prende come input una immagine binaria, e restituisce i bounding box
blobAnalyser = vision.BlobAnalysis('BoundingBoxOutputPort', true, 'AreaOutputPort', true, ...
               'CentroidOutputPort', true, 'MinimumBlobArea', minimumArea,'MaximumBlobArea',maximumArea);

% inizializzazione delle tracce per il Tracking
tracks = initializeTracks();     

nextId = 1; % ID della "prossima" track
freePlaces = 0; % contatore dei posti liberi
busyPlaces = 0; % contatotre dei posti occupati
places = initializePlaces(); % inizializzazione della struttura relativa alle posizioni dei posti
frameCount = 0; % contatore del numero di frame 
afterPanic = 0;
panic = 0;

%% MAIN LOOP: 1 ITERATION PER FRAME

while ~isDone(videoSource)
    
    nextFrame = step(videoSource); % estrazione di un frame dal video
    debug = 74;
    debugFrame = 15577;
    if (any(frameCount == indexGood(:)) || jump==0) %Se il jump non ? attivo o se il frame ? buono
        
        if(frameCount > debugFrame)
            debug;
        end
        
        % riconoscimento degli oggetti in movimento tramite Background Subtraction (GMM)
        [centroids, bboxes, mask, panic, afterPanic] = detectObjects(nextFrame,foregroundDetector,blobAnalyser, panic, afterPanic);
        
        if(frameCount > debugFrame)
            debug;
        end
        
        % predizione della nuova posizione delle tracce
        tracks = predictNewLocationsOfTracks(tracks);

        % ho trovato i nuovi oggetti in movimento, e le nuove tracce (predette con kalman) 
        % adesso associo gli oggetti rilevati alle tracce
        % ottengo tracce assegnate, e tracce non assegnate
        [assignments, unassignedTracks, unassignedDetections] = detectionToTrackAssignment(tracks,centroids,bboxes);
        if (panic == 1 || afterPanic > 0)
           nTracks = length(tracks);
           unassignedTracks = [1:nTracks]';
           assignments = [];
        end
        
        if(frameCount > debugFrame)
            debug;
        end
        
        % aggiornamento delle tracce assegnate 
        tracks = updateAssignedTracks(tracks,assignments,centroids,bboxes,parkingAreaPoly,scaleFactor);
        
        if(frameCount > debugFrame)
            debug;
        end
        
        % aggiornamento delle tracce NON assegnate
        tracks = updateUnassignedTracks(tracks,unassignedTracks);
        
        if(frameCount > debugFrame)
            debug;
        end
        
        % eliminazione delle tracce perdute
        [tracks,freePlaces,busyPlaces,places] = deleteLostTracks(tracks,freePlaces,busyPlaces,places);
        
        if(frameCount > debugFrame)
            debug;
        end
        
        % creazione delle tracce nuove
        [tracks, nextId] = createNewTracks(tracks,unassignedDetections,centroids,bboxes,nextId,parkingAreaPoly,scaleFactor,panic);
        
        if(frameCount > debugFrame)
            debug;
        end
        
        minVisibleCount = 10; % valore minimo di visibilit??? affinch??? una traccia venga considerata affidabile
        if ~isempty(tracks)
            reliableTrackInds = [tracks(:).totalVisibleCount] > minVisibleCount; % estrazione degli indici delle tracce affidabili
            reliableTracks = tracks(reliableTrackInds); % estrazione delle tracce affidabili
            reliableTrackInds = [reliableTracks(:).consecutiveInvisibleCount] == 0;
            reliableTracks = tracks(reliableTrackInds);
            bboxes = cat(1, reliableTracks.bbox); % estrazione delle bounding boxes associate alle tracce affidabili
        elseif (panic == 1)
            bboxes = double([]);
        end
        
        % cazzate di visualizzazione
        nextFrame = insertShape(nextFrame,'rectangle',bboxes); % inserimento rettangoli attorno alle tracce affidabili
        placesTextPosition = [30 8]; % posizione del testo indicante il numero di parcheggi liberi/occupati
        nextFrame = insertText(nextFrame,placesTextPosition,sprintf('Posti liberi: %d           Posti occupati: %d     Frame: %d',freePlaces,busyPlaces,frameCount), ...
        'FontSize',13,'TextColor','w','BoxOpacity',0); % aggiunta del testo al frame
        nextFrame = imresize(nextFrame, scaleFactor); % ingrandimento del frame
        nextFrame = insertShape(nextFrame,'FilledPolygon',parkingArea_rearranged,'Color','yellow','Opacity',0.1); % evidenziamento area da monitorare
        freeCircles = circlesFromFreePlaces(places,scaleFactor); % ottenimento dei centroidi relativi ai posti liberi
        nextFrame = insertShape(nextFrame,'FilledCircle',freeCircles,'Color','green'); % inserimento di cerchietti verdi in corrispondenza dei posti liberi
        busyCircles = circlesFromBusyPlaces(places,scaleFactor); % ottenimento dei centroidi relativi ai posti occupati
        nextFrame = insertShape(nextFrame,'FilledCircle',busyCircles,'Color','red'); % inserimento di cerchietti rossi in corrispondenza dei posti occupati
        figure(1);
        imshow(nextFrame); % visualizzazione del frame
    else
        foregroundDetector.reset();
        tracks = initializeTracks();  
    end
    frameCount = frameCount + 1; % aumento del contatore di frame
    
end

release(videoSource); % rilascio dell'oggetto video