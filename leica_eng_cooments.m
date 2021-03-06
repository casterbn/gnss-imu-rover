clear all; close all; clc;
tic;
% number of measured points
N = 10000;

% empty matrices
xyz1_true      = zeros(3,N);
xyz1_new       = zeros(3,N);
T_new          = zeros(1,N);
xyz2_new       = zeros(3,N);
xyz2_error     = zeros(3,N);
T_true         = zeros(1,N);
xyz2_error_mod = zeros(1,N);

% true angles
T_true         = rand(N,1) * pi/6;
T_true         = T_true';
Azimuth_true   = rand(N,1) * 2 * pi;
Azimuth_true   = Azimuth_true';

% pole length
L      = 1.8;
L_xyz  = [L * sin(T_true) .* cos(pi/2 - Azimuth_true);
          L * sin(T_true) .* sin(pi/2 - Azimuth_true);
          L * cos(T_true)];

% true coordinates of the measured point      
x2_true    = randn(N,1) * 0;
y2_true    = randn(N,1) * 0;
z2_true    = randn(N,1) * 0;
xyz2_true  = [ x2_true y2_true z2_true]';

% constants for noise calculation (in meters)
sigma_gnss = 0*(0.018 + 0.024)/2;       
sigma_imu  = (0.011 + 0.017)/2;       

% degrees step for plotting
deg_step = 1; 

% array of tilt angles for plotting
T_array  = [0: deg_step : 90]'*1;                      
T_array  = T_array';

% sums calculation of the coordinates error for each tilt
counter_xyz  = zeros(size(T_array));  

% number of sums calculation for each tilt
sum_counter  = zeros(size(T_array));  

for i = 1:length(T_true)
% true coordinates of the antenna phase center point 
xyz1_true(1:3, i) = xyz2_true(1:3, i) + L_xyz(1:3, i);

% noisy coordinates of the antenna phase center point
xyz1_new(1:3, i)   = xyz1_true(1:3, i) + randn(3, 1) * sigma_gnss;

% noisy tilt angle
T_new(1, i)        = T_true(1, i) + randn(1, 1)*deg2rad(0.3);
Azimuth_new(1, i)  = Azimuth_true(1, i) + randn(1, 1)*deg2rad(1.3);

% noisy coordinates of measured point
L_xyz_tilted(1:3, i)  =  [L * sin(T_new(1, i)) .* cos(pi/2 - Azimuth_new(1, i));
          L * sin(T_new(1, i)) .* sin(pi/2 - Azimuth_new(1, i));
          L * cos(T_new(1, i))];
      
xyz2_new(1:3,i)   = xyz1_new(1:3,i) - L_xyz_tilted(1:3, i);

% coordinates error for measured point 
xyz2_error(1:3, i) = xyz2_true(1:3, i) - xyz2_new(1:3, i);

% 3d coordinates error for measured point 
xyz2_error_mod(i) = sqrt(xyz2_error(1:3, i)'*xyz2_error(1:3, i));

% T_true(i) = rad2deg(T_true(i));

% index of  coordinates error
[tmp,k_arr] = min(abs(T_array - rad2deg(T_true(i))));   
k = k_arr(1);

% rms calculating
counter_xyz(k) = (xyz2_error_mod(i))^2 + counter_xyz(k);
sum_counter(k) = sum_counter(k) + 1;
end

counter_xyz = sqrt(counter_xyz./ sum_counter); 

% plotting
% figure
% plot(rad2deg(T_true),(xyz2_error(1,:)), '.','LineWidth',1);
% title('x2 coordinate error vs Tilt')
% xlabel('Tilt, deg')
% ylabel('x2 coordinate error, m')
% grid on
% 
% figure
% plot(rad2deg(T_true),xyz2_error(2,:), '.','LineWidth',2);
% title('y2 coordinate error vs Tilt')
% xlabel('Tilt, deg')
% ylabel('y2 coordinate error, m')
% grid on
% 
% figure
% plot(rad2deg(T_true),xyz2_error(3,:), '.','LineWidth',2);
% title('z2 coordinate error vs Tilt')
% xlabel('Tilt, deg')
% ylabel('z2 coordinate error, m')
% grid on
T_array_new = T_array(2:30);
counter_xyz_new = counter_xyz(2:30);
figure
plot(T_array,counter_xyz, '-*','LineWidth',1);
title('zyz2 coordinate error rms vs Tilt')
xlabel('Tilt, deg')
ylabel('rms zyz2 coordinate error, m')
plot(T_array_new,counter_xyz_new, '-*','LineWidth',2)
hold on
plot([1,29], [0.008,0.02],'--','LineWidth',2);
% title('zyz2 coordinate error rms vs Tilt')
% xlabel('Tilt, deg')
% ylabel('rms zyz2 coordinate error, m')
grid on

% ylabel('������, ���������� � ���, �')
ylabel('����, ���������� � ���, �')
xlabel('������ ����, ����')
title('')
ylim([0 0.025])
legend('������','������ Leica')

toc;
