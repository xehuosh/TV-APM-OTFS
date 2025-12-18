clc;
clear;
close all;
%% 绘制海底地形图
fid = fopen('bathymetry.dat', 'r');
if fid == -1
    error('无法打开文件 bathymetry.dat');
end
nx = fscanf(fid, '%d', 1);
x_coords = fscanf(fid, '%f', nx);
ny = fscanf(fid, '%d', 1);
y_coords = fscanf(fid, '%f', ny);
depth_matrix = zeros(ny, nx);
for i = 1:ny
    depth_matrix(i, :) = fscanf(fid, '%f', nx);
end
fclose(fid);
[X, Y] = meshgrid(x_coords, y_coords);

% 创建新图形窗口
figure(1);

% 绘制二维彩图
pcolor(X, Y, -depth_matrix);
shading interp; % 平滑着色
colormap(jet);
colorbar;

% 紧缩Y轴范围
y_min = min(y_coords);
y_max = max(y_coords);
ylim([y_min, y_max]); % 这将使Y轴范围刚好从数据的最小值到最大值

% 图形标注
title('海底地形二维图', 'FontSize', 16);
xlabel('X (m)');
ylabel('Y (m)');
axis equal tight; % 同时保证比例正确且范围紧缩

figure(2);
Z_corrected = -depth_matrix;
surf(X, Y, Z_corrected, 'EdgeColor', 'none');
colormap(turbo);
colorbar;

title('海底地形三维图', 'FontSize', 16);
xlabel('X (m)');
ylabel('Y (m)');
zlabel('深度 (m)');
daspect([1 1 0.1]);
view(-60, 25);
grid on;

%% 绘制声速剖面图
% 读取sound_speed.dat文件
% 文件格式：第一列为深度(米)，第二列为声速(米/秒)
data = load('sound_speed.dat');

% 提取深度和声速数据
depth = data(:, 1);      % 第一列是深度
sound_speed = data(:, 2); % 第二列是声速

% 创建图形窗口
figure(3);

% 绘制声速剖面图
plot(sound_speed, depth, 'b-', 'LineWidth', 2);
grid on;

% 设置坐标轴范围
xlim([1489, 1497]);   % X轴范围：声速1489-1497米/秒
ylim([0, 205]);       % Y轴范围：深度0-205米
ax = gca;
ax.YDir = 'reverse';  % 设置Y轴方向为反向[1,6,7,8](@ref)

% 添加标签和标题
xlabel('声速 (m/s)');
ylabel('深度 (m)');
title('声速剖面图', 'FontSize', 16);

% 添加网格
grid on;

%% 绘制发射信号
% 读取signal.dat文件
signal_data = load('signal.dat');
real_part = signal_data(:, 1);
imag_part = signal_data(:, 2);
complex_signal = real_part + 1i * imag_part;

% 获取参数（需要根据实际parameters.m文件调整）
fs_x = 10000; % 采样频率，单位：Hz

% 计算基本参数
N = length(complex_signal);
t = (0:N-1) / fs_x; % 时间轴

figure();
plot(t, real(complex_signal), 'b-', 'LineWidth', 1.5);
xlabel('时间 (s)'); ylabel('幅度');
title('发射实值信号x(t)', 'FontSize', 16);
grid on; 