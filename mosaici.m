function [hi,ri] = mosaici(x,y,h,xi,yi,DeltaX,DeltaY,theta,v,tau,tmax)
%
% MOSAICI: Mosaic interpolation. 
% 
% Usage:  hi = mosaici(x,y,s,xi,yi,Deltax,Deltay,theta,v,tau,tmax)
% 

%***************************************************************************************
% First version: 29/01/2010
% 
% Contact: orodrig@ualg.pt
% 
% Any suggestions to improve the performance of this 
% code will be greatly appreciated. 
% 
%***************************************************************************************

hi = []; 
ri = [];
xt = []; 
yt = []; 

if ( xi(1) < x(1) )||( yi(1) < y(1) )
disp('Initial transect coordinates are outside surface boundaries!')
return
end 

% Get the size of the rectangle containing the surface: 
xmin = min(x); xmax = max(x); deltax = xmax - xmin; nxi = length( xi ); 
ymin = min(y); ymax = max(y); deltay = ymax - ymin; nyi = length( yi ); 

% Get how many tiles are needed to fill the big rectangle 
% with the surface rectangle (we need this so the intermediary 
% states are not dependent on the transect but on the the dimensions
% of the big rectangle):
ntilesx = ceil( DeltaX/deltax );
ntilesy = ceil( DeltaY/deltay );

% Determine the indexes of the tiles along X, crossed by the xtransect: 
first_tileX = ceil( (xi( 1 )-xmin)/deltax );
 last_tileX = ceil( (xi(nxi)-xmin)/deltax );
% Avoid problems with transects along the boundaries: 
if first_tileX == 0, first_tileX = 1; end 
if  last_tileX == 0,  last_tileX = 1; end 

% Determine the indexes of the tiles along Y, crossed by the ytransect:
% first_tileY = ceil( (yi( 1 )-ymin)/deltay );
%  last_tileY = ceil( (yi(nxi)-ymin)/deltay );
% Avoid problems with transects along the boundaries: 
%    if first_tileY == 0, first_tileY = 1; end 
%    if  last_tileY == 0,  last_tileY = 1; end 

% Define tile indexes: 
if first_tileX > last_tileX 
tilesX = [first_tileX:-1:last_tileX];
else
tilesX = [first_tileX: 1:last_tileX];
end

% For each tile along X determine Y tiles crossed by the transect:
for ix = tilesX
    x1 = deltax*(ix-1)+xmin; 
    x2 = x1 + deltax;
   [dummy,indexesx] = find( ( xi >= x1 )&( xi <= x2 ) );
    xix =     xi( indexesx );
    yix =     yi( indexesx );
      n = length( indexesx );
    first_tileY = ceil( (yix(1)-ymin)/deltay );
     last_tileY = ceil( (yix(n)-xmin)/deltay );
% Avoid problems with transects along the boundaries: 
    if first_tileY == 0, first_tileY = 1; end 
    if  last_tileY == 0,  last_tileY = 1; end
    if first_tileY > last_tileY 
    tilesY = [first_tileY:-1:last_tileY];
    else
    tilesY = [first_tileY: 1:last_tileY];
    end    
%Loop over Y tiles to get the interpolated values:
    for iy = tilesY
        y1 = deltay*(iy-1)+ymin; 
        y2 = y1 + deltay;
       [dummy,indexesy] = find( ( yix >= y1 )&( yix <= y2 ) );
        if isempty( indexesy ) ~= 1
           yiy = yix( indexesy ); 
           xiy = xix( indexesy );
           hshifted = shiftsurf(x,y,h,theta,v,tau,tmax,ix,iy,ntilesx,ntilesy);
%          hshifted = h; 
           hxy = interp2(x+deltax*(ix-1),y+deltay*(iy-1),hshifted,xiy,yiy);
           hi = [hi hxy];
           xt = [xt xiy];
           yt = [yt yiy];
        end 
    end
end

ri = sqrt( ( xt - xmin ).^2 + ( yt - ymin ).^2 ); [ri,indexes] = unique(ri); 
hi = hi( indexes ); 
