clc; clear; close all;

%% Parameters
N_vals = [64, 128, 256, 512, 1024]; % Different subcarrier sizes
M = 4; % QPSK modulation (bits per symbol = log2(M) = 2)
K_ratio = 0.5; % Active subcarrier ratio for IM-based schemes

%% FLOPs Calculation
flops_ofdm = zeros(size(N_vals));
flops_ofdm_im = zeros(size(N_vals));
flops_f_ofdm_im = zeros(size(N_vals));

for i = 1:length(N_vals)
    N = N_vals(i);
    K = round(K_ratio * N); % Active subcarriers
    
    % OFDM Complexity (IFFT + Guard + FFT)
    flops_ofdm(i) = 5 * N * log2(N); 
    
    % OFDM-IM Complexity (Subcarrier Selection + IFFT + Guard + FFT)
    flops_ofdm_im(i) = flops_ofdm(i) + 2 * K; 
    
    % F-OFDM-IM Complexity (Filtering + Subcarrier Selection + IFFT + FFT)
    flops_f_ofdm_im(i) = flops_ofdm_im(i) + 2 * N; % Additional filtering complexity
end

%% Plot Results
figure;
semilogy(N_vals, flops_ofdm, 'r-o', 'LineWidth', 2, 'MarkerSize', 8);
hold on;
semilogy(N_vals, flops_ofdm_im, 'b-s', 'LineWidth', 2, 'MarkerSize', 8);
semilogy(N_vals, flops_f_ofdm_im, 'g-d', 'LineWidth', 2, 'MarkerSize', 8);
grid on;
legend('OFDM', 'OFDM-IM', 'F-OFDM-IM', 'Location', 'NorthWest');
xlabel('Number of Subcarriers (N)');
ylabel('Computational Complexity (FLOPs)');
title('Computational Complexity Comparison');