function ev = logEvent(ev, eventIdx, onsetTime, value, typeName, stateCode, startExp, duration)
    % Log a single event in the event structure
    %
    % Inputs:
    %   ev         - struct containing all event fields
    %   eventIdx   - index of the event to log
    %   onsetTime  - GetSecs() or event timestamp
    %   value      - numeric value to store (optional)
    %   typeName   - string describing the event type
    %   stateCode  - numeric code for the event
    %   startExp   - experiment start time (GetSecs)
    %   duration   - duration of the event in seconds
    %
    % Outputs:
    %   ev         - updated struct with event logged

    if nargin < 8
        duration = NaN;
    end

    ev.onsets(eventIdx)    = onsetTime - startExp; % relative to experiment start
    ev.durations(eventIdx) = duration;
    ev.types{eventIdx}     = typeName;
    ev.values(eventIdx)    = value;
    ev.samples(eventIdx)   = NaN;

    % Store current time with milliseconds
    ev.time{eventIdx} = datetime('now', 'Format', 'dd-MMM-yyyy HH:mm:ss.SSS');

    % Optional: store state if needed
    ev.states(eventIdx) = stateCode;
end