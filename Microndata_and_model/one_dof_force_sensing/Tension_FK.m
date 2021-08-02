%% This is a forward Kinetostatic model for a Tendon Robot
% This code requires the files: Tr.m, F_plot.m, Tendon_Plotter.m, and arrow3.m

%% Inputs
%   tau - tendon tensions in N. It is Nt x 1
%   robotparameters - [rod length, radius of rod, E, G]
%   guess_init - initial guess for base wrench (w0)
%
%   Tr(s) is the function where the tendon routing is determined 

%% Outputs
%   w0 - base wrench i.e. correct guess
%   q - tendon lengths. It is Nt x 1
%   y - [ Rp00 n0 m0 q0; ... ;pN RN nN mN qN]


function [w0, q, y] = Tension_FK(tau, robotparameters, guess_init)
    
    % Here we can define tip load and distributed loads
    sigma = 2000; 
    amp = [0 0; 0 0]; % Nl x 2 [ax_0 ay_0; ... ; ax_Nl ay_Nl]; 
    mu = [0; 0]; % Nl x 1 [mu_0; ... ; mu_Nl]; 
 
    F_loc = [0;  25.4905./1000.*9.81; 0]; 


    
    if nargin < 2
        robotparameters = [.15, 1.4/2000, 207e9, 74e9,0];
    end  
    
    if nargin < 3
        guess_init = zeros(6, 1);
    end 
    
    Nt = size(Tr(0), 2); % Number of Tendons 
    L = robotparameters(1); 
    ro = robotparameters(2);% Rod outer radius in m
    ri = 0/(2*1000); % For a tube this is the inner radius in m 
    I = 1/4*pi*(ro^4-ri^4); % Area Moment 
    Aa = pi*(ro^2-ri^2); % Area 
    J = 2*I; % Polar Moment 


    %Rod parameters Music Wire 
    E = robotparameters(3); % Young's Modulus Pa
    Ga = robotparameters(4); % Shear Modulus Pa
    rho = robotparameters(5); %rod density kg/m
    % Inverses of the stiffness matrices
    K_bt = [E*I 0 0; 0 E*I 0; 0 0 J*Ga]; 
    K_se = [Ga*Aa 0 0; 0 Ga*Aa 0; 0 0 E*Aa]; 

      
    
    
    
    
    %% Manipulator Solve

    % Setting up solver
    optionsFsolve=optimset('Display','Iter','TolFun',1e-18,'algorithm','levenberg-marquardt');
    get_resAnon = @(guess_init) get_res(guess_init,tau, L, K_se, K_bt, Nt);
    
    % Running solver 
    tic
    [correct_guess,residual,exitflag,~,Jacobian] = fsolve(get_resAnon,guess_init,optionsFsolve);
    toc

    
    %% Collecting and outputting results 
    w0 = correct_guess'
    q = y(end, 19: 18 + Nt)

    Tendon_Plotter(y, amp, mu, sigma)
    hold on
   
    F_plot(F_loc + 1e-10, y(end, 1:3)', reshape(y(end, 4:12), 3, 3), true, true, true); 





%% -------------------------------------------------------------------------------------------------------------------------------------------------
%% -------------------------------------------------------------------------------------------------------------------------------------------------


% Hat Function
    function uhat=hat(u)
        uhat = [0,-u(3),u(2);u(3),0,-u(1);-u(2),u(1),0];
    end

% Vee Function
    function u = vee(uhat)
        u = [uhat(3,2);uhat(1,3);uhat(2,1)];
    end


% Here are the Cosserat Rod Equations 
    function y_dot = deriv(s, y, tau, K_se, K_bt, Nt)
        
        u_star = [0; 0; 0]; 
        v_star = [0; 0; 1]; 
        u_star_dot = [0; 0; 0];
        v_star_dot = [0; 0; 0]; 
        
        % Turn ODE input into named variables
        %p = [y(1);y(2);y(3)];
        R = [y(4) y(7) y(10);y(5) y(8) y(11);y(6) y(9) y(12)];
        n = [y(13);y(14);y(15)];
        m = [y(16);y(17);y(18)];
        
        v = K_se^-1 * R' * n + [0; 0; 1]; 
        u = K_bt^-1 * R' * m; 
        
        % Distributed load is defined here 
        fx_loc = distLoad(s, amp(:, 1), mu, sigma);
        fy_loc = distLoad(s, amp(:, 2), mu, sigma);
        
        f = R * [fx_loc; fy_loc; 0] + [0 ; -9.81* rho ; 0];
        
        
   
        
        % Compute the easy state variable derivatives 
        p_dot = R*v;
        R_dot = R*hat(u);
       
        
        % Now it's time to compute out the stuff for v_dot and u_dot
        [r, r_dot, r_ddot] = Tr(s); % Rows x, y, z coloumns are tendon 

        A = zeros(3,3); 
        B = A; 
        G = A; 
        H = A; 
        a = 0; 
        b = 0; 
        
        s_dot = zeros(Nt, 1); 
        
        for ti = 1:Nt
            pb_dot = hat(u)*r(:,ti) + r_dot(:,ti) + v; 
            Ai = -tau(ti).*hat(pb_dot)^2./norm(pb_dot)^3; 
            Bi = hat(r(:,ti))*Ai; 
            
            ai = Ai*(hat(u)*pb_dot + hat(u)*r_dot(:,ti) + r_ddot(:,ti)); 
            bi = hat(r(:,ti))*ai; 
            
            A = A + Ai; 
            B = B + Bi; 
            a = a + ai; 
            b = b + bi; 
            
            G = G - Ai*hat(r(:,ti)); 
            H = H - Bi*hat(r(:,ti));        
            
            s_dot(ti) = norm(hat(u) * r(:,ti) + r_dot(:,ti) + v); 
        end 
        
        c = K_bt*u_star_dot - hat(u)*K_bt*(u-u_star) - hat(v)*K_se*(v-v_star) - b; 
        
        d = K_se*v_star_dot - hat(u)*K_se*(v-v_star) - R'*f - a; 
        
        superMatrix = [K_se+A, G; B, K_bt+H]; 
        
        vu_dot = superMatrix\[d;c]; 
        
        
        % Convert u_dot and v_dot into n_dot and m_dot 
        n_dot = R_dot * K_se * (v - [0; 0; 1]) + R * K_se * vu_dot(1:3); 
        m_dot = R_dot * K_bt * u + R * K_bt * vu_dot(4:6); 
        
        
                
        y_dot = [p_dot; reshape(R_dot,9,1); n_dot; m_dot; s_dot];
    end





%% Residual Function
% So this is what defines our Boundary conditions. All the equations in
% here are set such that if the BVP is sovled they should equal zero. 
% Also also, fsolve automatically takes the residual and does the sum of
% squares, so we don't have to define it in the function. 
    function res = get_res(guess, tau, L, K_se, K_bt, Nt)
 
 
        pts = 100; % Number of integration points 
        
        % 'y' is the matrix that represents a rod is a pts x 18+Nt matrix. 
        % Where the coloumns are the states of the rod: (P R v u q)
        % and the row represents the arc length along the rod. So row 0 is
        % the base of the rod and row pts is the distal end of the rod
        

        % Set initial conditions
        y_init = zeros(18 + Nt, 1); % p_init
        y_init(13:15) = guess(1:3); % n_init
        y_init(16:18) = guess(4:6); % m_init
        y_init([4 8 12]) = 1; % Rotation is initially identity 
             
        
        % Solve IVP 
        [~,y] = ode45(@(t,y) deriv(t, y, tau, K_se, K_bt, Nt),linspace(0,L,pts),y_init);

        
        
        % Residual computation 
        R_L = reshape(y(end,4:12),3,3); 
        v_L = K_se^-1 * R_L' * y(end,13:15)' + [0; 0; 1]; 
        u_L = K_bt^-1 * R_L' * y(end,16:18)'; 
        
        F = R_L * F_loc; 
        
        res(1:3,1) = -y(end, 13:15)' + F; 
        res(4:6,1) = -y(end, 16:18)' ; 

        % Cacluating the tendon tip wrench
        [r, r_dot] = Tr(L); 
        for i = 1:Nt
            p_dot = R_L * (hat(u_L)*r(:,i) + r_dot(:,i) + v_L);
            res(1:3,1) = res(1:3,1) - tau(i) .* p_dot./norm(p_dot); 
           
            res(4:6,1) = res(4:6,1) - tau(i) .* hat(R_L*r(:,i)) * p_dot./norm(p_dot); 
        end 
     
    end 


%% distLoad function
    function f = distLoad(s, amp, mu, sigma)

            f = 0; 
            for i = 1:length(amp)
                f = f + amp(i) .* exp( -sigma .* (s-mu(i)).^2); 
            end 
    end 
      
end 
