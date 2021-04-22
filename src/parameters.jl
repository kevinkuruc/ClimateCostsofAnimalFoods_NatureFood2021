using XLSX, DataFrames, CSV

#######################################################################################################################
# Load parameters for the DICE-FARM Model.
#######################################################################################################################
# Description: This function loads any parameters required to create the default version of the DICE-FARM model.
#
# Function Arguments:
#
#       start_year = The first year to switch DICE on and fully couple it to FAIR (2015).
#       end_year   = The last year to run FAIR coupled to DICE+FARM (2500).
#       DICEFile   = Path to DICE and FARM parameter file.
#----------------------------------------------------------------------------------------------------------------------

function getdice2016excelparameters(start_year, end_year, DICEFile)
    p = Dict{Symbol,Any}()

    # Get length of model time horizon.
    T = length(start_year:end_year)

    #Open DICE_2016 Excel File to read in parameters.
    f = XLSX.readxlsx(DICEFile)

    p[:a0]          = getparams(f, "B108:B108", :single, "Parameters",1) # Initial level of total factor productivity
    p[:a1]          = getparams(f, "B25:B25", :single, "Base", 1)        # Damage coefficient on temperature
    p[:a2]          = getparams(f, "B26:B26", :single, "Base", 1)        # Damage quadratic term
    p[:a3]          = getparams(f, "B27:B27", :single, "Base", 1)        # Damage exponent
    p[:cca0]        = getparams(f, "B92:B92", :single, "Base", 1)        # Initial cumulative industrial emissions
    p[:cumetree0]   = 100                                                # Initial cumulative emissions from deforestation (see GAMS code)
    p[:damadj]      = getparams(f, "B65:B65", :single, "Parameters", 1)  # Adjustment exponent in damage function
    p[:dela]        = getparams(f, "B110:B110", :single, "Parameters",1) # Decline rate of TFP per 5 years
    p[:tfp]         = getparams(f, "B21:CW21", :all, "Base", T)          # Total factor productivity.
    p[:deland]      = getparams(f, "D64:D64", :single, "Parameters", 1)  # Decline rate of land emissions (per period)
    p[:DoubleCountCo2] = zeros(T)                                        # Just here for calibration purposes
    p[:dk]          = getparams(f, "B6:B6", :single, "Base", 1)          # Depreciation rate on capital (per year)
    p[:dsig]        = getparams(f, "B66:B66", :single, "Parameters", 1)  # Decline rate of decarbonization (per period)
    p[:eland0]      = getparams(f, "D63:D63", :single, "Parameters", 1)  # Carbon emissions from land 2015 (GtCO2 per year)
    p[:etree]       = getparams(f, "B44:CW44", :all, "Base", T)          # Exogenous Land Use emissions scenario (GtCO2).
    p[:e0]          = getparams(f, "B113:B113", :single, "Base", 1)      # Industrial emissions 2015 (GtCO2 per year)
    p[:elasmu]      = getparams(f, "B19:B19", :single, "Base", 1)        # Elasticity of MU of consumption
    p[:eqmat]       = getparams(f, "B82:B82", :single, "Parameters", 1)  # Equilibirum concentration of CO2 in atmosphere (GTC)
    p[:expcost2]    = getparams(f, "B39:B39", :single, "Base", 1)        # Exponent of control cost function
    p[:fosslim]     = getparams(f, "B57:B57", :single, "Base", 1)        # Maximum carbon resources (Gtc)
    p[:ga0]         = getparams(f, "B109:B109", :single, "Parameters",1) # Initial growth rate for TFP per 5 years
    p[:gama]        = getparams(f, "B5:B5", :single, "Base", 1)          # Capital Share
    p[:gback]       = getparams(f, "B26:B26", :single, "Parameters", 1)  # Initial cost decline backstop cost per period
    p[:gsigma1]     = getparams(f, "B15:B15", :single, "Parameters", 1)  # Initial growth of sigma (per year)
    p[:k0]          = getparams(f, "B12:B12", :single, "Base", 1)        # Initial capital
    p[:mat0]        = getparams(f, "B61:B61", :single, "Base", 1)        # Initial Concentration in atmosphere in 2015 (GtC)
    p[:mateq]       = getparams(f, "B82:B82", :single, "Parameters", 1) # Equilibrium concentration atmosphere  (GtC)
    p[:MIU]         = getparams(f, "B135:CW135", :all, "Base", T)        # Optimized emission control rate results from DICE2016R (base case)
    p[:EIndToggle]  = 1.                                                 # Lets you toggle Industrial Emissions off (through sigma)
    p[:pback]       = getparams(f, "B10:B10", :single, "Parameters", 1)  # Cost of backstop 2010$ per tCO2 2015
    p[:rho]         = .015                                               # Annual social rate of time preference
    p[:S]           = getparams(f, "B131:CW131", :all, "Base", T)        # Optimized savings rate (fraction of gross output) results from DICE2016 (base case)
    p[:scale1]      = getparams(f, "B49:B49", :single, "Base", 1)        # Multiplicative scaling coefficient
    p[:scale2]      = getparams(f, "B50:B50", :single, "Base", 1)        # Additive scaling coefficient
    p[:CO2Marg]     = zeros(T)

    #Subbing in annual population for DICE-FARM.
    # Value for annual version, use .134 to hit 5-year population levels.
    lexp            = .02835142
    lasymptote      = 11500
    l               = zeros(T)
    # Calculate annual population values.
    l[1]            = 7403
        for h = 2:T
        l[h]  = l[h-1]*(lasymptote/l[h-1])^lexp
        end
    p[:l]           = l

    ##Add Farm Sector Parameters
    PCgrowth = ones(T)
    if PCgrowth[10]>1
        println("Running With Per Capita Meat Consumption Increase")
    end

    p[:Beef]  = 1e6*1.4*p[:l].*PCgrowth[:]    # Beef (in kg of protein) produced annually.
    p[:Dairy] = 1e6*2.6*p[:l].*PCgrowth[:]    # Dairy (in kg of protein) produced annually.
    p[:Poultry] = 1e6*2.0*p[:l].*PCgrowth[:]  # Poultry (in kg of protein) produced annually.
    p[:Pork]    = 1e6*2.0*p[:l].*PCgrowth[:]  # Pork (in kg of protein) produced annually.
    p[:Eggs]    = 1e6*1.25*p[:l].*PCgrowth[:] # Eggs (in kg of protein) produced annually.
    p[:SheepGoat] = 1e6*.4*p[:l].*PCgrowth[:] # Sheep/Goat (in kg of protein) produced annually.
    p[:AFarm] = 75.0*ones(T)                  # Number of animals to produce a kilogram of meat.

    p[:sigmaBeefMeth] = 4.98                  # CH₄ emissions (in kg) per kg of protein
    p[:sigmaBeefCo2]  = 63.99                 # CO₂ emissions (in kg) per kg of protein
    p[:sigmaBeefN2o]  = 0.229                 # N₂O emissions (in kg) per kg of protein

    p[:sigmaDairyMeth] = 1.69                 # CH₄ emissions (in kg) per kg of protein
    p[:sigmaDairyCo2]  = 16.46                # CO₂ emissions (in kg) per kg of protein
    p[:sigmaDairyN2o]  = 0.078                # N₂O emissions (in kg) per kg of protein

    p[:sigmaPoultryMeth] = .02                # CH₄ emissions (in kg) per kg of protein
    p[:sigmaPoultryCo2]  = 25.63              # CO₂ emissions (in kg) per kg of protein
    p[:sigmaPoultryN2o]  = 0.030              # N₂O emissions (in kg) per kg of protein

    p[:sigmaPorkMeth] = .503                  # CH₄ emissions (in kg) per kg of protein
    p[:sigmaPorkCo2]  = 25.12                 # CO₂ emissions (in kg) per kg of protein
    p[:sigmaPorkN2o]  = 0.043                 # N₂O emissions (in kg) per kg of protein

    p[:sigmaEggsMeth] = .052                  # CH₄ emissions (in kg) per kg of protein
    p[:sigmaEggsCo2]  = 20.09                 # CO₂ emissions (in kg) per kg of protein
    p[:sigmaEggsN2o]  = 0.032                 # N₂O emissions (in kg) per kg of protein

    p[:sigmaSheepGoatMeth] = 3.72             # CH₄ emissions (in kg) per kg of protein
    p[:sigmaSheepGoatCo2]  = 22.45            # CO₂ emissions (in kg) per kg of protein
    p[:sigmaSheepGoatN2o]  = 0.176            # N₂O emissions (in kg) per kg of protein

    #For IsoCost Curves
    p[:CEQ]       = 0.0                       # For Social Cost computation
    p[:MeatReduc] = 0.0                       # For Isocost curves
    p[:EIndReduc] = 0.0                       # For Isocost curves

    return p
end
