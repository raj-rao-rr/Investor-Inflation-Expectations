% Primary executable file (run all file)

clear; clc;

%% set the primary directory to work in  
root_dir = pwd;

% enter the root directory 
cd(root_dir)            

%% add paths to acess files
addpath([root_dir filesep 'code'])            
addpath([root_dir filesep 'code' filesep 'lib']) 
addpath([root_dir filesep 'input'])
addpath([root_dir filesep 'temp'])
addpath([root_dir filesep 'output'])  
 
%% running project scripts in synchronous order 
% run('data_gather.m')                                                            
% run('macro_response.m')                                                    
