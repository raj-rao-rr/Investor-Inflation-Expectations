#!/apps/Anaconda3-2019.03/bin/python 
# -*- coding: utf-8 -*-
"""
Created on Wed Apr 27 11:48:00 2021

@author: Rajesh Rao

This script is designed to be run once at the project inception, to construct an excel file
to aid in the process of retrieving Bloomberg Price Data. All subsequent updates to price 
data should not require the running of this file, unless the excel file is deleted.

After the file is run, the user must manually open the file(s) and use the Spreadsheet Builder
icon on the Bloomberg Excel tab to pull information on Bid Price, Ask Price, & Last Price 
"""

##########################################################################
# PACKAGE IMPORTS
##########################################################################

import pandas as pd 
import numpy as np

# seting up correct directory
baseDirectory = '/home/rcerxr21/DesiWork/Policy/Inflation_Swap_Breakeven_Basis/'
inputDirectory = baseDirectory + 'input/'


# %% Building Bloomberg CUSIP Handles for inflation zero-coupon CAPs

zc_cap_base_cusip = 'USZPC'
yoy_cap_base_cusip = 'USYPC'

caps_strikes = {'1.00%': '1', '1.50%': 'S', '2.00%': '2', '2.50%': 'R', '3.00%': '3', '3.50%': 'Q', 
                '4.00%': '4', '4.50%': 'P', '5.00%': '5', '6.00%': '6'}
cap_term_map = {'1y': ('01', '1'), '3y': ('03', '3'), '5y': ('05', '5'), '7y': ('07', '7'), 
                '10y': ('10', '10'), '15y': ('15', '15'), '20y': ('20', '20'), '30y': ('30', '30')}

zc_cusip_cap_map = {}
yoy_cusip_cap_map = {}

for cap_strike in caps_strikes.keys():
    
    cap_cusip_strike = caps_strikes[cap_strike]
    
    # check whether the strike has special formatting rules
    cap_norm_check = cap_cusip_strike.isnumeric()
    
    for cap_term in cap_term_map.keys():
        
        # check whether a half strike is present
        if cap_norm_check:
            zc_cusip = zc_cap_base_cusip + cap_cusip_strike + cap_term_map[cap_term][0]
            yoy_cusip = yoy_cap_base_cusip + cap_cusip_strike + cap_term_map[cap_term][0]
            
            # e.g. USZPC101 BFIL Curncy : 1y 1.00%
            zc_cusip_cap_map[zc_cusip + ' BFIL ' + 'Curncy'] = cap_term + ' ' + cap_strike
            yoy_cusip_cap_map[yoy_cusip + ' BFIL ' + 'Curncy'] = cap_term + ' ' + cap_strike
        else:
            zc_cusip = zc_cap_base_cusip + cap_cusip_strike + cap_term_map[cap_term][1]
            yoy_cusip = yoy_cap_base_cusip + cap_cusip_strike + cap_term_map[cap_term][1]
            
            # e.g. USYPCS1 BFIL Curncy : 1y 1.50%
            zc_cusip_cap_map[zc_cusip + ' BFIL ' + 'Curncy'] = cap_term + ' ' + cap_strike
            yoy_cusip_cap_map[yoy_cusip + ' BFIL ' + 'Curncy'] = cap_term + ' ' + cap_strike

# construct a horizontal DataFrame, useful for drawing Bloomberg prices (CAPs)
zc_caps = pd.DataFrame.from_dict(zc_cusip_cap_map, orient='index').T
yoy_caps = pd.DataFrame.from_dict(yoy_cusip_cap_map, orient='index').T

# %% Building Bloomberg CUSIP Handles for inflation zero-coupon FLOORs

zc_floor_base_cusip = 'USZPF'
yoy_floor_base_cusip = 'USYPF'

floor_strikes = {'-3.00%': 'X', '-2.00%': 'O', '-1.00%': 'Z', '-0.50%': 'U', '0.00%': '0', 
                '0.50%': 'T', '1.00%': '1', '1.50%': 'S', '2.00%': '2', '3.00%': '3'}
floor_term_map = {'1y': ('01', '1'), '3y': ('03', '3'), '5y': ('05', '5'), '7y': ('07', '7'), 
                '10y': ('10', '10'), '15y': ('15', '15'), '20y': ('20', '20'), '30y': ('30', '30')}

zc_cusip_floor_map = {}
yoy_cusip_floor_map = {}

for floor_strike in floor_strikes.keys():
    
    floor_cusip_strike = floor_strikes[floor_strike]
    
    # check whether the strike is normal (rounded strikes) or half-strikes
    cap_norm_check = ~np.isin(floor_strike, ['-3.00%', '-2.00%', '-0.50%', '0.00%', '0.50%', 
                                             '1.50%'])
    
    for floor_term in floor_term_map.keys():
        
        if cap_norm_check:
            zc_cusip = zc_floor_base_cusip + floor_cusip_strike + floor_term_map[floor_term][0]
            yoy_cusip = yoy_floor_base_cusip + floor_cusip_strike + floor_term_map[floor_term][0]
            
            zc_cusip_floor_map[zc_cusip + ' BFIL ' + 'Curncy'] = floor_term + ' ' + floor_strike
            yoy_cusip_floor_map[yoy_cusip + ' BFIL ' + 'Curncy'] = floor_term + ' ' + floor_strike
        else:
            zc_cusip = zc_floor_base_cusip + floor_cusip_strike + floor_term_map[floor_term][1]
            yoy_cusip = yoy_floor_base_cusip + floor_cusip_strike + floor_term_map[floor_term][1]
            
            zc_cusip_floor_map[zc_cusip + ' BFIL ' + 'Curncy'] = floor_term + ' ' + floor_strike
            yoy_cusip_floor_map[yoy_cusip + ' BFIL ' + 'Curncy'] = floor_term + ' ' + floor_strike

# construct a horizontal DataFrame, useful for drawing Bloomberg prices (FLOORs)            
zc_floors = pd.DataFrame.from_dict(zc_cusip_floor_map, orient='index').T
yoy_floors = pd.DataFrame.from_dict(yoy_cusip_floor_map, orient='index').T
            
# %% Export excel files 

# data starts 9/23/2013 for Caps and Floors (Bid, Ask, Last Price data)
zc_caps.to_excel(inputDirectory + 'options/usd-inflation-zc-caps.xlsx')
yoy_caps.to_excel(inputDirectory + 'options/usd-inflation-yoy-caps.xlsx')
zc_floors.to_excel(inputDirectory + 'options/usd-inflation-zc-floors.xlsx')
yoy_floors.to_excel(inputDirectory + 'options/usd-inflation-yoy-floors.xlsx')

print('Inflation options CUSIPS have been created and exported to the Input/ folder.\n')
