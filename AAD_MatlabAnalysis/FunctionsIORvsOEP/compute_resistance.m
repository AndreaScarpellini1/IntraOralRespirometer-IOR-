function results = compute_resistance(flow, pressure,f)
    % Computes resistance R using a linear fit and also fits the nonlinear Roehr equation.
    %
    % Parameters:
    % flow (array): Flow data.
    % pressure (array): Pressure data.
    %
    % Returns:
    % results: Struct with fields 'R_linear', 'k0', 'k1', 'k2'
    
    % Linear Fit: P = R * Flow
    p_linear = polyfit(flow, pressure, 1);
    R_linear = p_linear(1);
    
    % Define the Roehr equation: P = k0 + k1*F + k2*F*|F|
    roehr_eq = @(k, F) k(1) + k(2) * F + k(3) * F .* abs(F);
    
    % Initial Guess for Nonlinear Fit
    k0_init = 0;
    k1_init = R_linear;
    k2_init = 0;
    k_init = [k0_init, k1_init, k2_init];
    
    % Perform Nonlinear Curve Fitting
    opts = optimset('Display', 'off');
    k_fit = lsqcurvefit(roehr_eq, k_init, flow, pressure, [], [], opts);
    
    % Extract fitted parameters
    k0 = k_fit(1);
    k1 = k_fit(2);
    k2 = k_fit(3);
    
    % Generate fit lines for plotting
    flow_range = linspace(min(flow), max(flow), 100);
    linear_fit = R_linear * flow_range;
    roehr_fit = roehr_eq(k_fit, flow_range);
    
    % Plot results
    figure(f);
    scatter(flow, pressure,0.1); hold on;
    plot(flow_range, linear_fit, 'r--', 'LineWidth', 1.5, 'DisplayName', sprintf('Linear Fit: P = %.3f * Flow', R_linear));
    plot(flow_range, roehr_fit, 'g-', 'LineWidth', 1.5, 'DisplayName', sprintf('Roehr Fit: P = %.3f + %.3fF + %.3fF|F|', k0, k1, k2));
    xline(0)
    yline(0)
    xlabel('Flow');
    ylabel('Pressure');
    legend;
    title('Flow vs Pressure Fitting');
    grid on;
    hold off;
    
    % Store results in a struct
    results = struct('R_linear', R_linear, 'k0', k0, 'k1', k1, 'k2', k2);
end
