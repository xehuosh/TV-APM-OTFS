% 主程序UnderProSim
%
% 基于Bellhop水声工具箱开发的上层框架，用于水下移动节点仿真
% 
% 时变水声传播模型
%
fclose all;
delete('computation_advance.txt');
delete('Results.mat');

%======================================================================
%     Define the Scenario
%======================================================================

%======================================================================
% Surface definition 
%======================================================================
fid   = fopen('surface.dat','r');
nxati = fscanf(fid,'%d\n',[1 1]);  
xati  = fscanf(fid,'%e ' ,[1 nxati]);
nyati = fscanf(fid,'%d\n',[1 1]);  
yati  = fscanf(fid,'%e ' ,[1 nyati]);
for i = 1:nyati
    zati(i,:) = fscanf(fid,'%f',[1 nxati]); 
end 
fclose( fid );

%======================================================================
% Sound speed profile definition 
%======================================================================
load sound_speed.dat 
z = sound_speed(:,1); 
c = sound_speed(:,2); 
[z,indexes] = sort(z);
c = c(indexes); 
if z(1) > 0 
    z = [0   ; z(:)];
    c = [c(1); c(:)];
end

%======================================================================
% Bottom definition 
%======================================================================
fid   = fopen('bathymetry.dat','r');
nxbty = fscanf(fid,'%d\n',[1 1]);  
xbty  = fscanf(fid,'%e ' ,[1 nxbty]);
nybty = fscanf(fid,'%d\n',[1 1]);  
ybty  = fscanf(fid,'%e ' ,[1 nybty]);
for i = 1:nybty
    zbty(i,:) = fscanf(fid,'%f',[1 nxbty]); 
end 
fclose( fid );

xmin = min( xbty ); xmax = max( xbty ); 
ymin = min( ybty ); ymax = max( ybty ); 

dx = abs( xmax - xmin );
dy = abs( ymax - ymin );

fetch = max([dx dy]); clear dx dy xmin xmax ymin ymax

% Don't change this unless you know what you are doing:
if fetch < 1e6 
fetch = 1e6; 
end 

case_title = 'scenarioID';

%======================================================================
% Configuration parameters:
%======================================================================
parameters;

g         = 9.80665;      % 重力加速度(m/s^2)
UxU       =     U*U;      % square of wind speed
theta     = theta*pi/180; % convert degrees to radians 
X         =   fetch;      % wave parameter, do not change
cg        =       0;      % group velocity, modified later if U ~= 0 

wind.U = U; wind.X = X; wind.thetaU = theta; % auxiliary structure

if U > 0 

   fp = (7/2)*( g/U )*( g*X/UxU )^(-0.33); 
   kp = 4*pi^2*fp^2/g; 
   Tp = 1/fp; 
   cp = g*Tp/(2*pi); cg = 0.5*cp; 
   fthreshold = fzero(@(f) wavespec(f,fp),fp);
   kthreshold = 4*pi^2*fthreshold^2/g; 
   Rs        = 1/(2*kthreshold);

end

delta_hyd = max(delta_hyd,0.01);

%======================================================================
% load input signal 
%======================================================================
load signal.dat;
x = signal(:,1) + sqrt(-1)*signal(:,2);
tmax = 1 + length(x)/fs_x; % total duration of the scenario %

clear signal x;

%======================================================================
% Calculate the largest separation    
% between the source and the receiver 
%======================================================================
sourceX = [source_x(1) source_x(1)+source_v(1)*tmax];
sourceY = [source_x(2) source_x(2)+source_v(2)*tmax];
 arrayX =  [array_x(1)  array_x(1)+array_v(1)*tmax];
 arrayY =  [array_x(2)  array_x(2)+array_v(2)*tmax];
   xmin = min( [sourceX arrayX] );
   xmax = max( [sourceX arrayX] );
   ymin = min( [sourceY arrayY] );
   ymax = max( [sourceY arrayY] );   
DX = abs(repmat(arrayX',1,2)-repmat(sourceX,2,1)); dx = max( DX(:) );
DY = abs(repmat(arrayY',1,2)-repmat(sourceY,2,1)); dy = max( DY(:) );

rangemax = sqrt(dx*dx+dy*dy);

%======================================================================
% Prepare a square for the generation of the surface:                     
%======================================================================
if dy < dx 
   dy = dx; ymax = ymin + dy; 
else  
   dx = dy; xmax = xmin + dx; 
end 

%======================================================================
% Generate the surface wave ondulation:
%======================================================================
natimin =   128;
natimax =  1024; 
if U > 0 
   flag_flat = 0; 
   nati = fix( dx/Rs ); 
   naux = log2( nati ); nati = 2^( fix( naux ) + 1 );
   if nati < natimin, nati = natimin; end 
   if nati > natimax
      xmax = natimax*Rs+xmin; 
      ymax = natimax*Rs+ymin;
      nati = natimax;
      range_do_mosaico = xmax - xmin;
      flag_mosaic = 1;
   else 
      flag_mosaic = 0;
   end
   xu   = linspace(xmin,xmax,nati);
   yu   = linspace(ymin,ymax,nati);
   ru   = sqrt( (xu-xmin).^2 + (yu-ymin).^2 );
   [hu,Tp,fm,B,Sk,kx,ky] = sea_surface(xu,yu,wind,'JS',spreading);
   hmin = min( hu(:) ); hmax = max( hu(:) ); wave_height = 0.5*( hmax - hmin );
   hu = hu - min(hu(:));
   % Generate random final states: 
   final_statet = wave_height*randn( size(hu) )/5;
   final_statex = wave_height*randn( size(hu) )/5;
   final_statey = wave_height*randn( size(hu) )/5;
   save final_states final_statet final_statex final_statey 
   figure(1)
   subplot(211),mesh(xu,yu,hu), xlabel('x (m)'),ylabel('y (m)')
   subplot(212),mesh(kx,ky,Sk), xlabel('k_x (1/m)'),ylabel('k_y (1/m)')
   flag_flat = 0;
else
   nati = 2;
   Rs = 0;
   flag_flat   = 1;
   flag_mosaic = 0;
   xu = [xmin  xmax];
   yu = [ymin  ymax]; 
   ru = [0 rangemax];
   hu = [0        0];
   kx = []; ky = []; Sk = []; 
end

save Results_surface flag_flat wind xu yu hu kx ky Sk 

%if(0)
%======================================================================
% check for source & array positioning
%======================================================================
% Verify if the source is above the bottom or below the surface:
last_source_x = source_x + source_v*tmax; 
source_zaty(1) = interp2(xati,yati,zati,     source_x(1),     source_x(2));
source_zaty(2) = interp2(xati,yati,zati,last_source_x(1),last_source_x(2));
source_zbty(1) = interp2(xbty,ybty,zbty,     source_x(1),     source_x(2));
source_zbty(2) = interp2(xbty,ybty,zbty,last_source_x(1),last_source_x(2));
%Test 1: ==============================================================
if source_x(3) < source_zaty(1)
disp('Initial source positioned above the surface...')
return  
end 
%Test 2: ==============================================================
if last_source_x(3) < source_zaty(2)
disp('Final source positioned above the surface...')
return
end
%Test 3: ==============================================================
if source_x(3) > source_zbty(1)
disp('Initial source positioned below the bottom...')
return 
end 
%Test 4: ==============================================================
if last_source_x(3) > source_zbty(2)
disp('Final source positioned below the bottom...')
return
end 
%Time to plot: ========================================================
taux = linspace(0,tmax,10);
source_celerity = norm( source_v );
if source_celerity > 0 
   for i = 1:10
       source_position = source_x + taux(i)*source_v;
       figure(2)
       plot3(source_position(1),source_position(2),-source_position(3),'ko','MarkerSize',16), hold on
       plot3(source_position(1),source_position(2),-source_position(3),'m*','MarkerSize',16)
   end 
   zlabel('Depth (m)')
   title('Source motion')
   box on, grid on
   hold off
else 
   figure(2)
   plot3(source_x(1),source_x(2),-source_x(3),'ko','MarkerSize',16), hold on
   plot3(source_x(1),source_x(2),-source_x(3),'m*','MarkerSize',16)
   surf(xbty,ybty,-zbty); shading interp; colorbar; 
   title('Static Source');
   hold off
end
figure(2)
xlabel('X (m)')
ylabel('Y (m)')
%print -dpng source_position.png
% Array check:
last_array_x  = array_x + array_v*tmax; 
array_zaty(1) = interp2(xati,yati,zati,     array_x(1),     array_x(2));
array_zaty(2) = interp2(xati,yati,zati,last_array_x(1),last_array_x(2));
array_zbty(1) = interp2(xbty,ybty,zbty,     array_x(1),     array_x(2));
array_zbty(2) = interp2(xbty,ybty,zbty,last_array_x(1),last_array_x(2));
%Test 1: ==============================================================
if first_hyd < array_zaty(1)
disp('Start: first hydrophone positioned above the surface...')
return
end
%Test 2: ==============================================================
if last_hyd > array_zbty(1)
disp('Start: last hydrophone positioned below the bottom...')
return
end
%Test 3: ==============================================================
if first_hyd+array_v(3)*tmax < array_zaty(2)
disp('End: first hydrophone positioned above the surface...')
return
end
%Test 4: ==============================================================
if last_hyd+array_v(3)*tmax > array_zbty(2)
disp('End: last hydrophone positioned below the bottom...')
return
end
%Test 5: ==============================================================
if ( array_x(1) < xati(1) )||( array_x(1) > xati(nxati) )
disp('Array initial position along X is outside surface borders...')
return
end
%Test 6: ==============================================================
if ( array_x(2) < yati(1) )||( array_x(2) > yati(nyati) )
disp('Array initial position along Y is outside surface borders...')
return
end
%Test 7: ==============================================================
if ( last_array_x(1) < xati(1) )||( last_array_x(1) > xati(nxati) )
disp('Array final position along X is outside surface borders...')
return
end
%Test 8: ==============================================================
if ( last_array_x(2) < yati(1) )||( last_array_x(2) > yati(nyati) )
disp('Array final position along Y is outside surface borders...')
return
end
%Test 9: ==============================================================
c_at_zs = interp1(z,c,source_x(3));
d(1) = sqrt( sum( (     source_x(1:2)-     array_x(1:2)).^2 ) );
d(2) = sqrt( sum( (     source_x(1:2)-last_array_x(1:2)).^2 ) );
d(3) = sqrt( sum( (last_source_x(1:2)-     array_x(1:2)).^2 ) );
d(4) = sqrt( sum( (last_source_x(1:2)-last_array_x(1:2)).^2 ) );
source_array_range = max( d );
optimal_dtheta = sqrt( c_at_zs/(10*fc*source_array_range) );
optimal_nrays  = fix( 2*source_aperture*(pi/180)/optimal_dtheta );
if source_nrays < optimal_nrays 
warning1 = ['This frequency requires at least ' num2str(optimal_nrays) ' rays!'];
warning2 = ['setting source_nrays = ' num2str(optimal_nrays) ' ...'];
disp( warning1 )
disp( warning2 )
source_nrays = optimal_nrays; 
%return
end 
%======================================================================
%Time to plot:
%======================================================================
array_celerity = norm( array_v );
nhyds = length(first_hyd:delta_hyd:last_hyd);
if array_celerity > 0 
   for i = 1:10
       array_position = array_x + taux(i)*array_v;
       figure(3)
       plot3(array_position(1)*ones(1,nhyds),array_position(2)*ones(1,nhyds),-[array_v(3)*taux(i)+[first_hyd:delta_hyd:last_hyd]],'o','MarkerFaceColor','k'), hold on
    end
    zlabel('Depth (m)')
    title('Source motion')
    box on, grid on
    hold off
else 
    figure(3)
    plot3(array_x(1)*ones(1,nhyds),array_x(2)*ones(1,nhyds),-[first_hyd:delta_hyd:last_hyd],'o','MarkerFaceColor','k'), hold on
    surf(xbty,ybty,-zbty), shading interp 
    title('Static Array')
    hold off
end
figure(3)
xlabel('X (m)')
ylabel('Y (m)')
%print -dpng array_position.png 
clear taux
%Is everything ready for calculations? then let's have a look 
%at the initial positioning of the source and the array: 
figure(4)
% 先绘制海底地形（作为背景）
pcolor(xbty, ybty, -zbty), shading interp, hold on
% 再绘制位置标记（作为前景）
plot(source_x(1), source_x(2), 'ko', 'MarkerSize', 16)
plot(source_x(1), source_x(2), 'm*', 'MarkerSize', 16)
plot(array_x(1), array_x(2), 'o', 'MarkerFaceColor', 'k')
xlabel('X (m)')
ylabel('Y (m)')
title('Source/Array initial positioning')
%print -dpng source_array_position.png 
%end
%======================================================================
% calculate source and receiver position
%======================================================================
twhole = 0:1/fs_x:tmax;
source_position   =   eval_source_position(twhole,source_x,source_v);
receiver_position = eval_receiver_position(twhole, array_x, array_v);
clear twhole

%======================================================================
% create the structure containing the waveguide information 
%======================================================================
Scenario_info.xati = xati;
Scenario_info.yati = yati;
Scenario_info.zati = zati;
Scenario_info.ru   = ru;
Scenario_info.hu   = hu;
Scenario_info.xu   = xu;
Scenario_info.yu   = yu;
Scenario_info.Rs   = Rs;
Scenario_info.wind = wind;
Scenario_info.c    = c;
Scenario_info.z    = z;
Scenario_info.xbty = xbty;
Scenario_info.ybty = ybty;
Scenario_info.zbty = zbty;
Scenario_info.cg   = cg;
Scenario_info.bottomp  = bottom_properties;
Scenario_info.rangemax = rangemax;

Scenario_info.source_nrays      = source_nrays;
Scenario_info.source_aperture   = source_aperture; 
Scenario_info.source_ray_step   = source_ray_step; 
Scenario_info.source_position   = source_position;
Scenario_info.receiver_position = receiver_position;
Scenario_info.hydrophones       = first_hyd:delta_hyd:last_hyd; 

Scenario_info.tmax = tmax;
Scenario_info.fs_x = fs_x; 
Scenario_info.fc   = fc;

Scenario_info.source_array_range = source_array_range; 
Scenario_info.case_title = case_title;
Scenario_info.flags      = [flag_flat flag_mosaic];
%flag_mosaic 
%flag_flat
save('Results','Scenario_info');
clear all;
load('Results','Scenario_info');

%======================================================================
%     Run the Simulation
%======================================================================

%======================================================================
% Generate Impulse Responses with Bellhop
%======================================================================
disp('Generate Impulse Responses with Bellhop');
OceanTVIR(Scenario_info);

%======================================================================
% Filter the input signal
%======================================================================
disp('Filter the input signal');
tic;

load signal.dat;
x = signal(:,1) + sqrt(-1)*signal(:,2);
load('Results','vt_h');
fs_h = 1/vt_h(2);
fs_x = Scenario_info.fs_x;
vhyd = Scenario_info.hydrophones;
save('Results','x','fs_x','fs_h','vhyd','-APPEND');
clear signal vt_h;

for hyd = 1:length(vhyd)
    load('Results','h');
    hhyd = squeeze(h(:,:,hyd));
    clear h;
    eval(['y',num2str(hyd),' = TVFilterhyd(x,hhyd,fs_x,fs_h);']);
    eval(['save Results y',num2str(hyd),' -APPEND']);
    eval(['clear y',num2str(hyd)]);
end

toc;
%======================================================================
