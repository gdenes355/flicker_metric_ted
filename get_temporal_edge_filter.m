function [filt, t] = get_temporal_edge_filter(t, tfilter)
% sample the given temporal edge detection filter at time values t.
% t: the time values at which we sample the filter
% tfilter: type of filter to use. Defaults to d_all
%
% filter types: 
%  - t_all: final filter from the paper, interpolated
%  - d_all: analytical disef function fitted to t_all, sampled in time
%  - tcsf_all: filter based on temporal CSF (stelaCSF), sampled in time
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
		% DISEF
        s_in_sec = 0.016;   % s value from paper
		amp = 148;          % amplitude from paper
        t0 = mean(t);  % shift the fitler to be in the middle of t
        t = t - t0;
        filt = -amp * sign(t).*exp(-abs(t)/(s_in_sec));  % DISEF function
		
    elseif strcmpi(tfilter, 't_all')
		% "free" filter
		samples = [2.380681037902832031e-01, -3.177686214447021484e+00, -1.703772783279418945e+00, -8.107570409774780273e-01, 3.285695016384124756e-01, -7.167906761169433594e-01, 2.733870744705200195e+00, 1.208868598937988281e+01, 2.555757522583007812e+01, 4.278320312500000000e+01, 5.342393517494201660e-01, -4.472121047973632812e+01, -2.688981056213378906e+01, -1.345495414733886719e+01, -5.092443943023681641e+00, -1.369577884674072266e+00, -4.700142741203308105e-01, 1.906259655952453613e+00, 4.587969779968261719e+00, 5.420155048370361328e+00, 2.884223461151123047e+00]';    
        
        samplets = (0:(size(samples, 1)-1)) / 60;  % filters were measured for 60Hz
        filt = interp1(samplets, samples, t);
		
    elseif strcmpi(tfilter, 'tcsf_all')
		% temporal csf from stelaCSF
		t0 = mean(t);
		t_interp = t - t0;
		
		F_s = 960;
		N_s = 2 * F_s + 1;
		
		% Generate tCSF
        try
            csf = CSF_stelaCSF();
        catch e
            % try adding dependency folder
            folder = fileparts(mfilename('fullpath'));
            addpath(sprintf("%s/%s", folder, 'deps'));
            csf = CSF_stelaCSF();
        end
		omega = linspace(0, F_s/2, floor(N_s / 2));
		[~, R_trans] = csf.get_sust_trans_resp(omega);
		filt_fft = 1j * [0, R_trans, -flip(R_trans)];
		filt = ifft(filt_fft);
		filt = fftshift(real(filt));
		
		% Generate time samples
		delta = 1 / F_s;
		t = linspace(-F_s, F_s, N_s)' * delta;

		% interp
		filt = interp1(t, filt, t_interp);
	else
		error('unknown filter');
	end
    % remove nan values
    t = t(~isnan(filt));
    filt = filt(~isnan(filt));
    
    % normalise so +ves sum to 1, -ves sum to -1
    filt(filt>0) = filt(filt>0) / sum(filt(filt>0));
    filt(filt<0) = -filt(filt<0) / sum(filt(filt<0));
end