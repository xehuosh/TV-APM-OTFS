function h = wavespec(f,fp)

if f > fp 
sigma = 0.09;
else
sigma = 0.07; 
end 

if f > fp 
h = ( (fp/f)^5 )*exp( -5/4*( fp/f )^4 )/exp( -5/4 )*exp( -( (f-fp)^2 )/( 2*sigma^2*fp^2 ) ) - 5e-16;
else 
h = 1;
end 

