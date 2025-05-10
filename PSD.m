clc;
clear;
close all;

%% Parameters
N = 64; % Number of subcarriers
M = 4; % QPSK Modulation
numSymbols = 1000; % Number of OFDM symbols
fs = 15e3; % Subcarrier spacing (Hz)

%% Generate OFDM Signal
ofdm_symbols = randi([0 M-1], N, numSymbols);
modulated_ofdm = pskmod(ofdm_symbols, M, pi/4);
ifft_ofdm = ifft(modulated_ofdm, N);
ofdm_signal = reshape(ifft_ofdm, [], 1);

%% Generate FOFDM-IM Signal
K = N/2; % Number of active subcarriers
active_indices = randperm(N, K);
fofdm_symbols = zeros(N, numSymbols);
fofdm_symbols(active_indices, :) = pskmod(randi([0 M-1], K, numSymbols), M, pi/4);
ifft_fofdm = ifft(fofdm_symbols, N);
fofdm_signal = reshape(ifft_fofdm, [], 1);

%% Compute Power Spectral Density
[pxx_ofdm, f_ofdm] = pwelch(ofdm_signal, [], [], [], fs, 'centered');
[pxx_fofdm, f_fofdm] = pwelch(fofdm_signal, [], [], [], fs, 'centered');

%% Plot PSD Comparison
figure;
plot(f_ofdm/1e3, 10*log10(pxx_ofdm), 'b', 'LineWidth', 2); hold on;
plot(f_fofdm/1e3, 10*log10(pxx_fofdm), 'r', 'LineWidth', 2);
grid on;
legend('OFDM', 'FOFDM-IM');
xlabel('Frequency (kHz)');
ylabel('Power Spectral Density (dB/Hz)');
title('PSD Comparison of OFDM and FOFDM-IM');
