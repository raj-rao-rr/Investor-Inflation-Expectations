% Primary executable file (run all file)

clear; clc;

%% set the primary directory to work in  
root_dir = pwd;

% enter the root directory 
cd(root_dir)            

%% add paths to acess files
addpath([root_dir filesep 'Code'])            
addpath([root_dir filesep 'Code' filesep 'lib']) 
addpath([root_dir filesep 'Input'])
addpath([root_dir filesep 'Temp'])
addpath([root_dir filesep 'Output'])  
 
%% running project scripts in synchronous order 
% run('data_gather.m')   
% run('implied_probability.m')
% run('macro_response.m')  
% run('produce_graphs.m')  
