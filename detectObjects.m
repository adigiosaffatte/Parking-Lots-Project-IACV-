function [centroids, bboxes, mask] = detectObjects(frame,detector,blobAnalyser)
        % ritorna i centrodi degli oggetti rilevati come foreground
        % ritorna i rettangoli "circoscritti" a tali oggetti
        % ritorna la maschera binaria contenente pixel di background/foreground

        % riconoscimento del foreground
        mask = detector.step(frame);

        % applicazione di operazioni morfologiche per rimuovere il noise e riempire i buchi
        mask = imopen(mask, strel('rectangle', [3,3]));
        mask = imclose(mask, strel('rectangle', [15, 15]));
        mask = imfill(mask, 'holes');

        % analisi dei "gruppi" di pixel per trovare le componenti connesse
        [~, centroids, bboxes] = blobAnalyser.step(mask);
end