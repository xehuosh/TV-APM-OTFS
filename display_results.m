%==================================================================
% display surface 
%==================================================================

load Results_surface

if flag_flat == 0

   figure(1)
   mesh(xu,yu,hu), xlabel('x (m)'),ylabel('y (m)'), title('Sea surface')
   
   figure(2)
   mesh(kx,ky,Sk), xlabel('k_x (1/m)'),ylabel('k_y (1/m)'), title('Surface spectrum') 

end 

%==================================================================
% display results 
%==================================================================

load Results


% display the 4 fourier-related representations for one hydrophone 
%==================================================================
if(1)
[Nt,Ntau,Nhyd] = size(h); 
vf = [-(Ntau)/2:(Ntau)/2]/Ntau*fs_x;
vd = [-(Nt-1)/2:(Nt-1)/2]/Nt*fs_h;
TF = fft(h,Ntau,2);
SC = fftshift(fft(h,Nt,1),1);
DF = fftshift(fft(fft(h,Nt,1),Ntau,2),1);
hyd = input('which hydrophone ? : ');
while((hyd~=0)&&(hyd<=length(vhyd))) 
    figure,
    subplot(221),
    imagesc(vtau,vt_h,abs(squeeze(h(:,:,hyd))));
    xlabel('delay (s)');
    ylabel('time (s)');
    title('t-tau representation');
    subplot(222),
    imagesc(vf,vt_h,abs(squeeze(TF(:,:,hyd))));
    xlabel('frequency (Hz)');
    ylabel('time (s)');
    title('t-f representation');
    subplot(223),
    imagesc(vtau,vd,abs(squeeze(SC(:,:,hyd)))); axis xy;
    xlabel('delay (s)');
    ylabel('Doppler (Hz)');
    title('d-tau representation');
    subplot(224),
    imagesc(vf,vd,abs(squeeze(DF(:,:,hyd)))); axis xy;
    xlabel('frequency (Hz)');
    ylabel('doppler (Hz)');
    title('d-f representation');
    hyd = input('which hydrophone ? : ');
end
end
clear all
