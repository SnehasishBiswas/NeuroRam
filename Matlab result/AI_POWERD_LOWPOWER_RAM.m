%% ==============================================================
%  AI-Driven Low-Power RAM (Pattern-Oriented Memory Simulation)
%  Author : Snehasish Biswas
%  Date   : 2025-10-28
%  ==============================================================
clc; clear; close all;

% Simulation Parameters
num_cycles = 200;         % total memory access cycles
num_addr   = 16;          % number of memory addresses
active_thr = 3;           % threshold for activity gating

% Initialize variables
access_freq = zeros(1, num_addr);
power_norm  = zeros(1, num_cycles);   % conventional RAM power
power_ai    = zeros(1, num_cycles);   % AI-optimized RAM power
power_save  = zeros(1, num_cycles);   % efficiency metric

% Simulate random address accesses (biased)
for t = 1:num_cycles
    % Generate address (biased towards a few active ones)
    if rand < 0.7
        addr = randi([1,4]);   % hot region (frequent)
    else
        addr = randi([5,num_addr]); % cold region
    end

    % Update access frequency (learning)
    access_freq(addr) = access_freq(addr) + 1;

    % --- Conventional RAM Power ---
    % all lines active -> full power
    power_norm(t) = num_addr; 

    % --- AI-POM RAM Power ---
    % disable low-activity lines
    gated_lines = sum(access_freq < active_thr);
    power_ai(t) = num_addr - gated_lines;

    % --- Efficiency ---
    power_save(t) = (1 - power_ai(t)/power_norm(t)) * 100;
end

%% ==============================================================
%  Plot the Results
%  ==============================================================
figure('Color','w');
subplot(3,1,1);
plot(1:num_cycles, power_norm, 'r--','LineWidth',1.2); hold on;
plot(1:num_cycles, power_ai, 'b','LineWidth',1.5);
xlabel('Cycle'); ylabel('Active Lines');
legend('Conventional','AI-Optimized');
title('Active Memory Lines Over Time');

subplot(3,1,2);
bar(access_freq,'FaceColor',[0.2 0.6 0.8]);
xlabel('Address Index'); ylabel('Access Frequency');
title('Final Learned Access Pattern (AI-POM)');

subplot(3,1,3);
plot(1:num_cycles, power_save,'g','LineWidth',1.5);
xlabel('Cycle'); ylabel('Power Saving (%)');
title('Dynamic Power Efficiency (AI-POM)');
grid on;

%% ==============================================================
%  Print Results
%  ==============================================================
fprintf('Average Power Saving = %.2f%%\n', mean(power_save));
fprintf('Most Active Addresses = ');
disp(find(access_freq > active_thr));
fprintf('Least Active (Gated) Addresses = ');
disp(find(access_freq <= active_thr));
