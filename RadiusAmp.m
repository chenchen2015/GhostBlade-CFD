  %% Filename ribbonfin.m
  
  %% Grid dimensions
  clear all;
  clc;
  cla;
  Frozen=0; 
  
  Lx = 6.0; Ly = 3.0; Lz = 3.0;
  Nx = 64*4^2; Ny = 32*4^2; Nz = 32*4^2;
  
  dx = Lx/Nx; dy = Ly/Ny; dz = Lz/Nz;
  Length_Plate = 2.0; Breadth_Plate = 0.4;
  
  Amp=37*pi/180;
  Lambda = Length_Plate/2.5;
  Omega = 1;
  
  NumPtsX = ceil(Length_Plate/dx)
  NumPtsZ = ceil(Breadth_Plate/dz)
  
  lag_pts = 0;


  for i = 1:NumPtsX
      
      X = (i-1)*dx;
      theta = Amp*sin(2*pi*X/Lambda - 2*pi*Omega*0.0+pi/2*0);
      
      for j = 1:NumPtsZ
          
          lag_pts = lag_pts +1;
          Radius(lag_pts) = (j-1)*dz;          
          LagX(lag_pts) = X; 
          LagY(lag_pts) = Radius(lag_pts)*sin(theta);
          LagZ(lag_pts) = -Radius(lag_pts)*cos(theta);
      end
  end
  
 
  
  plot3(LagX,LagY,LagZ,'.')
  view(2);axis equal
  
  %% write it in file
  
  fid = fopen('RibbonFin.vertex','wt');
  fprintf(fid,'%d\n',lag_pts);
  
  for i = 1:length(LagX)
      fprintf(fid,'%12.7E\t\t%12.7E\t\t%12.7E\n',LagX(i), LagY(i), LagZ(i));
  end
  
  fclose(fid);
  
%% Write Radius Amp file

  if(Frozen)
    Radius(:)=0.0;
    Amp=0.0;
  end
     
  fid2 = fopen('RadiusAmp.dat','wt');
  for i=1:length(LagX)
      fprintf(fid2,'%12.7E \t\t %12.7E \t\t %12.7E\n', LagX(i), Radius(i), Amp);
  end
  fclose(fid2);