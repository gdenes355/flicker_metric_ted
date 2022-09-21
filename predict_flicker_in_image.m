function P = predict_flicker_in_image( frame_a, frame_b, ppd, fps, tfilter, options )
%  predict_flicker_in_image
% frame_a - frame in CIE XYZ
% frame_b - frame in CIE XYZ
% [ppd] - pixels per visual degree on the display. Default: 52 (desktop)
% [fps] - frames per second. Default: 120(Hz)
% [filter] - temporal edge detection to use. For options, see get_filter.m. Default: d_all
% [options] - model paramteres. Default: best fitting reported in paper for d_all
%
% output:
% P - a probability of detection map; identical in size to frame_a and
% frame_b
%
% for example use, see demo folder
%
% References
% under review.
%
% Copyright (c) 2022 Gyorgy Denes (gdenes355@gmail.com), Pontus Andersson, 
% Tomas Akenine-Möller, Kalle Åström, William H. McIlhagga
%
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.

    %% input processing, asserts
    assert(isequal(size(frame_a), size(frame_b)));
    if ~exist( 'ppd', 'var' )
        ppd = 52;
    end
    if ~exist( 'fps', 'var') || isempty(fps)
        fps = 120;
    end
    if ~exist('tfilter', 'var')
        tfilter = 'd_all';
    end
    if ~exist('options', 'var')
        psyalpha = -0.1008;
        psybeta = 0.9061;
    else
        psyalpha = options.psyalpha;
        psybeta = options.psybeta;
    end
    
    %% create a 1.0 second video with 2 samples per frame
    SAMPLES_PER_FRAME = 2;
    
    % time samples
    t = (0:(1/(SAMPLES_PER_FRAME*fps)):1.0)';
    
    % video frames (luiminance only)
    vid = zeros(size(t,1), size(frame_a, 1), size(frame_a, 2));
    allmask = 1:size(t,1);
    amask = mod(floor(allmask/SAMPLES_PER_FRAME),2)==0;
    bmask = mod(floor(allmask/SAMPLES_PER_FRAME),2)==1;
    vid(amask,:,:) = repmat(reshape(frame_a(:,:,2), 1,size(frame_a, 1), size(frame_a,2)), sum(amask),1,1);
    vid(bmask,:,:) = repmat(reshape(frame_b(:,:,2), 1,size(frame_b, 1), size(frame_b,2)), sum(bmask),1,1);
    
    %% get the filter
    ted_filter = get_temporal_edge_filter(t(t<0.9), tfilter);

    %% process
    filtered = convn(vid, ted_filter, 'valid');  % convolution along time axis
    filtered = squeeze(max(abs(filtered)));  % max (abs) along time axis
    
    filtered = imgaussfilt(filtered, 0.36 * ppd, 'padding', 'symmetric');  % filter in spatial domain
    
    P = 1 - exp(psyalpha * filtered .^ psybeta);  % apply psychometric function
end
