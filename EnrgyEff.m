clc; clear; close all;

% Parameters
N = 64; % Total subcarriers
M_values = [2, 4, 6]; % Active subcarriers for FOFDM-IM
modulation_orders = [2, 4]; % QPSK (2 bits/symbol), 16-QAM (4 bits/symbol)

% Assume normalized power per subcarrier
P_total = 1; % Total power in watts for OFDM
P_per_subcarrier = P_total / N; % Power per subcarrier

% Bandwidth (normalized)
BW = 1; % Assume 1 Hz bandwidth for comparison

% Energy Efficiency Calculation
EE_OFDM = zeros(1, length(modulation_orders));
EE_FOFDM_IM = zeros(length(M_values), length(modulation_orders));

for m = 1:length(modulation_orders)
    M = modulation_orders(m); % Bits per symbol in modulation (log2(QAM order))
    
    % OFDM energy efficiency
    SE_OFDM = (N * M) / BW; % Spectral efficiency of OFDM
    P_OFDM = N * P_per_subcarrier; % Total power for OFDM
    EE_OFDM(m) = SE_OFDM / P_OFDM; % Energy efficiency
    
    % FOFDM-IM energy efficiency
    for i = 1:length(M_values)
        K = M_values(i); % Active subcarriers
        B_IM = log2(nchoosek(N, K)); % Index modulation bits
        SE_FOFDM_IM = (K * M + B_IM) / BW; % Spectral efficiency of FOFDM-IM
        P_FOFDM_IM = K * P_per_subcarrier; % Total power for FOFDM-IM
        EE_FOFDM_IM(i, m) = SE_FOFDM_IM / P_FOFDM_IM; % Energy efficiency
    end
end

% Plot Energy Efficiency Comparison
figure;
hold on;
plot(modulation_orders, EE_OFDM, 'b-o', 'LineWidth', 2, 'DisplayName', 'OFDM');
for i = 1:length(M_values)
    plot(modulation_orders, EE_FOFDM_IM(i, :), '--s', 'LineWidth', 2, 'DisplayName', sprintf('FOFDM-IM (M=%d)', M_values(i)));
end
xlabel('Modulation Order (Bits per Symbol)');
ylabel('Energy Efficiency (bits/Joule)');
title('Energy Efficiency Comparison: FOFDM-IM vs. OFDM');
legend('Location', 'best');
grid on;
hold off;
