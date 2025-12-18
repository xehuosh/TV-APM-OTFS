function shifteds = shiftsurf(x,y,s,theta,v,tau,tmax,tilex,tiley,ntilesx,ntilesy)
%
% SHIFTSURF: shifts a surface along the direction theta, for a given velocity    
% v and time instant tau. 
% 
% Usage:  ss = shiftsurf(x,y,s,theta,v,tau,tmax,nx,ny,NX,NY)
% 
%  where x and y are vectors defining the surface s, theta is the direction 
%  of propagation, v is the velocity of propagation and tau is the propagation
%  time. The function assumes a periodicity of the surface. 
% 
%  Example: 
%  xmin = -5; xmax = 5; nx = 101; x = linspace(xmin,xmax,nx); y = x;
%  v = 1; theta = pi/4; ntau= 51; tau = linspace(0,1,ntau);  
%  [X,Y] = meshgrid(x,y); Rsq = X.^2 + Y.^2; S = exp(-Rsq);  
%  for i = 1:ntau
%  ss = shiftsurf(x,y,s,theta,v,tau(i),tmax,1,1,1,1);
%  figure(1)
%  mesh(x,y,ss), pause(0.1)
%  end 

%***************************************************************************************
% First version: 26/01/2010
% 
% Contact: orodrig@ualg.pt
% 
% Any suggestions to improve the performance of this 
% code will be greatly appreciated. 
% 
%***************************************************************************************

shifteds = []; 

imunit = sqrt( -1 ); 

nx = length( x ); xmin = min( x ); xmax = max( x ); Deltax = xmax -xmin; 
ny = length( y ); ymin = min( y ); ymax = max( y ); Deltay = ymax -ymin; 

% Load the final states: they will be used to interpolate intermediary 
% states in time and space. Therefore the stochastic nature of the surface 
% is preserved, while allowing surface replication at two equal time instants.   
% Time values are used to introduce perturbations in the wavenumbers, 
% replicating surface motion; 
% tile values are used to introduce perturbations in phase, so the tiled surface 
% is not an exact copy of the original. 
 
load final_states 

perturbationt = final_statet*tau/tmax;
if ( ntilesx > 1 )&( tilex > 1 ) 
perturbationx = final_statex*tilex/ntilesx;
else
perturbationx = zeros( size( final_statex ) );
end 
if ( ntilesy > 1 )&( tiley > 1 ) 
perturbationy = final_statey*tiley/ntilesy;
else
perturbationy = zeros( size( final_statey ) );
end 

dx    = Deltax/nx;
dfx   = 1/Deltax ;
fsx   = 1/dx;
kxmax = 1/( 2*dx ); 
kx    = linspace(-kxmax,kxmax,nx);
Kx    = repmat(kx,ny,1); 
Kx    = Kx.*( 1 + perturbationt );

dy    = Deltay/ny;
dfy   = 1/Deltay ;
fsy   = 1/dy;
kymax = 1/( 2*dy ); 
ky    = linspace(-kymax,kymax,ny);
Ky    = repmat(ky',1,nx);
Ky    = Ky.*( 1 + perturbationt );

% Shift along X due to the wave motion and space phase shift: 

shiftx = v*cos( theta )*tau;
 
S               = dx * fftshift( fft2( fftshift( s ) ) );
shifting_factor = exp( imunit * ( Kx * shiftx + perturbationx ) );
shiftedS        = S .* shifting_factor;
shifteds        = real( fsx * ifftshift( ifft2( ifftshift( shiftedS ) ) ) );

% Shift along Y due to the wave motion and space phase shift: 

shifty = v*sin( theta )*tau;
 
S               = dy * fftshift( fft2( fftshift( shifteds ) ) );
shifting_factor = exp( imunit * ( Ky * shifty + perturbationy ) );
shiftedS        = S .* shifting_factor;
shifteds        = real( fsy * ifftshift( ifft2( ifftshift( shiftedS ) ) ) );

