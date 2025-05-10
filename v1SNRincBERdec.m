clc; clear; close all;

%% System Parameters
N = 64;  % Total number of subcarriers
M = 4;   % Modulation order (QPSK)
numActiveSubcarriers = N / 2;  % Active subcarriers
SNR_dB = 0:2:30;  % Finer SNR range for a smooth curve

%% Bit Mapping
bitsPerSymbol = log2(M);  
numSymbols = 1e4;  % Increased symbols per SNR point for smooth BER
dataBits = randi([0 1], numActiveSubcarriers * numSymbols * bitsPerSymbol, 1);  % More bits for accuracy

%% Modulation
modulatedSymbols = pskmod(bi2de(reshape(dataBits, bitsPerSymbol, []).'), M, pi/M);  % QPSK Modulation

%% Index Modulation (Efficient Selection)
activeIndices = sort(randperm(N, numActiveSubcarriers));  % Sorted for consistency
X = zeros(N, numSymbols);  % Initialize full subcarrier matrix
X(activeIndices, :) = reshape(modulatedSymbols, numActiveSubcarriers, numSymbols);  % Assign symbols correctly

%% Fast OFDM Processing
X_serial = ifft(X, N) * sqrt(N);  % Normalized IFFT

% BER Computation
BER = zeros(1, length(SNR_dB));
for i = 1:length(SNR_dB)
    % Add AWGN Noise
    noisySignal = awgn(X_serial, SNR_dB(i), 'measured');
    
    % Receiver Processing
    Y = fft(noisySignal, N) / sqrt(N);  % Normalized FFT
    receivedSymbols = Y(activeIndices, :);

    % ML Detection
    detectedBits = reshape(de2bi(pskdemod(receivedSymbols(:), M, pi/M), bitsPerSymbol).', [], 1);
    
    % BER Calculation
    BER(i) = mean(detectedBits ~= dataBits);
end

%% BER Plot
figure;
semilogy(SNR_dB, BER, '-o', 'LineWidth', 1.5);
grid on;
xlabel('SNR (dB)');
ylabel('BER');
title('Optimized Fast OFDM with Index Modulation - BER Performance');
legend(['M = ' num2str(M)]);
