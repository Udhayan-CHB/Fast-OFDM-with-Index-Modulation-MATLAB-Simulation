clc; clear; close all;

% Parameters
N = 64; % Number of subcarriers
M_values = [2, 4, 6]; % Number of active subcarriers for FOFDM-IM
modulation_orders = [2, 4]; % QPSK (2 bits/symbol), 16-QAM (4 bits/symbol)

% Bandwidth (normalized)
BW = 1; % Assume 1 Hz bandwidth for normalized comparison

% Spectral Efficiency Calculation
SE_OFDM = zeros(1, length(modulation_orders));
SE_FOFDM_IM = zeros(length(M_values), length(modulation_orders));

for m = 1:length(modulation_orders)
    M = modulation_orders(m); % Bits per symbol in modulation (log2(QAM order))
    
    % OFDM spectral efficiency
    SE_OFDM(m) = (N * M) / BW;
    
    % FOFDM-IM spectral efficiency
    for i = 1:length(M_values)
        K = M_values(i); % Active subcarriers in FOFDM-IM
        B_IM = log2(nchoosek(N, K)); % Index modulation bits
        SE_FOFDM_IM(i, m) = (K * M + B_IM) / BW;
    end
end

% Plot Spectral Efficiency Comparison
figure;
hold on;
plot(modulation_orders, SE_OFDM, 'b-o', 'LineWidth', 2, 'DisplayName', 'OFDM');
for i = 1:length(M_values)
    plot(modulation_orders, SE_FOFDM_IM(i, :), '--s', 'LineWidth', 2, 'DisplayName', sprintf('FOFDM-IM (M=%d)', M_values(i)));
end
xlabel('Modulation Order (Bits per Symbol)');
ylabel('Spectral Efficiency (bps/Hz)');
title('Spectral Efficiency Comparison: FOFDM-IM vs. OFDM');
legend('Location', 'best');
grid on;
hold off;
