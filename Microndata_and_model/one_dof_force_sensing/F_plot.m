function F_plot(F_loc, p, R, plot_x, plot_y, plot_z, plot_F)
   
    plot_scale = 4; 

    if nargin < 3
        plot_x = true; 
        plot_y = true; 
        plot_z = true; 
    end 
    
    if nargin < 7
        plot_F = false;
    end 
    
    if plot_x == true
        head_length = 70 * plot_scale * abs(F_loc(1));
        head_width = head_length * .7; 

        F_x_scaled = plot_scale.*R* [F_loc(1); 0; 0]; 
        arrow3( (p - F_x_scaled)', p', 'h-2', head_width, head_length) 
    end 
    
    if plot_y == true
        head_length = 70 * plot_scale * abs(F_loc(2));
        head_width = head_length * .7; 

        F_y_scaled = plot_scale.*R* [0; F_loc(2); 0]; 
        arrow3( (p - F_y_scaled)', p', 'h-2', head_width, head_length) 
    end
    
    if plot_z == true
        head_length = 70 * plot_scale * abs(F_loc(3));
        head_width = head_length * .7; 

        F_z_scaled = plot_scale.*R* [0; 0; F_loc(3)]; 
        arrow3((p - F_z_scaled)', p', 'h-2', head_width, head_length) 
    end
   
    if plot_F == true
        
        head_length = 70 * plot_scale * norm(F_loc);
        head_width = head_length * .7; 

        F_loc_scaled = plot_scale.*R* F_loc; 
        arrow3((p - F_loc_scaled)', p', 'h-2', head_width, head_length) 
        
    end 

end 