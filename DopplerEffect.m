clc; clear; close all;

N_subcarriers = 64; % Total subcarriers
N_active = 16; % Number of active subcarriers for IM
N_symbols = 1000; % Number of transmitted symbols
EbNo_dB = 0:5:30; % SNR range in dB
fd = 100; % Doppler shift in Hz
Ts = 1e-3; % Symbol duration

BER_FOFDM_IM = zeros(size(EbNo_dB));
BER_OFDM = zeros(size(EbNo_dB));

for i = 1:length(EbNo_dB)
    EbNo = 10^(EbNo_dB(i)/10);
    N_errors_FOFDM_IM = 0;
    N_errors_OFDM = 0;
    
    for j = 1:N_symbols
        % Generate random bits for subcarrier index selection and QPSK modulation
        active_indices = randperm(N_subcarriers, N_active); % Unique active subcarriers
        qpsk_bits = randi([0, 1], 2*N_active, 1); % QPSK needs 2 bits per symbol
        qpsk_symbols = pskmod(bi2de(reshape(qpsk_bits, [], 2)), 4, pi/4); % QPSK modulation
        
        modulated_symbols = zeros(N_subcarriers, 1);
        modulated_symbols(active_indices) = qpsk_symbols(1:N_active); % Assign modulated symbols to active subcarriers
        
        % Rayleigh fading with Doppler shift
        h = (randn(N_subcarriers, 1) + 1i*randn(N_subcarriers, 1)) / sqrt(2);
        fading_effect = exp(1i * 2 * pi * fd * (0:N_subcarriers-1)' * Ts);
        faded_symbols = h .* modulated_symbols .* fading_effect;
        
        % Additive White Gaussian Noise (AWGN)
        noise_variance = 1/(2*EbNo);
        noise = sqrt(noise_variance) * (randn(N_subcarriers, 1) + 1i*randn(N_subcarriers, 1));
        received_symbols = faded_symbols + noise;
        
        % FOFDM-IM demodulation (assuming perfect subcarrier index detection)
        detected_symbols = received_symbols(active_indices) ./ h(active_indices);
        detected_bits = de2bi(pskdemod(detected_symbols, 4, pi/4), 2);
        detected_bits = detected_bits(:);
        
        % Count errors
        N_errors_FOFDM_IM = N_errors_FOFDM_IM + sum(qpsk_bits ~= detected_bits);
        
        % OFDM (standard) transmission
        qpsk_bits_ofdm = randi([0, 1], 2*N_subcarriers, 1);
        qpsk_symbols_ofdm = pskmod(bi2de(reshape(qpsk_bits_ofdm, [], 2)), 4, pi/4);
        
        h_ofdm = (randn(N_subcarriers, 1) + 1i*randn(N_subcarriers, 1)) / sqrt(2);
        fading_effect_ofdm = exp(1i * 2 * pi * fd * (0:N_subcarriers-1)' * Ts);
        faded_symbols_ofdm = h_ofdm .* qpsk_symbols_ofdm .* fading_effect_ofdm;
        
        noise_ofdm = sqrt(noise_variance) * (randn(N_subcarriers, 1) + 1i*randn(N_subcarriers, 1));
        received_symbols_ofdm = faded_symbols_ofdm + noise_ofdm;
        
        detected_symbols_ofdm = received_symbols_ofdm ./ h_ofdm;
        detected_bits_ofdm = de2bi(pskdemod(detected_symbols_ofdm, 4, pi/4), 2);
        detected_bits_ofdm = detected_bits_ofdm(:);
        
        N_errors_OFDM = N_errors_OFDM + sum(qpsk_bits_ofdm ~= detected_bits_ofdm);
    end
    
    BER_FOFDM_IM(i) = N_errors_FOFDM_IM / (N_symbols * 2 * N_active);
    BER_OFDM(i) = N_errors_OFDM / (N_symbols * 2 * N_subcarriers);
end

% Plot results
figure;
semilogy(EbNo_dB, BER_FOFDM_IM, 'b-o', 'LineWidth', 2); hold on;
semilogy(EbNo_dB, BER_OFDM, 'r-s', 'LineWidth', 2);
grid on;
xlabel('E_b/N_0 (dB)'); ylabel('Bit Error Rate');
legend('FOFDM-IM with Doppler', 'OFDM with Doppler');
title('BER Comparison of FOFDM-IM and OFDM under Doppler Effect');
