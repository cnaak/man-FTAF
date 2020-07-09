# Module
module FTAF_engine

#----------------------------------------------------------------------------------------------#
#                                          Interface                                           #
#----------------------------------------------------------------------------------------------#

"""
Function to return the instantaneous combustion chamber volume, in m³.
"""
function V end

"""
Function to return the engine's total piston displaced volume, in m³.
"""
function Vd end

"""
Function to return the single-cylinder piston displaced volume, in m³.
"""
function Vdu end

"""
Function to return the single-cylinder TDC volume, in m³.
"""
function VTDC end

# VTDC's Vmin alias
Vmin = VTDC

"""
Function to return the single-cylinder BDC volume, in m³.
"""
function VBDC end

# VBDC's Vmin alias
Vmax = VBDC

"""
Function to return the engine's cylinder count.
"""
function z end

"""
Function to return the piston diameter, in m.
"""
function D end

"""
Function to return the piston stroke, in m.
"""
function S end

"""
Function to return the connecting rod length, in m.
"""
function L end

"""
Function to return the crank radius, in m.
"""
function R end

# Module
end
