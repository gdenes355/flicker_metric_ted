if ~exist('stimuli', 'var')
    % first time setup
    load([fileparts(mfilename('fullpath')) '/../stimuli.mat']);
    addpath([fileparts(mfilename('fullpath')) '/../'])
end

% fit to all data
options = optimset('PlotFcns',@optimplotfval);
[params2, err] = fminsearch(@(x) loss_function(stimuli, x), [ -0.0782,    1.25],options);
params2
fprintf(1, 'All error: -%f\n', err);

% k-fold validation
K = 3;
indices = repmat(1:K, 1, size(stimuli.names,1) / K);
indices = indices(randperm(size(indices, 2)));
for ik=1:K
    a_stimuli = select_stimuli(stimuli, find(indices ~= ik));
    options = optimset('PlotFcns',@optimplotfval);
    [params2, err] = fminsearch(@(x) loss_function(a_stimuli, x), [ -0.0782,    1.25],options);
    params2
    err_test = loss_function(select_stimuli(stimuli, find(indices == ik)), [params2]);
    fprintf(1, 'K-fold %d error (tr) (te): -%f & -%f\n', ik, err, err_test);
end

function err = loss_function(stimuli, params)
    opts = {};
    opts.psyalpha = params(1);
    opts.psybeta = params(2);
    err = getAllError(stimuli, @(a,b,ppd,fps) predict_flicker_in_image(a, b, ppd, fps, 'd_all', opts));
    
    % constrain to realistic params
    if params(1) > -0.01
        err = err + (params(1)+0.01)*100;
    end
    if params(2) < 0.1
        err = err + (0.1- params(2))*100;
    end
end
