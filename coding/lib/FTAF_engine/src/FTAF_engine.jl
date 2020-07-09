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

"""
Function to return the dimensionless piston stroke-to-diameter ratio.
"""
function rSD end

"""
Function to return the dimensionless piston diameter-to-stroke ratio.
"""
function rDS end

"""
Function to return the dimensionless rod length to crank radius ratio.
"""
function rLR end

"""
Function to return the dimensionless crank radius to rod lenght ratio.
"""
function rRL end

# Module
end
