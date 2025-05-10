clc; clear; close all;

% Define system parameters
N = 64:64:512; % Number of subcarriers
T_ifft = 1e-6; % Time for one IFFT operation (example: 1 microsecond)
T_fft = T_ifft; % FFT processing time (assumed same as IFFT)
T_filter = 2e-6; % Time for subband filtering in F-OFDM (example: 2 microseconds)
T_im = 0.5e-6; % Additional processing time for IM selection (example: 0.5 microseconds)

% Latency computation
Latency_OFDM = T_ifft + T_fft; % OFDM latency (IFFT + FFT)
Latency_OFDM_IM = Latency_OFDM + T_im; % OFDM-IM latency (includes IM processing)
Latency_FOFDM_IM = Latency_OFDM_IM + T_filter; % F-OFDM-IM latency (includes filtering)

% Plot latency comparison
figure;
plot(N, Latency_OFDM * 1e6, 'ro--', 'LineWidth', 2, 'MarkerSize', 8); hold on;
plot(N, Latency_OFDM_IM * 1e6, 'bs--', 'LineWidth', 2, 'MarkerSize', 8);
plot(N, Latency_FOFDM_IM * 1e6, 'g^--', 'LineWidth', 2, 'MarkerSize', 8);
grid on;
xlabel('Number of Subcarriers (N)');
ylabel('Latency (\mus)');
title('Latency Performance Comparison');

% Adjust legend to match the plot markers
legend({'OFDM', 'OFDM-IM', 'F-OFDM-IM'}, 'Location', 'NorthWest');
