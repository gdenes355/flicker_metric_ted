function res_stimuli = select_stimuli(stimuli,idx)
%GET_STIMULI select stimuli stubset
    
    res_stimuli = stimuli;
    res_stimuli.ResultImages = stimuli.ResultImages(idx,:,:,:);
    res_stimuli.ref = stimuli.ref(idx,:,:,:);
    res_stimuli.blur = stimuli.blur(idx,:,:,:);
    res_stimuli.levels = stimuli.levels(idx,:);
    res_stimuli.refreshRates = stimuli.refreshRates(idx,:);
    res_stimuli.names = stimuli.names{idx,:};
    res_stimuli.P = stimuli.P(idx,:,:);
    res_stimuli.V_simple = stimuli.V_simple(idx,:,:);
    res_stimuli.V_sample = stimuli.V_sample(idx,:,:);
    res_stimuli.P_observers = stimuli.P_observers(idx,:,:,:);
    res_stimuli.V_observers = stimuli.V_observers(idx,:,:,:);
    

end

