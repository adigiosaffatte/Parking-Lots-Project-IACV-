function [centroids, bboxes, mask] = detectObjects(frame,detector,blobAnalyser,bBoxes,cCentroids)
        % ritorna i centrodi degli oggetti rilevati come foreground
        % ritorna i rettangoli "circoscritti" a tali oggetti
        % ritorna la maschera binaria contenente pixel di background/foreground

        % riconoscimento del foreground
        mask = detector.step(frame);
        
        figure(2)
        subplot(2,1,1)
        imshow(mask);

        % applicazione di operazioni morfologiche per rimuovere il noise e riempire i buchi
        mask = imopen(mask, strel('diamond', 1));
        mask = imclose(mask, strel('diamond',10));
       %mask = imfill(mask, 'holes');

       foregroundPixels = sum(mask(:)); % numero di pixels di foreground
       pixelThreshold = 8500; % threshold per il numero di pixels massimi di foreground
       if (foregroundPixels < pixelThreshold)
           % analisi dei "gruppi" di pixel per trovare le componenti connesse
           [~, centroids, bboxes] = blobAnalyser.step(mask);
       else
%            [~, centroids, bboxes] = blobAnalyser.step(mask);
           bboxes = bBoxes;
           centroids = cCentroids;
       end
        
        maskBboxes = insertShape(im2uint8(mask),'rectangle',bboxes);
        subplot(2,1,2)
        imshow(maskBboxes);
end