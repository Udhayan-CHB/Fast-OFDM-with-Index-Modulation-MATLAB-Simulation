%% Visualize Conventional vs. "Fast" OFDM Subcarriers in Frequency Domain
% This version corrects the subcarrier selection for "Fast OFDM" to use
% the lower frequency half (DC + negative frequencies), matching the visual target.

clear;
clc;
close all;

%% Parameters
N = 16; % Basic number of subcarriers (MUST BE EVEN for this indexing)
if mod(N,2) ~= 0
    error('N must be even for this script.');
end
oversampling_factor = 16; % Factor for FFT resolution
M = N * oversampling_factor; % Total points for FFT analysis

% Frequency axis for plotting (centered)
freq_bins = linspace(-M/2, M/2 - 1, M);

% --- Define which subcarrier indices to activate and plot ---
carriers_to_plot_conventional = 0:(N-1);

% "Fast" OFDM: Use lower half bandwidth -> DC (0) and Negative Frequencies (N/2+1 to N-1)
carriers_to_plot_fast = [0, (N/2 + 1):(N-1)];
% Note: Index N/2 (Nyquist) is often excluded or handled specially, omitted here.

%% Generate the base Sinc function in Frequency Domain
time_pulse = ones(N, 1);
base_spectrum = fft(time_pulse, M);
base_spectrum_shifted = fftshift(base_spectrum); % Spectrum centered around DC

%% Plotting Setup
figure('Position', [100, 100, 800, 600]);
colors = get(gca,'colororder');
num_colors = size(colors, 1);
close(gcf);

%% 1. Conventional OFDM Plot (Frequency Domain Sinc Shapes)
h_conv = subplot(2, 1, 1);
hold(h_conv, 'on');
title(h_conv, 'Conventional OFDM Subcarriers (Frequency Domain Magnitude)');
xlabel(h_conv, 'Frequency Bin Index (Shifted)');
ylabel(h_conv, 'Magnitude');
max_mag_conv = 0;
% Maps logical carrier index k (0 to N-1) to its *approximate* peak bin
% location within the M-point FFT array (before fftshift).
map_k_to_M_bins_unshifted = round(linspace(0, (N-1)*oversampling_factor, N));

for i = 1:length(carriers_to_plot_conventional)
    k = carriers_to_plot_conventional(i);
    color_idx = mod(k, num_colors) + 1;

    % Calculate the shift amount needed to move the centered sinc peak
    % to the location corresponding to carrier k in the shifted view.
    % Carrier k (unshifted index 0..N-1) corresponds to:
    % - Bin k*oversampling_factor for k=0..N/2
    % - Bin (k-N)*oversampling_factor for k=N/2+1..N-1 (negative freqs)
    if k <= N/2
        freq_shift_target_bin = k * oversampling_factor;
    else
        freq_shift_target_bin = (k - N) * oversampling_factor;
    end

    % Plot shifted base spectrum magnitude
    plot(h_conv, freq_bins, abs(circshift(base_spectrum_shifted, round(freq_shift_target_bin))), ...
         'Color', colors(color_idx, :), 'LineWidth', 1);

    max_mag_conv = max(max_mag_conv, max(abs(base_spectrum_shifted)));
end

grid(h_conv, 'on');
hold(h_conv, 'off');
if max_mag_conv > 0; ylim(h_conv, [0, max_mag_conv * 1.1]); else; ylim(h_conv, [0, 1.1]); end
xlim_range = N * oversampling_factor / 1.8; % Adjust zoom slightly if needed
xlim(h_conv, [-xlim_range, xlim_range]);

%% 2. "Fast" OFDM Plot (Frequency Domain - Lower Half Bandwidth)
h_fast = subplot(2, 1, 2);
hold(h_fast, 'on');
title(h_fast, '"Fast" OFDM Subcarriers (Frequency Domain Magnitude - Lower Half)');
xlabel(h_fast, 'Frequency Bin Index (Shifted)');
ylabel(h_fast, 'Magnitude');
max_mag_fast = 0;

for i = 1:length(carriers_to_plot_fast)
    k = carriers_to_plot_fast(i); % Using indices for lower half BW
    color_idx = mod(k, num_colors) + 1;

    % Calculate shift amount for carrier k
    if k <= N/2 % Should only be k=0 here based on definition
        freq_shift_target_bin = k * oversampling_factor;
    else % k = N/2+1 to N-1 (Negative frequencies)
        freq_shift_target_bin = (k - N) * oversampling_factor;
    end

    % Plot shifted base spectrum magnitude
     plot(h_fast, freq_bins, abs(circshift(base_spectrum_shifted, round(freq_shift_target_bin))), ...
          'Color', colors(color_idx, :), 'LineWidth', 1);

    max_mag_fast = max(max_mag_fast, max(abs(base_spectrum_shifted)));
end

grid(h_fast, 'on');
hold(h_fast, 'off');
if max_mag_fast > 0; ylim(h_fast, [0, max_mag_fast * 1.1]); else; ylim(h_fast, [0, 1.1]); end
xlim(h_fast, [-xlim_range, xlim_range]); % Use same x-axis range as above

% --- Add the "Save Bandwidth" annotation on the unused (positive) side ---
x_limits = xlim(h_fast);
% Place annotation in the positive frequency region (e.g., 75% mark)
text_x_pos = x_limits(1) + 0.75 * (x_limits(2) - x_limits(1));

ylim_vals = ylim(h_fast);
text_y_pos = ylim_vals(2) * 0.6; % Adjust vertical position if needed

text(h_fast, text_x_pos, text_y_pos, '<-- Bandwidth Saving Area -->', ...
     'HorizontalAlignment', 'center', 'Color', 'blue', 'FontSize', 10, 'BackgroundColor', 'none');