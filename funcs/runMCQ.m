function [choiceIdx, choiceText, rt, confirmed] = runMCQ(cfg, questionText, options)
% One-screen MCQ with clickable circles next to options.
% Returns:
%   choiceIdx: 1..K
%   choiceText: the selected option label
%   rt: seconds from onset to click
%   confirmed: 1 if answered, 0 if aborted (ESC)

win = cfg.screen.pointer;
bg  = cfg.format.backgroundColor;
fg  = cfg.format.foregroundColor;

Screen('TextFont', win, cfg.format.font);
Screen('TextSize', win, cfg.format.fontSizeText);

K = numel(options);

ShowCursor();
SetMouse(cfg.screen.centerX, cfg.screen.centerY, win);

% Layout
yQ = round(cfg.screen.resoly * 0.18);
y0 = round(cfg.screen.resoly * 0.35);
dy = round(cfg.screen.resoly * 0.08);

circleR = 14;
circleX = round(cfg.screen.resolx * 0.20);
textX   = circleX + 40;

cy = y0 + (0:K-1)*dy;

drawFrame(NaN);
tOnset = Screen('Flip', win);

if cfg.info.parallel_port; parallel_port(30); end
NetStation('Event','EVEN', tOnset, 0.001, 'ques',30); %NetStation('FlushReadbuffer');
ev = logEvent(ev, event_, tResp, NaN, 'DI30', 30, start_exp, 500);
event_ = event_ + 1;

choiceIdx = NaN;
choiceText = '';
rt = NaN;
confirmed = 0;

while ~confirmed
    [keyIsDown, ~, keyCode] = KbCheck;
    if keyIsDown && keyCode(cfg.keys.keyESCAPE)
        return;
    end

    [mx, my, buttons] = GetMouse(win);

    if any(buttons)
        for i = 1:K
            if (mx - circleX)^2 + (my - cy(i))^2 <= circleR^2
                choiceIdx  = i;
                choiceText = options{i};
                rt         = GetSecs() - tOnset;
                confirmed  = 1;
                break;
            end
        end
    end

    drawFrame(choiceIdx);
    Screen('Flip', win);
end

HideCursor();

    function drawFrame(sel)
        Screen('FillRect', win, bg);
        DrawFormattedText(win, questionText, 'center', yQ, fg);

        for j = 1:K
            Screen('FrameOval', win, fg, [circleX-circleR cy(j)-circleR circleX+circleR cy(j)+circleR], 2);

            if ~isnan(sel) && sel == j
                Screen('FillOval', win, fg, [circleX-circleR+4 cy(j)-circleR+4 circleX+circleR-4 cy(j)+circleR-4]);
            end

            DrawFormattedText(win, options{j}, textX, cy(j)-cfg.format.fontSizeText/2, fg);
        end

        DrawFormattedText(win, 'Click an option', 'center', round(cfg.screen.resoly*0.92), fg);
    end
end