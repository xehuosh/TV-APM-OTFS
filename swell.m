function [s,SK,kx,ky] = swell(x,y,hs,theta,spreading);

%
% SWELL: generates sea surface swell realizations. 
% 
% Usage:  [s,Sk,kx,ky] = swell(x,y,hs,theta,spreading)
% 
%  where x and y are vectors defining the surface grid, hs is the significant wave height, 
%  theta represents the direction of swell propagation, and spreading defines the angular 
%  spreading of the swell spectrum ('none' for no spreading, 'jack' for Jackson spreading).
%  The output is a matrix s (size(s) = [length(y) length(x)]), the spectrum Sk and the 
%  wavenumber vector arguments kx and ky, which define the grid of Sk.
% 
%  Examples: 
%  nx = 200; xmin = 0; xmax = 500; x = linspace(xmin,xmax,nx); 
%  ny = 200; ymin = 0; ymax = 500; y = linspace(ymin,ymax,ny);
%  [s,Sk,kx,ky] = swell(x,y,4,pi/4,'none');
%  figure(1)
%  subplot(211),mesh(x,y,s),ylabel('y(m)'),xlabel('x(m)') 
%  subplot(212),mesh(kx,ky,Sk),ylabel('ky (1/m)'),xlabel('kx (1/m)') 
% 
% References:
% 1) SWIMSAT: A Real-Aperture Radar to Measure Directional Spectra of
%    Ocean Waves from Space (Main Characteristics and Performance Simulation)
%    D. Hauser et al. 2001

%***************************************************************************************
% First  version: 26/07/2011
% 
% Contact: orodrig@ualg.pt
% 
% Any suggestions to improve the performance of this 
% code will be greatly appreciated. 
% 
%***************************************************************************************
s   = []; 
Sk  = s; 
kx  = s;
ky  = s;

imunit = sqrt( -1 );

kpeak = 2*pi/200; 
sigmal = 0.006;

nx = length( x );
ny = length( y );

%======================================================================
% Surface generation: 

dx = x(2) - x(1);
kxmax = 1/( 2*dx );
kx = linspace(-kxmax,kxmax,nx);
dy = y(2) - y(1);
kymax = 1/( 2*dy );
ky = linspace(-kymax,kymax,ny);
[Kx,Ky] = meshgrid(kx,ky);
K = sqrt( Kx.^2 + Ky.^2 ); 

%======================================================================
%  Calculate the spectrum in the wavenumber domain:

SK = hs*hs/( 16*sqrt(2*pi)*sigmal )*exp( -0.5*( ( K-kpeak)/sigmal ).^2 );

%======================================================================
%  A real sea surface requires a symmetric spectrum in the wavenumber 
%  domain; thus, wherever required, additional calculations will ensure
%  that the spreading matrix is indeed symmetrical:

THETA = angle( Kx+imunit*Ky ) - theta;

switch spreading
   
case 'none' % no spreading 
        
     D = ones(size(K)); 
   
case 'jack' % Jackson spreading
        
     D = cos( THETA ).^14;

otherwise
   
     disp('Unknown swell spreading.')
   
end

%======================================================================
% Get the power spectrum: 

D = D + fliplr( flipud( D ) ); % make it symmetric
D = D/max( D(:) )*2/pi; % spreading normalization
SK = SK.*D;             % power spectrum(k,theta) = spectrum(k)*spreading(theta)

%======================================================================
% Get the surface realization from the spectrum: 

white_noise     = unifrnd(-127,127,ny,nx)/127;
WHITE_NOISE     = fft2( white_noise );
NOISE_amplitude =  abs( WHITE_NOISE );

NOISE_energy = sum( WHITE_NOISE(:).^2 );
WHITE_NOISE  = WHITE_NOISE/NOISE_energy; 

centered_WHITE_NOISE = fftshift( WHITE_NOISE );
NOISE_phase = angle( centered_WHITE_NOISE );

% Modulate noise amplitude with the power spectrum: 
NOISE_amplitude = NOISE_amplitude .* SK;

% Randomize modulated noise in the wavenumber space combining 
% modulated amplitudes with original phases: 
NOISE_ipart = NOISE_amplitude .* sin( NOISE_phase );
NOISE_rpart = NOISE_amplitude .* cos( NOISE_phase );

filtered_NOISE = NOISE_rpart + imunit*NOISE_ipart;
filtered_NOISE = fftshift( filtered_NOISE );

% Get the 2D surface through an inverse fft:  
s = ifft2( filtered_NOISE );
s = real( s );
maxs = max( abs(s(:)) );
s = hs*s/maxs; % Normalization to hs
