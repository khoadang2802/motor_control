function Tendon_Plotter(y, amp, mu, sigma, loadplot, L)

    figure 
    if nargin < 2
        amp = [0 0];
        mu = 0; 
        sigma = 0; 
    end 
    
    if nargin < 5
        loadplot = false; 
    end 
    
    if nargin < 6
        L = .15; 
    end 
    
    %% Plot rod and tendons
    plot3(y(:,1), y(:,2), y(:,3), 'k', 'linewidth',5)
    hold on
    
    s_y = linspace(0, L, length(y)); 
    tendon = zeros(3, length(y), 2); 
 
    for it = 1:length(y)
       
        rt = Tr(s_y(it)); 
        for jt = 1:size(rt, 2)
            
            tendon(:, it, jt) = reshape(y( it, 4:12), 3, 3)*rt( :, jt) + y( it, 1:3)'; 
            
        end 
    end 
        
    for meps = 1:size(rt, 2)
        plot3(tendon( 1, :, meps), tendon( 2, :, meps), tendon( 3, :, meps), 'r', 'LineWidth', 2)
    end 
    
    axis([-.1 .1 -.1 .1 0 .18])
%     view(-143, 23)
    view(0, 0)
    daspect([1 1 1])
    grid on

    zlabel('z(m)')
    xlabel('x(m)')
    ylabel('y(m)')

    %% Plot dist load
    
    scale = .1; 

    s_load = linspace(0, L, 300);
    for j = 1:length(s_load)

        fx = distLoad(s_load(j), amp(:,1), mu, sigma); 
        fy = distLoad(s_load(j), amp(:,2), mu, sigma); 
        y_interped = interp1(s_y, y, s_load(j)); 

        butts(j) = fx; 
        try 
            load_tmp = reshape(y_interped(4:12),3,3) * [fx; fy; 0];
        catch
            disp('butts')
        end 

        Arrows(j,1:3) = scale.*load_tmp'; 
        load(j,1:3) = y_interped(1:3) - Arrows(j,1:3); 

    end 


    plot3(load(:,1), load(:,2), load(:,3),'b','LineWidth',1)
    [~, index] = max(abs(butts));
    s_load(index);

    for i = 10:10:length(Arrows)
        quiver3(load(i,1), load(i,2), load(i,3), Arrows(i,1), Arrows(i,2), Arrows(i,3),0,'b-','LineWidth',1,'MaxHeadsize',2)

    end 

%% plot load on a 2d plot

    if loadplot == true
        s_load2 = linspace(0, L, 200); 
        figure; plot(s_load2, distLoad(s_load2, amp(:,1), mu, sigma))
    end
    
    %% load and tendon placement functions
    function f = distLoad(s, amp, mu, b)

            f = 0; 
            for i = 1:length(amp)
                f = f + amp(i) .* exp( -b .* (s-mu(i)).^2); 
            end 
    end 

end 