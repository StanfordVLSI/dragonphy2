function enob = myenob(y, window_func, signal_thresh)
    % reference:
    % page 7 here http://www.mit.edu/~klund/A2Dtesting.pdf
    
    % set defaults
    if ~exist('window_func','var')
        window_func = @hann;
        fprintf("myenob: using hann window function\n");
    end
    if ~exist('signal_thresh','var')
        signal_thresh = 0.1;
        fprintf("myenob: using signal threshold of %0.3e\n", signal_thresh);
    end

    % make input a row vector
    if (size(y, 1) ~= 1)
        y = y';
    end
    
    % make vector an even length
    if (mod(length(y), 2) == 1)
        y = y(1:end-1);
    end
    
    % remove offset
    y = y - mean(y);
    
    % apply window function if desired
    if (isa(window_func, "function_handle"))
        y = y .* window_func(length(y))';
    end
        % get amplitudes
    A = abs(fft(y));
    A = A(1:(length(y)/2));
    
    % find peak
    [peak, center] = max(A);
    fprintf("myenob: auto-detected signal at fft sample %0d\n", center);
    
    % find width if needed
    low_bnd = center;
    while ((low_bnd > 1) && (A(low_bnd) >= (signal_thresh*peak)))
        low_bnd = low_bnd - 1;
    end
    high_bnd = center;
    while ((high_bnd < length(A)) && (A(high_bnd) >= (signal_thresh*peak)))
        high_bnd = high_bnd + 1;
    end
    
    width = high_bnd - low_bnd + 1;
    fprintf("myenob: auto-detected width of %0d (%0.1f%% of spectrum)\n", width, 100*width/length(A));
    
    % get vector of signal amplitudes
    As = A(low_bnd:high_bnd);
    
    % get vector of noise amplitudes
    An = [A(1:(low_bnd-1)), A((high_bnd+1):end)];
    
    % calculate SNDR
    sndr = 10*log10(sum(As.^2) / sum(An.^2));

    % return enob
    enob = (sndr - 1.76) / 6.02;
end