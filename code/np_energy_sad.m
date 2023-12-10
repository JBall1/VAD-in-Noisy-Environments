% np_energy_sad.m
% Credit: Dr John Carmody
% Modifications made: 
% 1. Dynamic allocation based on side of S
% 2. Rounded several items to fix integer/error messages
function [ret, energy, snr] = np_energy_sad(signal, fs, win, thresh)
    % Apply a bandpass filter to signal to reduce ambient noise and fp
    fpass = [300 1500]; % Passband frequencies in Hz
    [b, a] = butter(4, fpass/(fs/2)); % 4th-order Butterworth filter
    signal = filter(b, a, signal);


    frame_size = round((win*10^-3)*fs);
    signal(1:fs) = 0;
    signal(end-fs:end) = 0;
    len = length(signal);
    voice_bin_len = ceil(len/frame_size);
    voice_bin = zeros(1, voice_bin_len);
    snr = zeros(1, voice_bin_len);
    count = 1;

    for i = 1:round(frame_size):round(len)
        edge = (frame_size + i) - 1;
        if edge > len
            edge = len;
        end
        frame = signal(i:edge);
        ts = 1/fs;
        Lfft = 1024;
        freq_axis = (0:Lfft/2-1)/(Lfft*ts);
        frame_size = max(1, round((win*10^-3)*fs));
        S = fft(double(frame), frame_size);
        S = S(1:floor(length(S)/2));
        locations = find(freq_axis >= 195);
        begin_index = locations(1);

        locations = find(freq_axis >= 3843);
        end_index = locations(1);
        S(1:begin_index) = 0.0;
        S(end_index:end) = 0.0;
        S = abs(S);
        S_squared = S.^2;
        Et = sum(S_squared);

        S_sorted = sort(S_squared);
        % Modified given code to include dynamic indexing
        idx_start = round(0.10 * length(S_sorted));
        idx_end = round(0.20 * length(S_sorted));
        Np = (1/100.0)*sum(S_sorted(idx_start:idx_end)) + .00001;
        L = 1;
        % Dynamically determine the upper index based on actual size
        upper_idx = length(S_sorted);

        % Ensure the loop does not attempt to access beyond array bounds
        for j = upper_idx:-1:1
            if sum(S_sorted(j:upper_idx)) >= Et*.4;
                L = j;
                break;
            end
        end
        if L == upper_idx
            L = L - 1;
        end
        % Updated to use upper_idx instead of 512
        Sp = (1.0/(upper_idx-L))*sum(S_sorted(L:upper_idx)) + 1e-10;

        snr(count) = (Sp / (Np + 1e-10));
        voice_bin(count) = (Sp/Np) > thresh + 90;
        count = count + 1;
    end

    ret = zeros(1, voice_bin_len*frame_size);
    for k = 1:frame_size
        ret(k:frame_size:end) = voice_bin;
    end

    e_len = ceil(len/frame_size);
    energy = zeros(1, e_len);
    signal = signal.^2;
    count = 1;
    for i = 1:frame_size:len
        edge = (i + frame_size) - 1;
        if edge > len
            edge = len;
        end
        pow2 = sum(signal(i:edge));
        pow = sqrt(pow2);
        energy(count) = pow;
        count = count + 1;
    end
end
