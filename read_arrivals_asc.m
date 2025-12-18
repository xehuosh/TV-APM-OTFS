function [ amp, delay, SrcAngle, RcvrAngle, NumTopBnc, NumBotBnc, narrmat, Pos ] ...
    = read_arrivals_asc( ARRFIL, narrmx )
% 修改版本，2022版的Bellhop生成的*.arr文件格式有变动，确保能正常读取
% Read the arrival time/amplitude data computed by BELLHOP
% Modified to support both old (pre-2012) and new (2020+) Bellhop versions

% useage:
%[ amp, delay, SrcAngle, RcvrAngle, NumTopBnc, NumBotBnc, narrmat, Pos ] ...
%    = read_arrivals_asc( ARRFIL, narrmx );
%
% You must set the string ARRFIL specifying the Arrivals File
% narrmx specifies the maximum number of arrivals allowed
% mbp 9/96, modified for new Bellhop format

if nargin == 1
    narrmx = 200;
end

fid = fopen( ARRFIL, 'r');	% open the file
if ( fid == -1 )
    errordlg( 'read_arrivals_asc: Arrivals file cannot be opened' )
end

% Check file format version by reading first line
% New format starts with '2D' or '3D' flag, old format starts with frequency
first_word = fscanf( fid, '%s', 1 );
frewind(fid); % Rewind to beginning

% Detect format based on first word
is_new_format = false;
if strcmp(first_word, '''2D''') || strcmp(first_word, '''3D''')
    is_new_format = true;
    % Skip the 2D/3D flag
    fscanf( fid, '%s', 1 );
end

% read the header info
freq = fscanf( fid, '%f', 1 );
Nsd  = fscanf( fid, '%i', 1 );
Pos.s.depth   = fscanf( fid, '%f', Nsd );
Nrd  = fscanf( fid, '%i', 1 );
Pos.r.depth   = fscanf( fid, '%f', Nrd );
Nrr  = fscanf( fid, '%i', 1 );
Pos.r.range   = fscanf( fid, '%f', Nrr );

% Store frequency in Pos structure for compatibility
Pos.freq = freq;

% loop to read all the arrival info (delay and amplitude)
amp       = zeros( Nrr, narrmx, Nrd, Nsd );
delay     = zeros( Nrr, narrmx, Nrd, Nsd );
SrcAngle  = zeros( Nrr, narrmx, Nrd, Nsd );
RcvrAngle = zeros( Nrr, narrmx, Nrd, Nsd );
NumTopBnc = zeros( Nrr, narrmx, Nrd, Nsd );
NumBotBnc = zeros( Nrr, narrmx, Nrd, Nsd );
narrmat   = zeros( Nrr, Nrd, Nsd );

for isd = 1:Nsd
    % max number of arrivals for this source
    narrmx2 = fscanf( fid, '%i', 1 );
    
    for ird = 1:Nrd
        for ir = 1:Nrr
            narr = fscanf( fid, '%i', 1 );    % number of arrivals
            narrmat( ir, ird, isd ) = narr;
            
            if narr > 0   % do we have any arrivals?
                if is_new_format
                    % New format: 8 columns
                    % 1: amplitude, 2: phase(deg), 3: delay real, 4: delay imag
                    % 5: SrcDeclAngle, 6: RcvrDeclAngle, 7: NumTopBnc, 8: NumBotBnc
                    da = fscanf( fid, '%f', [ 8, narr ] );
                    narr = min( narr, narrmx );
                    narrmat( ir, ird, isd ) = narr;
                    
                    % Store data
                    amp(       ir, 1:narr, ird, isd ) = da( 1, 1:narr ) .* exp( 1i * da( 2, 1:narr ) * pi/180 );
                    delay(     ir, 1:narr, ird, isd ) = da( 3, 1:narr );  % Use real part only for compatibility
                    SrcAngle(  ir, 1:narr, ird, isd ) = da( 5, 1:narr );
                    RcvrAngle( ir, 1:narr, ird, isd ) = da( 6, 1:narr );
                    NumTopBnc( ir, 1:narr, ird, isd ) = da( 7, 1:narr );
                    NumBotBnc( ir, 1:narr, ird, isd ) = da( 8, 1:narr );
                else
                    % Old format: 7 columns
                    % 1: amplitude, 2: phase(deg), 3: delay, 4: SrcAngle
                    % 5: RcvrAngle, 6: NumTopBnc, 7: NumBotBnc
                    da = fscanf( fid, '%f', [ 7, narr ] );
                    narr = min( narr, narrmx );
                    narrmat( ir, ird, isd ) = narr;
                    
                    % Store data
                    amp(       ir, 1:narr, ird, isd ) = da( 1, 1:narr ) .* exp( 1i * da( 2, 1:narr ) * pi/180 );
                    delay(     ir, 1:narr, ird, isd ) = da( 3, 1:narr );
                    SrcAngle(  ir, 1:narr, ird, isd ) = da( 4, 1:narr );
                    RcvrAngle( ir, 1:narr, ird, isd ) = da( 5, 1:narr );
                    NumTopBnc( ir, 1:narr, ird, isd ) = da( 6, 1:narr );
                    NumBotBnc( ir, 1:narr, ird, isd ) = da( 7, 1:narr );
                end
            end
        end    % next receiver range
    end        % next receiver depth
end    % next source depth

fclose( fid );