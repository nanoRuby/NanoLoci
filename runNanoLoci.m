%% License Information:
%   This software, "Image analysis optimization for nanowire-based optical
%   detection of molecules", was developed by Rubina Davtyan, Nicklas
%   Anttu, Julia Valderas-Gutiérrez, Fredrik Höök, and Heiner Linke at Lund
%   University, Åbo Akademi, and Chalmers University of Technology.
%   Correspondence regarding this software should be addressed to Rubina
%   Davtyan (rubina.davtyan@ftf.lth.se)%   

% This software is provided with GNU 3.0 license. See license file for more
% information.
% If you use this software, please cite the following paper:
%       Rubina Davtyan, Nicklas Anttu, Julia Valderas-Gutiérrez, Fredrik
%       Höök, and Heiner Linke. "Image analysis optimization for
%       nanowire-based optical detection of molecules." [submitted to...], 2024.
% (c) 2024 Rubina Davtyan. All rights reserved.
% ======================================================================= %
openFilePath = which('runNanoLoci.m');
if isempty(openFilePath)
    error('The file input.m is not currently open or cannot be found.');
end

% Navigate to the parent directory of the open file
parentFolder = fileparts(openFilePath);

% Add the parent directory and all its subfolders to the MATLAB path
addpath(genpath(parentFolder));

% Now that the folder is added to the path, you can use it to access other files
% For example, you can open your MATLAB App (.mlapp) file
run(fullfile('nanoLoci.mlapp'));