%% This code requires two input files: 1) Marker Frame data and 2) Tedon tension and motor locations
% NOTE: this code requires the cool card data as well
% Frame data should be in mm and q should be in mm
% Tension data is input in grams 


%% This is what it outputs 
% This code will return three variables
%   data - this is a coloumn cell array that contains each test case
%           Each element is a Nm x 3 matrix i.e. it is the position, p(s).
%           The data is oriented such that -y is the direction of gravity
%           The units are in meters 
%           data = {p0, p1, ..., pNd} 
%           where p(s) = [x0 y0 z0; ...; xNm yNm zNm]
%   tau - tendon tensions 
%       units are in N
%   q - motor command
%       units are in mm

%% Parameters 
clear all
Nd = 2; % Number of tests
Nd_i = 10; % Number of pictures for each pose stream
Nm = 9;  % Number of markers (Not including cool card)

%rb = [-13;-10;-17];
%rm = [13;-10;17];
%ri = [x;y;z];
%rb = [-17; 10; 18]; % This is the local offset from the maker origin and it's corresponding location on the robot
%rm = [-17; 10; 18]; % The base marker and the other markers have their x and y flipped :'(                                                                                                                                                                                                                the other markers have their x and y flipped :'(
%rm = [18 ; -10 ; 16];
%rb = [18 ; -10 ; 16];
%rb = [7; -13; 17]; 
%rm = [-13; 7; 17]; 
rm = [18 ; -10 ; 17];
rb = [18 ; -10 ; 17];

%% Importing tau and q

tendon_data = readmatrix('20poses_tension_up_tip_wlc.txt', 'HeaderLines', 1, 'ExpectedNumVariables', 2); 
q = tendon_data(:, 1); 
tau = tendon_data(:, 2)./1000 .* 9.81; 



%% Importing Shape
raw_data = readmatrix('20poses_up_tip_wlc.txt', 'HeaderLines', 1, 'ExpectedNumVariables', (Nm + 1)*12 + 1); % Even though it's called 'ExpectedNumVariables', it's the number of coloumns in the file 

data_shifted = cell(Nd, Nm); % This cell contains all the data before we package up p(s) into data 
data = cell(Nd, 1); 

gbib = eye(4); 
gbib(1:3, 4) = rb; 
gdm = eye(4); 
gdm(1:3, 4) = rm; 


% *NOTE* I removed the cool card marker from the data matrix 
% So the data should contain  raw_data = [# cool_card base t1 t2 .. tNm]
% 1) When we store the marker data we skip the first marker hence j = 2
% 2) the first coloumn of the data is not necessary so we skip it as well

for i = 1:Nd
    
    for j = 2:Nm+1 % it starts at 2 because I am skipping the cool card marker
        
        % For each pose we took Ndi number of pictures. We simply average
        % the data together to get mean_marker
        tmp_marker = raw_data(Nd_i*(i-1) + 1: Nd_i*i, 2 + 12*(j-1): 1 + 12*j); 
        mean_marker = sum(tmp_marker, 1) ./ sum(tmp_marker~=0, 1); 
      
        pmc = mean_marker(1:3)'; 
        Rmc = reshape(mean_marker(4:12), 3, 3)'; 
        gmc = [Rmc pmc; 0 0 0 1]; 
       
        % This part is just a bunch of transformation matrices to get
        % locations along the robot and to have them with reference to the
        % base point on the robot. 
        if j == 2
            gdc = gmc*gbib; 
            gbc = gdc; 
        else
            gdc = gmc*gdm; 
        end 
        
        gdb = gbc^-1 * gdc; 
        pm_shift = gdb(1:3, 4); 
        data_shifted{i, j-1}(1:3) = [pm_shift(3); pm_shift(2); -pm_shift(1)];
    end 

end 




% Finally, for useabilities sake, I collect all the stuff from data_shifted
% into the useable data matrix 
XYZ = zeros(Nm-1, 3); 
for j = 1:Nd
    for i = 1:Nm
        XYZ(i, 1:3) = data_shifted{j, i}(1:3); 
    end 
    data{j} = XYZ./1000; 
end


% This is just plots the last data point so we can check to see if
% everything read in correctly 
figure

plot3(XYZ(:, 1), -XYZ(:, 2), -XYZ(:, 3), 'bo-')

% axis([0 100 0 450 -10 10])
grid on
view(0,90)
daspect([1 1 1])
xlabel('x')
ylabel('y')
zlabel('z')