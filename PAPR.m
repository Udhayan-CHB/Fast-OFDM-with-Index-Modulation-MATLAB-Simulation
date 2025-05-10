clc;
clear;
close all;

%% Parameters
N = 64; % Number of subcarriers
M = 4; % QPSK Modulation (QPSK corresponds to M=4)
numSymbols = 1000; % Number of OFDM symbols
fs = 15e3; % Subcarrier spacing (Hz)
K = N/2; % Number of active subcarriers

%% Generate OFDM Signal
% Generate random OFDM symbols (QPSK)
ofdm_symbols = randi([0 M-1], N, numSymbols);
modulated_ofdm = pskmod(ofdm_symbols, M, pi/4); % QPSK modulation

% Perform IFFT for OFDM symbols
ifft_ofdm = ifft(modulated_ofdm, N);
ofdm_signal = reshape(ifft_ofdm, [], 1);

%% Generate FOFDM-IM Signal with Optimized Subcarrier Selection
% Select K active subcarriers randomly
active_indices = randperm(N, K); 

% Initialize FOFDM-IM signal matrix
fofdm_symbols = zeros(N, numSymbols);

% Modulate active subcarriers (QPSK)
modulated_active_symbols = pskmod(randi([0 M-1], K, numSymbols), M, pi/4);

% Assign modulated symbols to the active subcarriers
fofdm_symbols(active_indices, :) = modulated_active_symbols;

% Perform IFFT for FOFDM-IM
ifft_fofdm = ifft(fofdm_symbols, N);
fofdm_signal = reshape(ifft_fofdm, [], 1);

% Power normalization to match OFDM and FOFDM-IM average power
fofdm_signal = fofdm_signal * sqrt(mean(abs(ofdm_signal).^2) / mean(abs(fofdm_signal).^2)); 

%% Compute Power Spectral Density (PSD)
[pxx_ofdm, f_ofdm] = pwelch(ofdm_signal, [], [], [], fs, 'centered');
[pxx_fofdm, f_fofdm] = pwelch(fofdm_signal, [], [], [], fs, 'centered');

%% Compute PAPR
papr_ofdm = max(abs(ofdm_signal).^2) / mean(abs(ofdm_signal).^2);
papr_fofdm = max(abs(fofdm_signal).^2) / mean(abs(fofdm_signal).^2);

%% Plot PSD Comparison
figure;
plot(f_ofdm/1e3, 10*log10(pxx_ofdm), 'b', 'LineWidth', 2); hold on;
plot(f_fofdm/1e3, 10*log10(pxx_fofdm), 'r', 'LineWidth', 2);
grid on;
legend('OFDM', 'FOFDM-IM');
xlabel('Frequency (kHz)');
ylabel('Power Spectral Density (dB/Hz)');
title('PSD Comparison of OFDM and FOFDM-IM');

%% Display PAPR Results
fprintf('PAPR of OFDM: %.2f dB\n', 10*log10(papr_ofdm));
fprintf('PAPR of FOFDM-IM: %.2f dB\n', 10*log10(papr_fofdm));
