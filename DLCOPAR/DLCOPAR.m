function [D, X, rt] = DLCOPAR(Y, Y_range, opts)
% function [D, X, rt] = DLCOPAR(Y, Y_range, opts)
% -----------------------------------------------
% Author: Tiep Vu, thv102@psu.edu, 5/11/2016
%         (http://www.personal.psu.edu/thv102/)
% -----------------------------------------------
    if nargin == 0
        addpath(fullfile('..', 'utils'));
        addpath(fullfile('..', 'ODL'));
        addpath(fullfile('..', 'DLSI'));
        C = 10;    N = 7;    d = 30;
        k = 7;
        k0 = 10;
        opts.k        = k;
        opts.k0       = k0;
        opts.lambda   = 0.0001;
        opts.eta      = 0.01;
        opts.gamma    = 0.01;
        opts.max_iter = 5;
        opts.verbal   = true;
        opts          = initOpts(opts);
        
        Y = normc(rand(d, C*N));
        Y_range = N*(0:C);        
    end
    %%
    C = numel(Y_range) - 1;
    D_range = opts.k*(0:C);
    % --------------- append D0 -------------------------
    D_range_ext = [D_range D_range(end)+opts.k0];    
    opts.D_range_ext = D_range_ext;    
    %% ================== block: init ==========================    
    optsinit          = opts;
    optsinit.max_iter = 30;
    optsinit.verbal   = false;
    [D, X]            = DLCOPAR_init(Y, Y_range, optsinit);
    %% options for updating X and D 
    optsX        = opts;
    optsX.verbal = 0;
    optsD        = opts;
    optsD.verbal = 0;
    %% MAIN alg
    iter         = 0;
    tic
    while iter < opts.max_iter 
        iter = iter + 1;
        
        %% ========= update X ==============================
        if opts.verbal
            fprintf('iter = %3d | updating X...', iter);
        end 
        X = DLCOPAR_updateX(Y, Y_range, D, X, optsX);
        t = toc;     
        if t > 20*3600
            break;
        end 
        if opts.verbal           
            costX = DLCOPAR_cost(Y, Y_range, D, D_range_ext, X, opts);
            fprintf('| costX = %5.3f\n', costX);        
        end 
        %% ========= update D ==============================
        if opts.verbal
            fprintf('             updating D...');
        end 
        D = DLCOPAR_updateD(Y, Y_range, D, X, optsD); % and DCp1 
        t0 = toc; 
        if opts.verbal
            costD = DLCOPAR_cost(Y, Y_range, D, D_range_ext, X, opts);        
            fprintf('| costD = %5.3f ', costD);    
            t = t0*(opts.max_iter - iter)/iter;
            time_estimate(t);
            if abs(costX - costD) < 1e-4
                break;
            end
        end 
        %% break if runningtime >= 20 hrs 
        if t0 > 20*3600
            break;
        end
    end 
    rt = toc;
    %%
    if nargin == 0
        D  = [];
        X  = [];
        rt = [];
    end
end 
