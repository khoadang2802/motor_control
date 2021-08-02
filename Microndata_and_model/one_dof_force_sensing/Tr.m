function [r, r_dot, r_ddot] = Tr(s)
        
        spacing = .014; 

        % r = [x0 ... xNt; y0 ... yNt; z0 ... zNt]; 
        
        r(1:3,1) = spacing.*[0; 1; 0];

        r_dot = zeros(3,1);
        r_ddot = zeros(3,1); 




        
%         evenly distributed paralel tendons
%         spacing = .01; 
%         r(1:3,1) = spacing.*[1; 0; 0];
%         r(1:3,2) = spacing.*[cos(2 * pi / 3); sin(2 * pi / 3); 0]; 
%         r(1:3,3) = spacing.*[cos(4 * pi / 3); sin(4 * pi / 3); 0]; 
% 
%         r_dot = zeros(3,3);
%         r_ddot = zeros(3,3); 

    % christmas tree
%     L = .15; 
%     r0 = .02;
%     r1 = .01; 
%     
%     
%     spacing = s * (r1 - r0)/L + r0; 
%     r(1:3,1) = spacing.*[1; 0; 0];
%     r(1:3,2) = spacing.*[cos(2 * pi / 3); sin(2 * pi / 3); 0]; 
%     r(1:3,3) = spacing.*[cos(4 * pi / 3); sin(4 * pi / 3); 0]; 
%     
%     spacing_dot = (r1 - r0)/L; 
%     r_dot(1:3,1) = spacing_dot.*[1; 0; 0];
%     r_dot(1:3,2) = spacing_dot.*[cos(2 * pi / 3); sin(2 * pi / 3); 0]; 
%     r_dot(1:3,3) = spacing_dot.*[cos(4 * pi / 3); sin(4 * pi / 3); 0]; 
%     
%     
%     r_ddot = zeros(3,3);

% 2 tendons helical 
%         period = 2*pi/.7;
% %         period = pi/4; 
%         radius = .03; 
%         r(1:3,1) = radius.*[cos(s*period); sin(s*period); 0]; 
%         r(1:3,2) = radius.*[cos(s*period+pi); sin(s*period+pi); 0];
%         
%         r_dot(1:3,1) = radius.*[-sin(s*period)*period; cos(s*period)*period; 0]; 
%         r_dot(1:3,2) = radius.*[-sin(s*period+pi)*period; cos(s*period+pi)*period; 0]; 
%         
%         r_ddot(1:3,1) = radius.*[-cos(s*period)*period*period; -sin(s*period)*period*period; 0];
%         r_ddot(1:3,2) = radius.*[-cos(s*period+pi)*period*period; -sin(s*period+pi)*period*period; 0]; 
       

% 3 helical tendons
%         period = 2*pi/.7;
% %         period = pi/4; 
%         radius = .03; 
%         r(1:3,1) = radius.*[cos(s*period); sin(s*period); 0]; 
%         r(1:3,2) = radius.*[cos(s*period+2*pi/3); sin(s*period+2*pi/3); 0];
%         r(1:3,3) = radius.*[cos(s*period+2*pi*2/3); sin(s*period+2*pi*2/3); 0];
% 
%         r_dot(1:3,1) = radius.*[-sin(s*period)*period; cos(s*period)*period; 0]; 
%         r_dot(1:3,2) = radius.*[-sin(s*period+2*pi/3)*period; cos(s*period+2*pi/3)*period; 0]; 
%         r_dot(1:3,3) = radius.*[-sin(s*period+2*pi*2/3)*period; cos(s*period+2*pi*2/3)*period; 0]; 
% 
%         r_ddot(1:3,1) = radius.*[-cos(s*period)*period*period; -sin(s*period)*period*period; 0];
%         r_ddot(1:3,2) = radius.*[-cos(s*period+2*pi/3)*period*period; -sin(s*period+2*pi/3)*period*period; 0]; 
%         r_ddot(1:3,3) = radius.*[-cos(s*period+2*pi*2/3)*period*period; -sin(s*period+2*pi*2/3)*period*period; 0]; 

%         

end 