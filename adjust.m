function rectangle = adjust(rect,size,scale)

% aggiusta il rettangolo di input utente, tagliando le parti che escono fuori dal video 

rectangle = rect;

realStartY = 37 * scale;
realEndY = 252 * scale;

if rectangle(1) < 1
    rectangle(3) = rectangle(3) + rectangle(1);
    rectangle(1) = 1;
end

if rectangle(1) > (size(2) * scale)
    rectangle(3) = 0;
    rectangle(1) = size(2) * scale;
end

if rectangle(2) < realStartY
    rectangle(4) = rectangle(4) - (realStartY - rectangle(2));
    rectangle(2) = realStartY;
end

if rectangle(2) > realEndY
    rectangle(4) = 0;
    rectangle(2) = realEndY;
end

if (rectangle(1) + rectangle(3)) > size(2) * scale
    rectangle(3) = size(2) * scale - rectangle(1);
end

if (rectangle(2) + rectangle(4)) > realEndY
    rectangle(4) = realEndY - rectangle(2);
end

end