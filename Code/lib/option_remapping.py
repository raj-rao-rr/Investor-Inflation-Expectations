#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Apr 30 09:48:19 2021

@author: Rajesh Rao

This script works on re-packaging the inflation options data, extracting essential 
columns and re-mapping their column names to appropriate Bid, Ask and 
Last Price figures for measurements  
"""

##########################################################################
# PACKAGE IMPORTS
##########################################################################

import os
import pandas as pd 


##########################################################################
# FUNCTIONS
##########################################################################

# seting up correct directory
baseDirectory = '/home/rcerxr21/DesiWork/Policy/Inflation_Swap_Breakeven_Basis/'
inputDirectory = baseDirectory + 'Input/'
tempDirectory = baseDirectory + 'Temp/'


# %% Function handle for mapping CUSIPS to economic initutive expressions

def cusip_remap(cusip:str, strike_map:dict, term_map:dict):
    """
    Converts a Bloomberg CUSIP value into reader friendly economic names
    ---------------------------------------------------------------------------
    :param: cusip (str) 
        a Bloomberg CUSIP corresponding to inflation option data (i.e. caps, floors)
    :param: strike_map (dict) 
        a dicitonary that maps Bloomberg CUSIP identifier to option strikes
    :param: term_map (dict) 
        a dicitonary that maps Bloomberg CUSIP identifier to option terms
    :returns: (str, int, float) 
        a string representing the economic meaning of the CUSIP

    e.g.
        [In]: '3.4'      ->  [Out]: '3.4'
        
        [In]: '73.6k'    ->  [Out]: '73.6'
        
        [In]: '-$113.5b' ->  [Out]: '-113.5'
        
        [In]: '-$113.5b' ->  [Out]: '-113.5'
    """
    
    # e.g. USZPC101 BFIL Curncy -> USZPC101
    bbg_ticker = cusip.split(' ')[0]
    
    # e.g. USZPC101 -> 101
    strike_term = bbg_ticker[5:]
    
    # e.g. 1, 10 -> strike, term
    strike, term = strike_term[0], strike_term[1:]
    
    return term_map[term] + "-" + strike_map[strike]

# %% Fixing the inflation options data

caps_strikes_remap = {'1':'1.00%', 'S':'1.50%', '2':'2.00%', 'R':'2.50%', '3':'3.00%', 'Q':'3.50%', 
                      '4':'4.00%', 'P':'4.50%', '5':'5.00%', '6':'6.00%'}
floor_strikes_remap = {'X':'-3.00%', 'O':'-2.00%', 'Z':'-1.00%', 'U':'-0.50%', '0':'0.00%', 
                       'T':'0.50%', '1':'1.00%', 'S':'1.50%', '2':'2.00%', '3':'3.00%'}
term_remap = {'01':'1y', '1':'1y', '03':'3y', '3':'3y', '05':'5y', '5':'5y', '07':'7y', 
              '7':'7y', '10':'10y', '15':'15y', '20':'20y', '30':'30y'}


# load in existing Bloomberg inflation option price data 
zc_caps = pd.read_excel(inputDirectory + 'options/usd-inflation-zc-caps.xlsx').set_index('Start Date')
yoy_caps = pd.read_excel(inputDirectory + 'options/usd-inflation-yoy-caps.xlsx').set_index('Start Date')
zc_floors = pd.read_excel(inputDirectory + 'options/usd-inflation-zc-floors.xlsx').set_index('Start Date')
yoy_floors = pd.read_excel(inputDirectory + 'options/usd-inflation-yoy-floors.xlsx').set_index('Start Date')

# execute cusip convertor for zero-coupons and yoy CUSIPS with correct mapping
new_zc_caps = zc_caps.iloc[2].fillna(method='ffill').apply(cusip_remap, 
                     args=(caps_strikes_remap, term_remap))                               
new_yoy_caps = yoy_caps.iloc[2].fillna(method='ffill').apply(cusip_remap,
                       args=(caps_strikes_remap, term_remap))
new_zc_floors = zc_floors.iloc[2].fillna(method='ffill').apply(cusip_remap, 
                     args=(floor_strikes_remap, term_remap))                               
new_yoy_floors = yoy_floors.iloc[2].fillna(method='ffill').apply(cusip_remap,
                       args=(floor_strikes_remap, term_remap))

# rename each of the corresponding rows to each column
new_zc_caps.iloc[0::3] = new_zc_caps.iloc[0::3].apply(lambda x: x + " Bid Price")                    # first row is Bid
new_zc_caps.iloc[1::3] = new_zc_caps.iloc[1::3].apply(lambda x: x + " Ask Price")                    # second row is Ask
new_zc_caps.iloc[2::3] = new_zc_caps.iloc[2::3].apply(lambda x: x + " Last Price")                   # second row is Last

new_yoy_caps.iloc[0::3] = new_yoy_caps.iloc[0::3].apply(lambda x: x + " Bid Price")     
new_yoy_caps.iloc[1::3] = new_yoy_caps.iloc[1::3].apply(lambda x: x + " Ask Price")    
new_yoy_caps.iloc[2::3] = new_yoy_caps.iloc[2::3].apply(lambda x: x + " Last Price")   

new_zc_floors.iloc[0::3] = new_zc_floors.iloc[0::3].apply(lambda x: x + " Bid Price")                    
new_zc_floors.iloc[1::3] = new_zc_floors.iloc[1::3].apply(lambda x: x + " Ask Price")                   
new_zc_floors.iloc[2::3] = new_zc_floors.iloc[2::3].apply(lambda x: x + " Last Price")                   

new_yoy_floors.iloc[0::3] = new_yoy_floors.iloc[0::3].apply(lambda x: x + " Bid Price")     
new_yoy_floors.iloc[1::3] = new_yoy_floors.iloc[1::3].apply(lambda x: x + " Ask Price")    
new_yoy_floors.iloc[2::3] = new_yoy_floors.iloc[2::3].apply(lambda x: x + " Last Price")     

# remap the columns for each renamed CUSIP
zc_caps.columns = new_yoy_caps.values
yoy_caps.columns = new_yoy_caps.values
zc_floors.columns = new_zc_floors.values
yoy_floors.columns = new_yoy_floors.values

# %% Export excel files 

if __name__ == '__main__':

    # export cleaned series for corresponding zero coupons    
    zc_caps.iloc[5:].to_csv(tempDirectory + 'options/usd-zc-inflation-caps.csv')
    yoy_caps.iloc[5:].to_csv(tempDirectory + 'options/usd-yoy-inflation-caps.csv')
    zc_floors.iloc[5:].to_csv(tempDirectory + 'options/usd-zc-inflation-floors.csv')
    yoy_floors.iloc[5:].to_csv(tempDirectory + 'options/usd-yoy-inflation-floors.csv')

    print('Inflation data has been modified by mappign CUSIPS.\n')    
