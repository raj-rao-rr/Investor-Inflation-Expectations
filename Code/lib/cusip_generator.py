#!/apps/Anaconda3-2019.03/bin/python 
# -*- coding: utf-8 -*-
"""
Created on Wed Apr 27 11:48:00 2021

@author: Rajesh Rao

This script is designed to be run once at the project inception, to construct an excel file
to aid in the process of retrieving Bloomberg Price Data. All subsequent updates to price 
data should not require the running of this file, unless the excel files are deleted.

After the file is run, the user must manually open the file(s) and use the Spreadsheet Builder
icon on the Bloomberg Excel tab to pull information on Bid Price, Ask Price, & Last Price. The 
files in question are usd-inflation-zc-caps.xlsx and usd-inflation-zc-floors.xlsx
"""

##########################################################################
# PACKAGE IMPORTS
##########################################################################

import os
import pandas as pd 
import numpy as np

# base directory for the user, check for SAN/RAN or Local instance
curr_pwd = os.getcwd()

if 'NYRESAN' in curr_pwd: # working on a local instance
    baseDirectory = '/'.join(curr_pwd.split('\\')[:-2])
else:
    baseDirectory = '/'.join(curr_pwd.split('/')[:-2])

inputDirectory = baseDirectory + '/Input/'


# %% Building Bloomberg CUSIP Handles for inflation zero-coupon CAPs

zc_caps_ticker = pd.read_excel(inputDirectory + 'options/option_tickers.xlsx', 
                               sheet_name='US_CPI_ZCC', index_col='Term')
nRows, mCols = zc_caps_ticker.shape
cap_strikes = zc_caps_ticker.columns
term_struct = zc_caps_ticker.index

# initialize containers to hold all 
cap_container = np.empty(shape=(mCols, nRows), dtype=object)
str_container = np.empty(shape=(mCols, nRows), dtype=object)

for i, col in enumerate(cap_strikes):
    cap_container[i] = zc_caps_ticker[col].values
    str_container[i] = np.array(list(map(lambda x: str(round(col * 100, 2)) + '% ' + x,  
                 term_struct)))
  
# convert the containers to dictionary maps
mapped_zc_caps = {'BBG_TICKER' : cap_container.flatten(), 
                  'STRIKE_TENOR' : str_container.flatten()}
mapped_zc_caps = pd.DataFrame(mapped_zc_caps)

# %% Building Bloomberg CUSIP Handles for inflation zero-coupon FLOORs

zc_floors_ticker = pd.read_excel(inputDirectory + 'options/option_tickers.xlsx', 
                               sheet_name='US_CPI_ZCF', index_col='Term')
nRows, mCols = zc_floors_ticker.shape
floor_strikes = zc_floors_ticker.columns
term_struct = zc_floors_ticker.index

# initialize containers to hold all 
floor_container = np.empty(shape=(mCols, nRows), dtype=object)
str_container = np.empty(shape=(mCols, nRows), dtype=object)

for i, col in enumerate(floor_strikes):
    floor_container[i] = zc_floors_ticker[col].values
    str_container[i] = np.array(list(map(lambda x: str(round(col * 100, 2)) + '% ' + x,  
                 term_struct)))
  
# convert the containers to dictionary maps
mapped_zc_floors = {'BBG_TICKER' : floor_container.flatten(), 
                    'STRIKE_TENOR' : str_container.flatten()}
mapped_zc_floors = pd.DataFrame(mapped_zc_floors)

# %% Export excel files 

# data starts 9/23/2013 for Caps and Floors (Bid, Ask, Last Price data)
mapped_zc_caps.to_excel(inputDirectory + 'options/usd-inflation-zc-caps.xlsx', index=False)
mapped_zc_floors.to_excel(inputDirectory + 'options/usd-inflation-zc-floors.xlsx', index=False)

print('Inflation options CUSIPS have been created and exported to the Input/ folder.\n')
