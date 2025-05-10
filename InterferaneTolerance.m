clc; clear; close all;

% Simulation Parameters
N = 64; % Number of subcarriers
M = 4; % QPSK Modulation
numSymbols = 10000; % Number of symbols
SNR_dB = 0:2:20; % Reduced SNR range for better testing
ACI_power_dB = -10; % Decreased ACI power for testing (Lower interference)

% Generate random data
data = randi([0 M-1], numSymbols, 1);

% QPSK Modulation
modulatedSymbols = pskmod(data, M, pi/M);

% Allocate subcarriers for OFDM-IM with reduced guard bands
guard_band_size = 2; % Reduced guard band size for testing
active_indices = [guard_band_size+1:N/2-guard_band_size, N/2+guard_band_size+1:N-guard_band_size]; % Updated active indices

% Ensure modulatedSymbols match the size of active_indices
numActiveSymbols = length(active_indices); % Number of symbols to modulate
modulatedSymbols = modulatedSymbols(1:numActiveSymbols); % Adjust modulated symbols to match

% Initialize OFDM symbols
ofdm_symbols = zeros(N, 1);

% Assign the modulated symbols to active subcarriers
ofdm_symbols(active_indices) = modulatedSymbols; 

% Perform IFFT
ofdm_time = ifft(ofdm_symbols, N);

% Apply 48th order FIR filter with cutoff at 0.45*fs (Removed for now, for testing)
% Uncomment the following line for filtering if needed later
% filter_coeff = fir1(48, 0.45); % 48th order FIR filter with cutoff at 0.45*fs
% f_ofdm_time = filter(filter_coeff, 1, ofdm_time); % Filter the OFDM signal

% For testing, skip the FIR filter and use the original OFDM signal
f_ofdm_time = ofdm_time; % Skip filtering for testing

% Preallocate BER arrays
ber_ofdm = zeros(1, length(SNR_dB));
ber_f_ofdm = zeros(1, length(SNR_dB));

% Add Interference & Noise for Each SNR
for i = 1:length(SNR_dB)
    % Generate Adjacent Channel Interference (ACI)
    ACI_signal = sqrt(10^(ACI_power_dB/10)) * (randn(N,1) + 1j*randn(N,1))/sqrt(2);

    % Add AWGN noise at specific SNR levels
    received_signal_ofdm = awgn(ofdm_time + ACI_signal, SNR_dB(i), 'measured');
    received_signal_f_ofdm = awgn(f_ofdm_time + ACI_signal, SNR_dB(i), 'measured');

    % Perform FFT
    received_freq_ofdm = fft(received_signal_ofdm, N);
    received_freq_f_ofdm = fft(received_signal_f_ofdm, N);

    % Demodulation
    demod_ofdm = pskdemod(received_freq_ofdm(active_indices), M, pi/M);
    demod_f_ofdm = pskdemod(received_freq_f_ofdm(active_indices), M, pi/M);

    % Compute BER
    ber_ofdm(i) = sum(demod_ofdm ~= data(1:numActiveSymbols)) / length(demod_ofdm);
    ber_f_ofdm(i) = sum(demod_f_ofdm ~= data(1:numActiveSymbols)) / length(demod_f_ofdm);
end

% Plot BER vs SNR
figure;
semilogy(SNR_dB, ber_ofdm, 'ro--', 'LineWidth', 2, 'MarkerSize', 8); hold on;
semilogy(SNR_dB, ber_f_ofdm, 'bs--', 'LineWidth', 2, 'MarkerSize', 8);
grid on;
xlabel('SNR (dB)');
ylabel('BER');
title('Interference Tolerance: BER vs SNR');
legend('OFDM', 'F-OFDM-IM', 'Location', 'SouthWest');
