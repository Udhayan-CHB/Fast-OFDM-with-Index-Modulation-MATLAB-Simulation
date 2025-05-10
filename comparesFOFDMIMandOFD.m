clc; clear; close all;

%% System Parameters
N = 64;  % Total subcarriers
M = 4;   % Modulation order (QPSK)
numActiveSubcarriers = N / 2;  % Active subcarriers for OFDM-IM
SNR_dB = 0:2:30;  % SNR range
numSymbols = 1e4;  % Number of symbols

%% Bit Mapping
bitsPerSymbol = log2(M);  
totalBits = numSymbols * numActiveSubcarriers * bitsPerSymbol;
dataBits = randi([0 1], totalBits, 1);

% Modulation
modulatedSymbols = pskmod(bi2de(reshape(dataBits, bitsPerSymbol, []).'), M, pi/M);
modulatedSymbols = reshape(modulatedSymbols, numActiveSubcarriers, numSymbols);

%% OFDM System (All subcarriers active)
X_OFDM = zeros(N, numSymbols);
X_OFDM(:,:) = pskmod(randi([0 M-1], N, numSymbols), M, pi/M);  % Fully occupied OFDM
X_serial_OFDM = ifft(X_OFDM, N);

%% OFDM-IM System
activeIndices = sort(randperm(N, numActiveSubcarriers));  % Select active subcarriers
X_OFDM_IM = zeros(N, numSymbols);
X_OFDM_IM(activeIndices, :) = modulatedSymbols;  % Assign active subcarriers
X_serial_OFDM_IM = ifft(X_OFDM_IM, N);

%% F-OFDM-IM System (Without Windowing and with Power Normalization)
X_FOFDM_IM = X_OFDM_IM;
X_serial_FOFDM_IM = ifft(X_FOFDM_IM, N);  % No windowing applied

% Power normalization (normalize per symbol)
for k = 1:numSymbols
    X_serial_FOFDM_IM(:, k) = X_serial_FOFDM_IM(:, k) / sqrt(sum(abs(X_serial_FOFDM_IM(:, k)).^2) / N);
end

%% BER Computation
BER_OFDM = zeros(1, length(SNR_dB));
BER_OFDM_IM = zeros(1, length(SNR_dB));
BER_FOFDM_IM = zeros(1, length(SNR_dB));

for i = 1:length(SNR_dB)
    % Add Noise
    noisy_OFDM = awgn(X_serial_OFDM, SNR_dB(i), 'measured');
    noisy_OFDM_IM = awgn(X_serial_OFDM_IM, SNR_dB(i), 'measured');
    noisy_FOFDM_IM = awgn(X_serial_FOFDM_IM, SNR_dB(i), 'measured');

    % Receiver FFT
    Y_OFDM = fft(noisy_OFDM, N) / sqrt(N);
    Y_OFDM_IM = fft(noisy_OFDM_IM, N) / sqrt(N);
    Y_FOFDM_IM = fft(noisy_FOFDM_IM, N) / sqrt(N);

    % Detection & Bit Error Calculation
    receivedSymbols_OFDM = Y_OFDM(:);
    receivedSymbols_OFDM_IM = Y_OFDM_IM(activeIndices, :);
    receivedSymbols_FOFDM_IM = Y_FOFDM_IM(activeIndices, :);

    detectedBits_OFDM = reshape(de2bi(pskdemod(receivedSymbols_OFDM, M, pi/M), bitsPerSymbol).', [], 1);
    detectedBits_OFDM_IM = reshape(de2bi(pskdemod(receivedSymbols_OFDM_IM(:), M, pi/M), bitsPerSymbol).', [], 1);
    detectedBits_FOFDM_IM = reshape(de2bi(pskdemod(receivedSymbols_FOFDM_IM(:), M, pi/M), bitsPerSymbol).', [], 1);

    % Ensure detected bit length matches original data length
    detectedBits_OFDM = detectedBits_OFDM(1:length(dataBits));
    detectedBits_OFDM_IM = detectedBits_OFDM_IM(1:length(dataBits));
    detectedBits_FOFDM_IM = detectedBits_FOFDM_IM(1:length(dataBits));

    % BER Computation
    BER_OFDM(i) = sum(detectedBits_OFDM ~= dataBits) / length(dataBits);
    BER_OFDM_IM(i) = sum(detectedBits_OFDM_IM ~= dataBits) / length(dataBits);
    BER_FOFDM_IM(i) = sum(detectedBits_FOFDM_IM ~= dataBits) / length(dataBits);
end

%% BER Plot
figure;
semilogy(SNR_dB, BER_OFDM, '-s', 'LineWidth', 1.5);
hold on;
semilogy(SNR_dB, BER_OFDM_IM, '-o', 'LineWidth', 1.5);
semilogy(SNR_dB, BER_FOFDM_IM, '-d', 'LineWidth', 1.5);
grid on;
xlabel('SNR (dB)');
ylabel('BER');
title('BER Performance Comparison');
legend('OFDM', 'OFDM-IM', 'F-OFDM-IM');
