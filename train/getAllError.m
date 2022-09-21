function [ error ] = getAllError(stimuli, model )
   
    ppd = 52;
    error = 0;
    for iS = 1:length(stimuli.levels)
        
        % prediction map       
        PMap = model(squeeze(stimuli.ref(iS,:,:,:)), ...
                                        squeeze(stimuli.blur(iS,:,:,:)), ...
                                        ppd, stimuli.refreshRates(iS));
        PMap = clamp(PMap, 0, 1);                           
        GroundTruth = squeeze(stimuli.P(iS,:,:));
        if size(PMap) ~= size(GroundTruth)
            PMap = imresize( PMap, size(GroundTruth), 'bilinear' );
        end
        
        % compute error (- log likelihood), averaged over each image
        error = error -loglik(PMap, GroundTruth)  / length(stimuli.levels);
    end   
end

function res = loglik(PMap, GroundTruth)
    N3 = 19 * 3; % number of markings (19 observers x 3 repetitions)
    p_mis = 0.01;  % probability of making a mistake while marking
    p = PMap;
    k = round(GroundTruth * N3 );
    n = N3;
    lik = p_mis + (1 - p_mis) * factorial(n) ./(factorial(k) .* factorial(n - k)) .* p .^ k .* (1-p) .^ (n-k);
    res = mean(mean(log(lik)));
end
