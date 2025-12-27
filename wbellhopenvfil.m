function wbellhopenvfil(filename, thetitle, source_info, surface_info, ssp_info, bathymetry_info, options)
% 写入Bellhop输入环境文件
%
% 语法: wbellhopenvfil(filename, title, source, surface, ssp, bottom, options)

%*******************************************************************************
% Gambelas, 16/06/2008 at 14:30
% Gambelas, 30/11/2010 at 13:00 update
% Written by Tordar 
%*******************************************************************************

% 生成这四个文件，作为Bellhop的输入文件，后三个文件是在生成*.env文件时顺便生成的
envfil = [filename '.env'];   % 主环境文件
atifil = [filename '.ati'];   % 海面边界文件
btyfil = [filename '.bty'];   % 海底边界文件
sspfil = [filename '.ssp'];   % 声速剖面文件

%*******************************************************************************
% 获取声源数据
box      = source_info.box;
xs       = source_info.position; nsources = length(xs);
freq     = source_info.f;
thetas   = source_info.thetas;
beamp    = source_info.p;
beamc    = source_info.comp;

%*******************************************************************************
% 获取海面数据
sitype = surface_info.itype;
xati   = surface_info.x;
if isempty(xati) ~= 1
    nati = length(xati(1,:));
else
    nati = 0;
end
pati = surface_info.p;

%*******************************************************************************
% 获取声速数据
c   = ssp_info.c;
z   = ssp_info.z;
Dmax = max(z);
r   = ssp_info.r;
nr = length(r);

%*******************************************************************************
% 获取海底地形数据
bitype = bathymetry_info.itype;
aunits = bathymetry_info.aunits;
xbty   = bathymetry_info.x;
if isempty(xbty) ~= 1
    nbty = length(xbty(1,:));
else
    nbty = 0;
end
pbty = bathymetry_info.p;

%*******************************************************************************  
% 获取选项参数
options1  = options.options1; options1(4) = aunits(2);
options2  = options.options2;
options3  = options.options3;
options4  = options.options4;
array_r   = options.r;
array_z   = options.z;

m = length(array_r);
n = length(array_z);

%*******************************************************************************  
% 写入主环境文件
fid = fopen(envfil, 'w');
fprintf(fid, '%s\n', thetitle);
fprintf(fid, '%f\n', freq);
fprintf(fid, '1 \n');
fprintf(fid, '%s\n', options1);

% 处理声速剖面选项
option1 = options1(2);
switch option1
    case 'Q'  % 水平变化声速场
        [nz, nr] = size(c);
        c1 = c(:, 1);
        fidssp = fopen(sspfil, 'w');
        fprintf(fidssp, '%d\n', nr);
        fprintf(fidssp, '%f ', r);
        fprintf(fidssp, '\n');
        for ii = 1:nz
            fprintf(fidssp, '%f ', c(ii, :));
            fprintf(fidssp, '\n');
        end
        fclose(fidssp);
    otherwise
        c1 = c;
end

% 处理海面选项
option2 = options1(3);
switch option2
    case 'A'  % 解析海面
        fprintf(fid, '%f ', pati);
        fprintf(fid, ' / \n');
end

% 判断是否需要独立海面文件
if numel(options1) > 5
    option5 = options1(6);
else
    option5 = ' ';
end

switch option5
    case '*'  % 需要独立海面文件
        fidati = fopen(atifil, 'w');
        fprintf(fidati, '%s\n', sitype);
        fprintf(fidati, '%d\n', nati);
        fprintf(fidati, '%f %f\n', xati);
        fclose(fidati);
end

% 写入声速剖面数据
fprintf(fid, '51  0.0 ');
fprintf(fid, '%f\n', Dmax);
zc = [z(:)'; c1(:)'];
fprintf(fid, '%f %f / \n', zc);

% 写入海底选项
fprintf(fid, '%s', options2);
fprintf(fid, ' 0.0\n');

% 处理海底选项
option1 = options2(2);
switch option1
    case 'A'  % 解析海底
        fprintf(fid, '%f ', Dmax);
        fprintf(fid, '%f ', pbty);
        fprintf(fid, '/ \n');
end

% 判断是否需要独立海底文件
option2 = options2(3);
switch option2
    case '*'  % 需要独立海底文件
        fidbty = fopen(btyfil, 'w');
        fprintf(fidbty, '%s\n', bitype);
        fprintf(fidbty, '%d\n', nbty);
        fprintf(fidbty, '%f %f\n', xbty);
        fclose(fidbty);
end

% 写入声源信息
fprintf(fid, '%d\n', nsources);
fprintf(fid, '%f ', xs);
fprintf(fid, '/\n');

% 写入接收器阵列信息
fprintf(fid, '%d\n', n);  % 深度点数
if n > 1
    fprintf(fid, '%f ', array_z(1));
    fprintf(fid, '%f ', array_z(n));
    fprintf(fid, ' / \n');
else
    fprintf(fid, '%f / \n', array_z(1));
end

fprintf(fid, '%d\n', m);  % 距离点数
if m > 1
    fprintf(fid, '%f ', array_r(1));
    fprintf(fid, '%f ', array_r(m));
    fprintf(fid, ' / \n');
else
    fprintf(fid, '%f / \n', array_r(1));
end

% 写入计算选项和输出控制
fprintf(fid, '%s\n', options3);
fprintf(fid, '%d\n', thetas(1));
fprintf(fid, '%f %f / \n', thetas(2), thetas(3));
fprintf(fid, '%f ', box);
fprintf(fid, '\n');

% 写入波束追踪选项
ioptions4 = isempty(options4);
switch ioptions4
    case 0
        fprintf(fid, '%s ', options4);
        fprintf(fid, '%f ', beamp(1:3));
        fprintf(fid, '\n');
        fprintf(fid, '%d ', beamp(4:5));
        fprintf(fid, '%s ', beamc);
end

fprintf(fid, '\n');
fclose(fid);