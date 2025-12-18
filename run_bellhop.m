% get the current time index %
indicetime = round(t(tt)*fs_x+1);

% get source position %
source_x = source_position(1,indicetime);
source_y = source_position(2,indicetime);
source_z = source_position(3,indicetime);
source_data.position = source_z;
source_data.c = interp1(ssp_data.z,ssp_data.c,source_z);

% get receiver position %
receiver_x = receiver_position(1,indicetime);
receiver_y = receiver_position(2,indicetime);
receiver_z = hydrophones + receiver_position(3,indicetime);

% define source-receiver range %
dx = receiver_x - source_x;
dy = receiver_y - source_y;
rangemax = sqrt( dx*dx + dy*dy );

% define transect coordinates %
if flag_flat == 0
   if flag_mosaic == 1 
   np = fix(rangemax/Rs);
   else
   np = nati;
   end
else 
   np = 2; 
end 
xtransect = linspace(source_x,receiver_x,np);
ytransect = linspace(source_y,receiver_y,np);
rtransect = sqrt( ( xtransect - source_x ).^2 + ( ytransect - source_y ).^2 );
%figure(5)
%mesh(xu,yu,hu), hold on
%plot3(xtransect,ytransect,zeros(size(xtransect)))
%plot3(xtransect,ytransect,zeros(size(xtransect)),'o')
%hold off 
% get surface elevation along the transect %
if flag_flat == 0
  if flag_mosaic == 0 % Temporal shift of sea surface:
     hshifted  = shiftsurf(xu,yu,hu,wind.thetaU,cg,t(tt),tmax,1,1,1,1);
     htransect = interp2(xu,yu,hshifted,xtransect,ytransect);
  else                % Temporal and space shifts of sea surface:
    [htransect,rtransect] = mosaici(xu,yu,hu,xtransect,ytransect,rangemax,rangemax,wind.theta,wind.v,t(tt),tmax);
  end 
else 
  htransect = [0 0];
end 

% Non-flat surface: be sure altimetry starts from min to max at range 0: 

if flag_flat == 0 
altimetry(1,:) = rtransect;
altimetry(2,:) = htransect;

altimetry(1,:) = altimetry(1,:) - min(altimetry(1,:));
[altimetry(1,:),indexes] = sort(altimetry(1,:)); 
 altimetry(2,:) = altimetry(2,indexes);
 altimetry(1,:) = altimetry(1,:)/1000; % Bellhop expects this in km...
 surface_data.x = altimetry;
end 

% define bottom bathymetry %
xbtyi = linspace(source_x,receiver_x,nbty);
ybtyi = linspace(source_y,receiver_y,nbty);
bathymetry(1,:) = linspace(0,1.1*rangemax,nbty);
bathymetry(2,:) = interp2(xbty,ybty,zbty,xbtyi,ybtyi);figure(10),plot(bathymetry(1,:),bathymetry(2,:)), view(0,-90)
bathymetry(1,:) = bathymetry(1,:)/1000;
bottom_data.x   = bathymetry;

options.r = rangemax/1000; options.z = receiver_z;

% write the data file and run Bellhop %
system('rm -rf scenario.env')
system('rm -rf scenario.arr')
wbellhopenvfil('scenario',case_title,source_data,surface_data,ssp_data,bottom_data,options);
system('bellhop.exe scenario')
[amp,travel_time,theta0,thetaR,srefl,brefl,mnarr,rz] = read_arrivals_asc( 'scenario.arr', narr );
if(narr<max(mnarr)),
    narr = max(mnarr);
    [amp,travel_time,theta0,thetaR,srefl,brefl,mnarr,rz] = read_arrivals_asc( 'scenario.arr', narr );
end
% format the output data %
travel_time = squeeze(travel_time); travel_time = travel_time';
amplitude   = squeeze(abs(amp))   ; amplitude   =  amplitude.';
phi         = angle(squeeze(amp)) ; phi         =         phi';
if(nhyd==1)
    amplitude   =   amplitude(:).';
    travel_time = travel_time(:)';
    phi         =         phi(:)';
end
