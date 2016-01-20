% Calculates the mask which was layed over the qr-code. there exists 8 masks.
% The mask is calculated with a binary xor of the format string and 10101
% (just the 3 last digits of the calculated string are the mask string).
% The function returns the following:
% - maskDec = mask as decimal number (1, 2, etc.)
% - maskBin = mask as binary number
% - xorFormatString = string after the xor from the format string and 10101
%% AUTHOR    : Joel Holzer 
%% $Revision : 1.00 $ 
%% FILENAME  : calculateMask.m 
function [maskDec, maskBin, xorFormatString] = calculateMask(formatStringBin)
    %calculate format mask
    formatStringDec = bin2dec(formatStringBin);
    xorOperatorDec = bin2dec('10101');
    xorFormatDec = bitxor(formatStringDec, xorOperatorDec);
    xorFormatString = dec2bin(xorFormatDec, 5);
    maskBin = xorFormatString(3:5);
    maskDec = bin2dec(maskBin);
end

