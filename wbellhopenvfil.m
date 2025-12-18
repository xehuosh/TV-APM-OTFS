function wbellhopenvfil( filename, thetitle, source_info, surface_info, ssp_info, bathymetry_info, options )

% Writes Bellhop input (environmental) file. 
%
% SYNTAX: wbellhopenvfil( filename, title, source, surface, ssp, bottom, options )
%

%*******************************************************************************
% Gambelas, 16/06/2008 at 14:30
% Gambelas, 30/11/2010 at 13:00 update
% Written by Tordar 
%*******************************************************************************

envfil = [ filename '.env' ];
atifil = [ filename '.ati' ]; 
btyfil = [ filename '.bty' ];
sspfil = [ filename '.ssp' ];

%*******************************************************************************
% Get source data: 

box      = source_info.box;
xs       = source_info.position; nsources = length( xs );
freq     = source_info.f;
thetas   = source_info.thetas;
beamp    = source_info.p;
beamc    = source_info.comp;

%*******************************************************************************
% Get surface data: 

sitype = surface_info.itype;
  xati = surface_info.x    ; 
  if isempty( xati ) ~= 1 
  nati = length( xati(1,:) );
  else
  nati = 0; 
  end 
  pati = surface_info.p    ;
  
%*******************************************************************************
% Get sound speed data: 

c   = ssp_info.c  ;
z   = ssp_info.z  ; Dmax = max( z );
r   = ssp_info.r  ; nr = length(r);

%*******************************************************************************
% Get bathymetry data:

bitype = bathymetry_info.itype ;
aunits = bathymetry_info.aunits;
  xbty = bathymetry_info.x     ; 
  if isempty( xbty ) ~= 1 
  nbty = length( xbty(1,:) ); 
  else
  nbty = 0;
  end
  pbty = bathymetry_info.p     ;

%*******************************************************************************  
% Get options: 
  options1  = options.options1   ; options1(4) = aunits(2);
  options2  = options.options2   ;
  options3  = options.options3   ;
  options4  = options.options4   ;
array_r     = options.r          ;
array_z     = options.z          ;

m = length( array_r ); 
n = length( array_z ); 

%*******************************************************************************  
% Write the ENVFIL: 
 
fid = fopen(envfil,'w');
fprintf(fid,'%s\n',thetitle);
fprintf(fid,'%f\n',freq);
fprintf(fid,'1 \n');
fprintf(fid,'%s\n', options1);

option1 = options1(2);

switch option1
       case 'Q' 
          [nz nr] = size( c );
          c1 = c(:,1);
          fidssp = fopen(sspfil,'w');
          fprintf(fidssp,'%d\n',nr);
          fprintf(fidssp,'%f ',r);
	  fprintf(fidssp,'\n'   );
	  for ii = 1:nz 
          fprintf(fidssp,'%f ',c(ii,:)); 
          fprintf(fidssp,'\n'   );
	  end
	  fclose(fidssp);
       otherwise
          c1 = c;
end

option2 = options1(3); 

switch option2
       case 'A'   
          fprintf(fid,'%f ',pati);  
          fprintf(fid,' / \n');
end

if numel( options1 ) > 5 
option5 = options1(6);
else
option5 = ' ';
end

switch option5
       case '*'   
          fidati = fopen(atifil,'w');
          fprintf(fidati,'%s\n',sitype);
          fprintf(fidati,'%d\n',nati);
          fprintf(fidati,'%f %f\n',xati);
          fclose(fidati);  
end

fprintf(fid,'51  0.0 ' ); 
fprintf(fid,'%f\n',Dmax );
zc = [z(:)';c1(:)']; 
fprintf(fid,'%f %f / \n' ,zc);

fprintf(fid,'%s', options2);
fprintf(fid,' 0.0\n' );

option1 = options2(2);

switch option1
      case 'A'
          fprintf(fid,'%f ',Dmax);
          fprintf(fid,'%f ',pbty);  
          fprintf(fid,'/ \n');
end 

option2 = options2(3);

switch option2
       case '*'   
          fidbty = fopen(btyfil,'w');
          fprintf(fidbty,'%s\n',bitype);
          fprintf(fidbty,'%d\n',nbty);
          fprintf(fidbty,'%f %f\n',xbty);
          fclose(fidbty);
end

fprintf(fid,'%d\n',nsources);
fprintf(fid,'%f ',xs);
fprintf(fid,'/\n');

m = length( array_r );
n = length( array_z );

fprintf(fid,'%d\n',n);

if n > 1 
fprintf(fid,'%f ',array_z(1));
fprintf(fid,'%f ',array_z(n));
fprintf(fid,' / \n');
else
fprintf(fid,'%f / \n',array_z(1));
end 

fprintf(fid,'%d\n',m);

if m > 1 
fprintf(fid,'%f ',array_r(1));
fprintf(fid,'%f ',array_r(m));
fprintf(fid,' / \n');
else
fprintf(fid,'%f / \n',array_r(1));
end 

fprintf(fid,'%s\n', options3);
fprintf(fid,'%d\n',thetas(1));
fprintf(fid,'%f %f / \n',thetas(2),thetas(3));
fprintf(fid,'%f ',box);
fprintf(fid,'\n');

ioptions4 = isempty( options4 ); 

switch ioptions4
       case 0
       fprintf(fid,'%s ', options4); 
       fprintf(fid,'%f ', beamp(1:3));
       fprintf(fid,'\n'); 
       fprintf(fid,'%d ', beamp(4:5));
       fprintf(fid,'%s ', beamc);
end 

fprintf(fid,'\n');

fclose( fid );
