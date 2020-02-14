function [result] = our_hann(L)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    L=L-1;
    result = 1/2.*(1-cos((2*pi*(0:L))/L))';
end

