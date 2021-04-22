using MimiDICE2016
using MimiFAIR
using Interpolations
using Mimi

include("helpers.jl")
include("parameters.jl")

# Load MimiDICE2016 components modified to be annual and integrate with FARM module.
include(joinpath("components", "DICE", "emissions_component.jl"))
include(joinpath("components", "DICE", "damages_component.jl"))
include(joinpath("components", "DICE", "grosseconomy_component.jl"))
include(joinpath("components", "DICE", "totalfactorproductivity_component.jl"))
include(joinpath("components", "DICE", "neteconomy_component.jl"))
include(joinpath("components", "DICE", "welfare_component.jl"))
include(joinpath("components", "farm_component.jl"))



#######################################################################################################################
# Initialize the DICE-FARM Model.
#######################################################################################################################
# Description: This function creates the necessary data scenarios and then couples together componets from FAIR,
#              DICE, and the FARM emissions component. This is just a first-step initialization. In the second step
#              (below), DICE-FARM harmonizes the endogenous agriculture emissions with the exogenous scenarios to
#              avoid any double-counting.
#
# Function Arguments:
#
#       p               = Parameters for the DICE and FARM models.
#       start_year      = First year to run the model (corresponding to when FAIR starts in 1765).
#       end_year        = The last year to run FAIR coupled to DICE+FARM (2500).
#       start_dice_year = The first year to switch DICE on and fully couple it to FAIR (2015).
#       TCR             = Transient climate response.
#       ECS             = Equilibrium climtae sensitivity.
#----------------------------------------------------------------------------------------------------------------------

function initialize_dice_farm(p, start_year, end_year, start_dice_year, TCR, ECS)

    #--------------------------------------------------------------------------------------------------------------------
    # Carry out data preparation step.
    #--------------------------------------------------------------------------------------------------------------------

    # Get an instance of DICE2016 to access emissions data.
    dice2016 = MimiDICE2016.get_model()
    run(dice2016)

    # Get DICE2016 total and land-use CO₂ emissions in 2015 and convert units to GtC.
    dice_landuseco2_2015 = dice2016[:emissions, :ETREE][1] * 12.01/44.01
    dice_totalco2_2015   = dice2016[:emissions, :E][1] * 12.01/44.01

    # Create annual MIU, savings rate, TFP values, and land use emissions (cropped from 2015:2500 to match RCP scenario end year).
    dice_2500_index = findfirst(x -> x == 2500, collect(2015:2510))
    annual_savings  = dice_interpolate(p[:S], 5)[1:dice_2500_index]
    annual_MIU      = dice_interpolate(p[:MIU], 5)[1:dice_2500_index]
    annual_TFP      = dice_interpolate(p[:tfp], 5)[1:dice_2500_index]
    annual_ETREE    = dice_interpolate(p[:etree], 5)[1:dice_2500_index]

    # Pad annualized paramters so they have the time length of the full DICE-FARM model, not just DICE.
    annual_savings = pad_parameter(annual_savings, end_year - start_dice_year + 1, start_dice_year - start_year, 0)
    annual_MIU     = pad_parameter(annual_MIU, end_year - start_dice_year + 1, start_dice_year - start_year, 0)
    annual_TFP     = pad_parameter(annual_TFP, end_year - start_dice_year + 1, start_dice_year - start_year, 0)
    annual_ETREE   = pad_parameter(annual_ETREE, end_year - start_dice_year + 1, start_dice_year - start_year, 0)

    # Pad remaining DICE parameters so they have the time length of the full DICE-FARM model, not just DICE.
    p = pad_parameters(p, end_year - start_dice_year + 1, start_dice_year - start_year, 0)

    # Create an instance of FAIR to extract some historical values and couple in DICE-FARM components.
    m = MimiFAIR.get_model(rcp_scenario="RCP60", start_year=start_year, end_year=end_year, TCR=TCR, ECS=ECS)
    run(m)

    # Extract some emissions values from FAIR.
    rcp_landuse_co2 = m[:landuse_rf, :landuse_emiss]
    rcp_total_co2   = m[:co2_cycle, :E]
    rcp_fossil_ch4  = m[:ch4_cycle, :fossil_emiss_CH₄]
    rcp_fossil_n2o  = m[:n2o_cycle, :fossil_emiss_N₂O]

    # Calculate RCP index to begin interpolation so there's a smooth transition from historic RCP to present day DICE CO₂ emissions (2010-2015).
    rcp_years      = collect(1765:2500)
    rcp_2010_index = findfirst(x-> x == 2010, rcp_years)
    rcp_2015_index = findfirst(x-> x == 2015, rcp_years)

    # Calculate the interpolation piece for landuse and fossil CO₂ emissions.
    landuse_interp = dice_interpolate([rcp_landuse_co2[rcp_2010_index], dice_landuseco2_2015], 5)
    total_interp   = dice_interpolate([rcp_total_co2[rcp_2010_index], dice_totalco2_2015], 5)

    # Set up backup emissions scenarios (Mimi requires backup values for when two model compoennts do not overlap).
    # This uses: RCP emissions (1765-2009), interpolation values (2010-2014), then -9999.99 so an error occurs if model coupling is incorrect (2015 onward is endogenous DICEFARM emissions).
    backup_landuse_RCPco2 = vcat(rcp_landuse_co2[1:(rcp_2010_index-1)], landuse_interp[1:5], ones(length(2015:2500)).*-9999.99)
    backup_total_RCPco2   = vcat(rcp_total_co2[1:(rcp_2010_index-1)], total_interp[1:5], ones(length(2015:2500)).*-9999.99)

    # Set up "backup" CH₄ and N₂O emissions. No need to interpolate since once DICE-FARM kicks in, CH₄ and N₂O emissions will be endogenous farm emissions + remaining RCP emissions (so they sum to total RCP emissions).
    backup_fossil_RCPn2o = vcat(rcp_fossil_n2o[1:(rcp_2015_index-1)], ones(length(2015:2500)).*-9999.99)
    backup_fossil_RCPch4 = vcat(rcp_fossil_ch4[1:(rcp_2015_index-1)], ones(length(2015:2500)).*-9999.99)

    #-----------------------------------------------------------------------
    # Add DICE-FARM Components to MimiFAIR v1.3
    #-----------------------------------------------------------------------

    # Add DICEFARM components used to calculate emissions that feed into FAIR.
    add_comp!(m, emissions,    before = :ch4_cycle; first = start_dice_year)
    add_comp!(m, farm,         before = :emissions; first = start_dice_year)
    add_comp!(m, grosseconomy, before = :farm;      first = start_dice_year)

    # Add DICEFARM components to calculate climate impacts, net output, and welfare based on FAIR temperature projections.
    add_comp!(m, damages,    after = :temperature; first = start_dice_year)
    add_comp!(m, neteconomy, after = :damages;     first = start_dice_year)
    add_comp!(m, welfare,    after = :neteconomy;  first = start_dice_year)


    # ----- Parameters Common to Multiple Components ----- #
    set_param!(m, :l,   p[:l])
    set_param!(m, :MIU, annual_MIU)

    # ----- Gross Economy ----- #
    set_param!(m, :grosseconomy, :gama, p[:gama])
    set_param!(m, :grosseconomy, :dk,   0.0819)  #Value derived so changing DICE to annual timesteps matches original version output.
    set_param!(m, :grosseconomy, :k0,   p[:k0])
    set_param!(m, :grosseconomy, :AL,   annual_TFP)

    # ----- Agriculture Emissions ----- #
    set_param!(m, :farm, :Beef,               p[:Beef])
    set_param!(m, :farm, :Dairy,              p[:Dairy])
    set_param!(m, :farm, :Poultry,            p[:Poultry])
    set_param!(m, :farm, :Pork,               p[:Pork])
    set_param!(m, :farm, :Eggs,               p[:Eggs])
    set_param!(m, :farm, :SheepGoat,          p[:SheepGoat])
    set_param!(m, :farm, :sigmaBeefMeth,      p[:sigmaBeefMeth])
    set_param!(m, :farm, :sigmaBeefCo2,       p[:sigmaBeefCo2])
    set_param!(m, :farm, :sigmaBeefN2o,       p[:sigmaBeefN2o])
    set_param!(m, :farm, :sigmaDairyMeth,     p[:sigmaDairyMeth])
    set_param!(m, :farm, :sigmaDairyCo2,      p[:sigmaDairyCo2])
    set_param!(m, :farm, :sigmaDairyN2o,      p[:sigmaDairyN2o])
    set_param!(m, :farm, :sigmaPoultryMeth,   p[:sigmaPoultryMeth])
    set_param!(m, :farm, :sigmaPoultryCo2,    p[:sigmaPoultryCo2])
    set_param!(m, :farm, :sigmaPoultryN2o,    p[:sigmaPoultryN2o])
    set_param!(m, :farm, :sigmaPorkMeth,      p[:sigmaPorkMeth])
    set_param!(m, :farm, :sigmaPorkCo2,       p[:sigmaPorkCo2])
    set_param!(m, :farm, :sigmaPorkN2o,       p[:sigmaPorkN2o])
    set_param!(m, :farm, :sigmaEggsMeth,      p[:sigmaEggsMeth])
    set_param!(m, :farm, :sigmaEggsCo2,       p[:sigmaEggsCo2])
    set_param!(m, :farm, :sigmaEggsN2o,       p[:sigmaEggsN2o])
    set_param!(m, :farm, :sigmaSheepGoatMeth, p[:sigmaSheepGoatMeth])
    set_param!(m, :farm, :sigmaSheepGoatCo2,  p[:sigmaSheepGoatCo2])
    set_param!(m, :farm, :sigmaSheepGoatN2o,  p[:sigmaSheepGoatN2o])
    set_param!(m, :farm, :MeatReduc,          p[:MeatReduc])

    # ----- Total Greenhouse Gas Emissions ----- #
    set_param!(m, :emissions, :gsigma1,        p[:gsigma1])
    set_param!(m, :emissions, :dsig,           p[:dsig])
    set_param!(m, :emissions, :e0,             p[:e0])
    set_param!(m, :emissions, :EIndReduc,      p[:EIndReduc])
    set_param!(m, :emissions, :cca0,           p[:cca0])
    set_param!(m, :emissions, :cumetree0,      p[:cumetree0])
    set_param!(m, :emissions, :MethERCP,       rcp_fossil_ch4) # Need to subtract endogenous FARM emissions from RCP scenario in second step to avoid double-counting.
    set_param!(m, :emissions, :N2oERCP,        rcp_fossil_n2o) # Need to subtract endogenous FARM emissions from RCP scenario in second step to avoid double-counting.
    set_param!(m, :emissions, :Co2Pulse,       0.0)
    set_param!(m, :emissions, :MethPulse,      0.0)
    set_param!(m, :emissions, :N2oPulse,       0.0)
    set_param!(m, :emissions, :DoubleCountCo2, p[:DoubleCountCo2])
    set_param!(m, :emissions, :ETREE,          annual_ETREE)

    # ----- Climate Damages ----- #
    set_param!(m, :damages, :a1, p[:a1])
    set_param!(m, :damages, :a2, p[:a2])
    set_param!(m, :damages, :a3, p[:a3])

    # ----- Net Economy ----- #
    set_param!(m, :neteconomy, :expcost2, p[:expcost2])
    set_param!(m, :neteconomy, :pback,    p[:pback])
    set_param!(m, :neteconomy, :gback,    p[:gback])
    set_param!(m, :neteconomy, :S,        annual_savings)
    set_param!(m, :neteconomy, :CEQ,      p[:CEQ])

    # ----- Welfare ----- #
    set_param!(m, :welfare, :elasmu,    p[:elasmu])
    set_param!(m, :welfare, :rho,       p[:rho])
    set_param!(m, :welfare, :scale1,    p[:scale1])
    set_param!(m, :welfare, :scale2,    p[:scale2])

    #-----------------------------------------------------------------------
    # Create Internal Component Connections
    #-----------------------------------------------------------------------
    connect_param!(m, :grosseconomy, :I,  :neteconomy, :I)

    connect_param!(m, :emissions, :YGROSS,    :grosseconomy, :YGROSS)
    connect_param!(m, :emissions, :Co2EFarm,  :farm,         :Co2EFarm)
    connect_param!(m, :emissions, :MethEFarm, :farm,         :MethEFarm)
    connect_param!(m, :emissions, :N2oEFarm,  :farm,         :N2oEFarm)

    # Couple DICE-FARM and FAIR components.
    # Note: DICE-FARM runs from 2015-2500. FAIR runs from 1765-2500. FAIR therefore uses historical RCP emissions, then switches to endogenous DICE-FARM emissions in 2015.
    connect_param!(m, :co2_cycle  => :E_CO₂,            :emissions => :total_CO₂emiss_GtC,   backup_total_RCPco2)
    connect_param!(m, :ch4_cycle  => :fossil_emiss_CH₄, :emissions => :MethE,                backup_fossil_RCPch4)
    connect_param!(m, :n2o_cycle  => :fossil_emiss_N₂O, :emissions => :N2oE,                 backup_fossil_RCPn2o)
    connect_param!(m, :landuse_rf => :landuse_emiss,    :emissions => :landuse_CO₂emiss_GtC, backup_landuse_RCPco2)

    connect_param!(m, :damages, :TATM,   :temperature,  :T)
    connect_param!(m, :damages, :YGROSS, :grosseconomy, :YGROSS)

    connect_param!(m, :neteconomy, :YGROSS,  :grosseconomy, :YGROSS)
    connect_param!(m, :neteconomy, :DAMAGES, :damages,      :DAMAGES)
    connect_param!(m, :neteconomy, :SIGMA,   :emissions,    :SIGMA)

    connect_param!(m, :welfare, :CPC, :neteconomy, :CPC)

    # Return initialized version of DICE-FARM.
    return m
end



#######################################################################################################################
# Create final version of the DICE-FARM Model.
#######################################################################################################################
# Description: This function sets up a final version of DICE+FARM with user-specified parameters and then harmonizes the
#              endogenous agriculture and exogenous emissions to prevent any double-counting.
#
# Function Arguments:
#
#       start_year      = First year to run the model (corresponding to when FAIR starts in 1765).
#       end_year        = The last year to run FAIR coupled to DICE+FARM (2500).
#       start_dice_year = The first year to switch DICE on and fully couple it to FAIR (2015).
#       TCR             = Transient climate response.
#       ECS             = Equilibrium climtae sensitivity.
#       datafile        = Path to DICE and FARM parameter file.
#----------------------------------------------------------------------------------------------------------------------

function create_dice_farm(;start_year=1765, end_year=2500, start_dice_year=2015, TCR::Float64=1.69, ECS::Float64=3.1, datafile=joinpath(dirname(@__FILE__), "..", "data", "DICE2016_Excel.xlsm"))

    # Load DICE-FARM parameters to initialize model.
    dicefarm_parameters = getdice2016excelparameters(start_dice_year, end_year, datafile)

    # Initialize and run an instance of DICE-FARM coupled to FAIR to endogenize agriculture emissions.
    dice_farm = initialize_dice_farm(dicefarm_parameters, start_year, end_year, start_dice_year, TCR, ECS)
    run(dice_farm)

    # Need to subtract endogenous FARM CO₂ emissions from exogenous DICE land-use emissions to avoid double-counting.
    new_etree = dice_farm[:emissions, :ETREE] .- dice_farm[:emissions, :Co2EFarm]

    # Subtract agriculture CH₄ emissions from exogenous RCP values to avoid double-counting (need to convert FARM emissions from from kg to Mt)
    new_rcp_CH₄ = dice_farm[:emissions, :MethERCP] .- (dice_farm[:emissions, :MethEFarm] / 1e9)

    # Subtract agriculture N₂O emissions from exogenous RCP values to avoid double-counting (need to convert FARM emissions from from kg to Mt and from N₂O -> N)
    new_rcp_N₂O = dice_farm[:emissions, :N2oERCP] .- (dice_farm[:emissions, :N2oEFarm] / 1e9 * (28.01/44.01))

    # Update exogenous (non-FARM agriculture) emission sources for land use CO₂, CH₄, and N₂O.
    update_param!(dice_farm, :ETREE,    new_etree)
    update_param!(dice_farm, :N2oERCP,  new_rcp_N₂O)
    update_param!(dice_farm, :MethERCP, new_rcp_CH₄)

    # Return model with updated emission scenarios that fully endogenize the FARM component emissions.
    return dice_farm
end
