function places = initializePlaces()
    % creazione di un array vuoto di posti
    places = struct(...
        'bbox', {}, ...   % rettangolo associato al posto
        'isFree', {});   % indica se il posto � libero o meno
end