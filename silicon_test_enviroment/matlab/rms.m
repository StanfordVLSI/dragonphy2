function [signal_rms] = rms(signal)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    signal_rms = sqrt(sum(signal.*signal));
end

