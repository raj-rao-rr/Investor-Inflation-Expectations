#!/apps/Anaconda3-2019.03/bin/python 
# -*- coding: utf-8 -*-
"""
Created on Tue Nov 3 10:45:17 2020

@author: Rajesh Rao

This script works to format economic release data from Bloomberg, controling for the types
of releases and converting the string values into numeric figures.
"""

##########################################################################
# PACKAGE IMPORTS
##########################################################################

# text/string manipulation re-gex 
import re

import pandas as pd 


# %% Economic Data Numeric Conversion

baseDirectory = '/home/rcerxr21/DesiWork/Policy/Inflation_Swap_Breakeven_Basis/'
inputDirectory = baseDirectory + 'Input/'


# reading in economic annoucements from Blommberg
ecoAnnounce = pd.read_csv(inputDirectory + 'economic-releases.csv')

def numericFix(elm):
    """
    Removes non-numeric characters from elements within reported data 
    :param: elm (str, int, float) 
        an element passed to extract necessary elements 
    :returns: (str, int, float) 
        a string representing a numerical quanity 

    e.g.
        [In]: '3.4'      ->  [Out]: '3.4'
        
        [In]: '73.6k'    ->  [Out]: '73.6'
        
        [In]: '-$113.5b' ->  [Out]: '-113.5'
        
        [In]: '-$113.5b' ->  [Out]: '-113.5'
    """

    try:
        # regex subset, extracting elements 0-9, '.' or '-' characters
        return re.sub("[^0-9|.|-]", "", elm)
    except TypeError:
        return elm

# fix the economic data points, extracting only numeric values
ecoAnnounce['SurvM'] = ecoAnnounce['SurvM'].apply(numericFix)
ecoAnnounce['SurvA'] = ecoAnnounce['SurvA'].apply(numericFix)
ecoAnnounce['SurvH'] = ecoAnnounce['SurvH'].apply(numericFix)
ecoAnnounce['SurvL'] = ecoAnnounce['SurvL'].apply(numericFix)
ecoAnnounce['Actual'] = ecoAnnounce['Actual'].apply(numericFix)
ecoAnnounce['Prior'] = ecoAnnounce['Prior'].apply(numericFix)
ecoAnnounce['Revised'] = ecoAnnounce['Revised'].apply(numericFix)

# %% Economic Release Split (e.g. Prior, Final)

def periodFix(elm:str, periods:list = ['A', 'F', 'P', 'R', 'S', 'T']):
    """
    Converts a period with trailing letter to single letter variable
    :param: elm (str) 
        an element passed to extract trailing figures 
    :returns: (str) 
        a string representing a letter for annoucement release  

    e.g.
        [In]: '4Q T'    ->  [Out]: 'T'
        
        [In]: '2Q F'    ->  [Out]: 'F'
    """
    check = True
    
    for i in periods:
        try:
            if elm[-1] == i:
                check = False
                return " " + i
        except TypeError:
            pass

    if check:
        return ""
    
# retrieve the release type for the annoucement releases
ecoAnnounce['Amendment'] = ecoAnnounce['Period'].apply(periodFix)

# reconsturing the event names according to their amendments
ecoAnnounce['Event'] = ecoAnnounce['Event'] + ecoAnnounce['Amendment'] 

# %% Export cleaned/modified economic varaible 

# store the macro-variables to temp folder
ecoAnnounce.to_csv(inputDirectory + 'clean-eco-releases.csv', index=False)
