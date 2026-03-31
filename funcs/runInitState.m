function [initResp] = runInitState(cfg)
% Runs initial physiological + meta-physiological VAS block

nQ = numel(cfg.init.items);

initResp.values = nan(1,nQ);
initResp.rt     = nan(1,nQ);

for qi = 1:nQ
    item = cfg.init.items{qi};

    [v, rtSec, ok] = runVAS( ...
        cfg, ...
        item.question, ...
        item.anchors{1}, ...
        item.anchors{2}, ...
        '' ... % no image
    );

    if ok
        initResp.values(qi) = v;
        initResp.rt(qi)     = rtSec;
    end

    WaitSecs(0.2);
end

end
