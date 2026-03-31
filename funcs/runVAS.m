function [valueNegPos, rt, confirmed] = runVAS(cfg, questionText, leftAnchor, rightAnchor, imageFile)
% Continuous VAS slider -100..100. Optional imageFile displayed above slider.
% Confirm by mouse click or SPACE. ESC aborts (returns NaNs).

if nargin < 5
    imageFile = '';
end

win = cfg.screen.pointer;
bg  = cfg.format.backgroundColor;
fg  = cfg.format.foregroundColor;

Screen('TextFont', win, cfg.format.font);
Screen('TextSize', win, cfg.format.fontSizeText);

ShowCursor();
SetMouse(cfg.screen.centerX, cfg.screen.centerY, win);

% Slider geometry
xCenter = cfg.screen.centerX;
yCenter = cfg.screen.centerY;

sliderLenPx = round(cfg.screen.resolx * 0.70);
sliderY     = round(yCenter + cfg.screen.resoly * 0.22);
sliderX1    = xCenter - sliderLenPx/2;
sliderX2    = xCenter + sliderLenPx/2;

lineWidthPx  = 6;
knobRadiusPx = 10;

knobX = xCenter; % start at 0

% Optional image texture
tex = [];
dstRect = [];
if ~isempty(imageFile) && isfile(imageFile)
    img = imread(imageFile);
    tex = Screen('MakeTexture', win, img);

    imgW = size(img,2); imgH = size(img,1);
    scale = min((cfg.screen.resolx*0.6)/imgW, (cfg.screen.resoly*0.25)/imgH);
    dstRect = CenterRectOnPointd([0 0 imgW*scale imgH*scale], xCenter, yCenter - cfg.screen.resoly*0.05);
end

drawFrame(fg);
tOnset = Screen('Flip', win);

if cfg.info.parallel_port; parallel_port(30); end
NetStation('Event','EVEN', tOnset, 0.001, 'ques',30);

confirmed = 0;
valueNegPos = NaN;
rt = NaN;
confirmationColor = [0 255 0]; 

while ~confirmed
    [keyIsDown, ~, keyCode] = KbCheck;
    if keyIsDown
        if keyCode(cfg.keys.keyESCAPE)
            cleanupTex();
            return;
        elseif keyCode(cfg.keys.keySPACE)
            confirmed = 1;
        end
    end

    [mx, ~, buttons] = GetMouse(win);
    knobX = min(max(mx, sliderX1), sliderX2);

    if any(buttons)
        confirmed = 1;
    end

    drawFrame(fg); % normal knob color
    Screen('Flip', win);
end

% --- CONFIRMATION VISUAL ---
rt = GetSecs() - tOnset;
frac = (knobX - sliderX1) / (sliderX2 - sliderX1);
valueNegPos = (frac * 200) - 100;

% Draw the knob in green for 0.4s

drawFrame(confirmationColor);
Screen('Flip', win);
WaitSecs(0.4); % short gap to avoid double-click

cleanupTex();
HideCursor();


    function drawFrame(knobColor)
        if nargin < 1
            knobColor = fg; % default color
        end

        Screen('FillRect', win, bg);
        DrawFormattedText(win, questionText, 'center', round(cfg.screen.resoly*0.12), fg);

        if ~isempty(tex)
            Screen('DrawTexture', win, tex, [], dstRect);
        end

        DrawFormattedText(win, leftAnchor,  sliderX1, sliderY + 40, fg);
        DrawFormattedText(win, rightAnchor, sliderX2 - 250, sliderY + 40, fg);

        Screen('DrawLine', win, fg, sliderX1, sliderY, sliderX2, sliderY, lineWidthPx);
        Screen('DrawLine', win, fg, xCenter, sliderY - 15, xCenter, sliderY + 15, 3);

        Screen('FillOval', win, knobColor, [knobX-knobRadiusPx, sliderY-knobRadiusPx, knobX+knobRadiusPx, sliderY+knobRadiusPx]);

        frac = (knobX - sliderX1) / (sliderX2 - sliderX1);
        v = (frac * 200) - 100;
        DrawFormattedText(win, sprintf('%0.0f', v), 'center', sliderY - 70, fg);

        DrawFormattedText(win, 'Click to confirm (or press SPACE)', 'center', round(cfg.screen.resoly*0.92), fg);
    end

    function cleanupTex()
        if ~isempty(tex)
            Screen('Close', tex);
        end
    end
end