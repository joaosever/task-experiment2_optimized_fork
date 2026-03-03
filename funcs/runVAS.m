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

drawFrame();
tOnset = Screen('Flip', win);

confirmed = 0;
valueNegPos = NaN;
rt = NaN;

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

    drawFrame();
    Screen('Flip', win);
end

rt = GetSecs() - tOnset;

frac = (knobX - sliderX1) / (sliderX2 - sliderX1);
valueNegPos = (frac * 200) - 100;

cleanupTex();
HideCursor();

    function drawFrame()
        Screen('FillRect', win, bg);

        DrawFormattedText(win, questionText, 'center', round(cfg.screen.resoly*0.12), fg);

        if ~isempty(tex)
            Screen('DrawTexture', win, tex, [], dstRect);
        end

        DrawFormattedText(win, leftAnchor,  sliderX1, sliderY + 40, fg);
        DrawFormattedText(win, rightAnchor, sliderX2 - 250, sliderY + 40, fg);

        Screen('DrawLine', win, fg, sliderX1, sliderY, sliderX2, sliderY, lineWidthPx);
        Screen('DrawLine', win, fg, xCenter, sliderY - 15, xCenter, sliderY + 15, 3);

        Screen('FillOval', win, fg, [knobX-knobRadiusPx, sliderY-knobRadiusPx, knobX+knobRadiusPx, sliderY+knobRadiusPx]);

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