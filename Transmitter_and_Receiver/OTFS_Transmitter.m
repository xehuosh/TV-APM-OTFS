clear;
clc;
close all;

%% OTFS参数设置
M = 64;          % 子载波数
N = 30;          % 每帧符号数
df = 15e3;       % 子载波间隔15kHz
padLen = 10;     % 零填充长度
padType = 'ZP';  % 使用零填充方式

%% 导频设计
pilotBin = floor(N/2) + 1;
Pdd = zeros(M, N);
Pdd(1, pilotBin) = exp(1i * pi/4);

%% OTFS调制
txOut = helperOTFSmod(Pdd, padLen, padType);

% 发射信号长度
numSamps = length(txOut);

%% 绘制发射信号波形
figure();

% 子图1：时域波形（实部和虚部）
subplot(1, 2, 1);
t = (0:numSamps-1) / (M * df);  % 时间轴（秒）
plot(t, real(txOut), 'b-', 'LineWidth', 1.5);
hold on;
plot(t, imag(txOut), 'r-', 'LineWidth', 1.5);
xlabel('时间');
ylabel('幅度');
title('时域波形');
legend('实部 (I)', '虚部 (Q)', 'Location', 'best');
grid on;
xlim([0, t(end)]);

% 子图2：幅度波形
subplot(1, 2, 2);
plot(t, abs(txOut), 'k-', 'LineWidth', 1.5);
xlabel('时间 ');
ylabel('幅度');
title('幅度波形');
grid on;
xlim([0, t(end)]);
