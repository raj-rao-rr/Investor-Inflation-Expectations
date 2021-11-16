% Primary executable file (run all file)

clear; clc;

%% set the primary directory to work in  
root_dir = pwd;

% enter the root directorot ty 
cd(root_dir)            

%% add paths to acess files

addpath([root_dir filesep 'Code'])            
addpath([root_dir filesep 'Code' filesep 'lib']) 
addpath([root_dir filesep 'Input'])
addpath([root_dir filesep 'Temp'])
addpath([root_dir filesep 'Output'])  

%% running project scripts in synchronous order 

tic
run('data_gather.m')            % gather and store neccesary data   
run('implied_probability.m')    % construct implied probability density
run('macro_regressions.m')      % perform regression analysis
run('produce_graphs.m')         % produce plots for analysis
toc
