function [filt, t] = get_temporal_edge_filter(t, tfilter)
% sample the given temporal edge detection filter at time values t.
% t: the time values at which we sample the filter
% afilter: type of filter to use. Defaults to d_all
%
% filter types: 
%  - t_all: final filter from the paper
%  - t_low: filter from low-contrast cases only
%  - d_all_interp: disef function fitted to all 60Hz data (t_all), interpolated
%  - d_low_interp: disef function fitted to t_low, interpolated
%  - d_all: analytical disef function fitted to t_all, sampled
%  - d_low: analytical disef function fitted to t_low, sampled
%
% References
% under review.
%
% MIT License
% Copyright (c) 2022 Gyorgy Denes (gdenes355@gmail.com), Pontus Andersson, 
% Tomas Akenine-Möller, Kalle Åström, Magnus Oskarsson, William H. McIlhagga
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

    if ~exist('tfilter', 'var') 
        tfilter = 'd_all';
    end
    
    % switch (tfilter)
    if strcmpi(tfilter, 'd_all')
        s_in_sec = 1.74443648427644 / 60;   % s value from paper
        t0 = mean(t);  % shift the fitler to be in the middle of t
        t = t - t0;
        filt = -sign(t).*exp(-abs(t)/(s_in_sec));  % DISEF
    elseif strcmpi(tfilter, 'd_low')
        s_in_sec = 1.2386001106974815 / 60;  % s value from paper
        t0 = mean(t);  % shift the fitler to be in the middle of t
        t = t - t0;
        filt = -sign(t).*exp(-abs(t)/(s_in_sec));  % DISEF
    else
        % this might be an interpolated filter.
        if strcmpi(tfilter, 't_all')
            samples = [3.955975174903869629e-01, -1.020166635513305664e+00, -3.440489530563354492e+00, -5.091692924499511719e+00, -5.026970863342285156e+00, -2.602464199066162109e+00, 3.469745635986328125e+00, 1.378295803070068359e+01, 2.633740043640136719e+01, 3.921465301513671875e+01, 1.188159108161926270e+00, -2.439352607727050781e+01, -1.657835006713867188e+01, -9.859210014343261719e+00, -6.638015270233154297e+00, -6.391635417938232422e+00, -5.401230812072753906e+00, -3.818691492080688477e+00, -1.050134897232055664e+00, 2.127528429031372070e+00, 2.900552988052368164e+00]';
        elseif strcmpi(tfilter, 'd_all_interp')
            samples = [1.909064141608989573e-01, 3.386727748829402862e-01, 6.008140111533419869e-01, 1.065859150098313224e+00, 1.890860909963615333e+00, 3.354434758568847652e+00, 5.950851535511070267e+00, 1.055696012785268678e+01, 1.872831249040729062e+01, 3.322449687130618656e+01, -0.000000000000000000e+00, -3.322449687130618656e+01, -1.872831249040729062e+01, -1.055696012785268678e+01, -5.950851535511070267e+00, -3.354434758568847652e+00, -1.890860909963615333e+00, -1.065859150098313224e+00, -6.008140111533419869e-01, -3.386727748829402862e-01, -1.909064141608989573e-01]';
        elseif strcmpi(tfilter, 't_low')
            samples = [2.467014074325561523e+00, 1.195966601371765137e+00, -1.652753710746765137e+00, -5.535111904144287109e+00, -8.609863281250000000e+00, -8.827475547790527344e+00, -4.716462135314941406e+00, 1.016245746612548828e+01, 3.350759124755859375e+01, 5.394515991210937500e+01, 6.111305236816406250e+00, -3.482356262207031250e+01, -1.925815010070800781e+01, -5.424099922180175781e+00, -1.625993967056274414e+00, -7.347380161285400391e+00, -7.372952938079833984e+00, -4.587455749511718750e+00, -2.869678020477294922e+00, 2.272292226552963257e-02, 2.123717546463012695e+00]';
        elseif strcmpi(tfilter, 'd_low_interp')
            samples = [3.219703752655577594e-02, 7.218537057656362887e-02, 1.618387319323421891e-01, 3.628404889282670909e-01, 8.134840086410377591e-01, 1.823821355409757761e+00, 4.088985525364493334e+00, 9.167456328464750115e+00, 2.055332673911014041e+01, 4.608031114726507838e+01, -0.000000000000000000e+00, -4.608031114726507838e+01, -2.055332673911014041e+01, -9.167456328464750115e+00, -4.088985525364493334e+00, -1.823821355409757761e+00, -8.134840086410377591e-01, -3.628404889282670909e-01, -1.618387319323421891e-01, -7.218537057656362887e-02, -3.219703752655577594e-02]';       
        else
            error('unknown filter');
        end
        samplets = (0:(size(samples, 1)-1)) / 60;  % filters were measured for 60Hz
        filt = interp1(samplets, samples, t);
    end

    % remove nan values
    filt = filt(~isnan(filt));
    t = t(~isnan(filt));
    
    % normalise so +ves sum to 1, -ves sum to -1
    filt(filt>0) = filt(filt>0) / sum(filt(filt>0));
    filt(filt<0) = -filt(filt<0) / sum(filt(filt<0));
end