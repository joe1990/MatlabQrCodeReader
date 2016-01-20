% This function returns the formula which is executed for every module for
% the given mask, as a string. Is only used to display the formula in the
% gui.
%% AUTHOR    : Joel Holzer 
%% $Revision : 1.00 $ 
%% FILENAME  : displayMaskFormula.m 
function maskFormula = displayMaskFormula(mask)
    maskFormula = strcat('Formel für Maske ', num2str(mask), ': ');
    
    if mask == 0
        maskFormula = strcat(maskFormula, '(row + column) % 2');
    elseif mask == 1
        maskFormula = strcat(maskFormula, '(row) % 2');
    elseif mask == 2
        maskFormula = strcat(maskFormula, '(column) % 3');
    elseif mask == 3
        maskFormula = strcat(maskFormula, '(row + column) % 3');
    elseif mask == 4
        maskFormula = strcat(maskFormula, '(row/2 + column/3) % 2');
    elseif mask == 5
        maskFormula = strcat(maskFormula, '((row * column) % 2) + ((row * column) % 2)');
    elseif mask == 6
        maskFormula = strcat(maskFormula, '((row * column) % 2) + ((row * column) % 3)');
    elseif mask == 7
        maskFormula = strcat(maskFormula, '(((row * column) % 3) + row + column) % 3');
    end
end

