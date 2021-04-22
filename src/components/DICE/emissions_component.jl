@defcomp emissions begin

    EIndReduc      = Parameter()             # Allows you to toggle off emissions
    gsigma1        = Parameter()             # Initial growth of sigma (per year)
    dsig           = Parameter()             # Decline rate of decarbonization (per period)
    e0             = Parameter()             # Industrial emissions 2015 (GtCO2 per year)
    cca0           = Parameter()             # Initial cumulative industrial emissions
    cumetree0      = Parameter()             # Initial emissions from deforestation (see GAMS code)
    Co2Pulse       = Parameter()             # Marginal CO₂ pulse.
    MethPulse      = Parameter()             # Marginal CH₄ pulse.
    N2oPulse       = Parameter()             # Marginal N₂O pulse.
    ETREE          = Parameter(index=[time]) # Exogenous Emissions from landuse/deforestation
    Co2EFarm       = Parameter(index=[time]) # Animal Ag CO₂ Emissions (GtCO₂)
    MIU            = Parameter(index=[time]) # Emission control rate GHGs
    YGROSS         = Parameter(index=[time]) # Gross world product GROSS of abatement and damages (trillions 2010 USD per year)
    MethERCP       = Parameter(index=[time]) # RCP methane emissions (baseline animal emissions removed in code)
    MethEFarm      = Parameter(index=[time]) # Methane missions from farmed animals
    N2oERCP        = Parameter(index=[time]) # RCP N₂O emissions (baseline animal emissions removed in code)
    N2oEFarm       = Parameter(index=[time]) # N₂O missions from farmed animals
    DoubleCountCo2 = Parameter(index=[time]) # Eliminate CO2 emissions from animal products here

    SIG0                 = Variable()             # Carbon intensity 2010-2015 (kgCO₂ per output 2010 USD)
    GSIG                 = Variable(index=[time]) # Change in sigma (cumulative improvement of energy efficiency)
    SIGMA                = Variable(index=[time]) # CO₂-equivalent-emissions output ratio
    EIND                 = Variable(index=[time]) # Industrial emissions (GtCO₂ per year)
    E                    = Variable(index=[time]) # Total CO₂ emissions (GtCO₂ per year)
    CUMETREE             = Variable(index=[time]) # Cumulative from land
    CCA                  = Variable(index=[time]) # Cumulative industrial emissions
    CCATOT               = Variable(index=[time]) # Cumulative total carbon emissions
    N2oE                 = Variable(index=[time]) # N₂O emissions by time
    MethE                = Variable(index=[time]) # CH₄ emissions by time
    total_CO₂emiss_GtC   = Variable(index=[time]) # FAIR requires CO2 emissions in units GtC.
    landuse_CO₂emiss_GtC = Variable(index=[time]) # FAIR requires land-use CO2 emissions in units GtC.


    function run_timestep(p, v, d, t)

        # Define SIG0
        if is_first(t)
            v.SIG0 = p.e0/(p.YGROSS[t] * (1 - p.MIU[t]))
        end

        # Define function for GSIG
        if is_first(t)
            v.GSIG[t] = p.gsigma1
        else
            v.GSIG[t] = v.GSIG[t-1] * (1 + p.dsig)
        end

        # Define function for SIGMA
        if is_first(t)
            v.SIGMA[t] = v.SIG0
        else
            v.SIGMA[t] = v.SIGMA[t-1] * exp(v.GSIG[t-1])
        end

        # Define function for EIND
        if gettime(t) < 2020 #reductions only possible starting in 2020
            v.EIND[t] = v.SIGMA[t] * p.YGROSS[t] * (1 - p.MIU[t])
        else
            v.EIND[t] = v.SIGMA[t] * p.YGROSS[t] * (1 - p.MIU[t]) * (1-p.EIndReduc)
        end

        # Define function for E
        if gettime(t) !=2020
        v.E[t] = v.EIND[t] + p.ETREE[t] + p.Co2EFarm[t] - p.DoubleCountCo2[t]
        else
        v.E[t] = v.EIND[t] + p.ETREE[t] + p.Co2EFarm[t] - p.DoubleCountCo2[t] + p.Co2Pulse
        end

        # Convert emissions to GtC units (required by FAIR).
        v.total_CO₂emiss_GtC[t] = v.E[t] * (12.01/44.01)
        v.landuse_CO₂emiss_GtC[t] = (p.ETREE[t] + p.Co2EFarm[t]) * (12.01/44.01)

        # Define function for CUMETREE
        if is_first(t)
            v.CUMETREE[t] = p.cumetree0
        else
            v.CUMETREE[t] = v.CUMETREE[t-1] + (p.ETREE[t] + p.Co2EFarm[t])
        end

        # Define function for CCA
        if is_first(t)
            v.CCA[t] = p.cca0
        else
            v.CCA[t] = (v.CCA[t-1] + v.EIND[t-1]) /3.666
        end

        # Define function for CCATOT
        v.CCATOT[t] = v.CCA[t] + v.CUMETREE[t]

        if gettime(t) != 2020
            # CH₄ and N₂O for FAIR module (scale agriculture CH₄ and N₂O emissions from kg to Mt with factor 1e9).
            v.MethE[t] = p.MethEFarm[t] / 1e9 + p.MethERCP[t]
            # FARM emissions in kg N₂O. FAIR and RCP have Mt N₂/yr. kg -> Mt = 1e9. N₂O -> N₂ = (28.01/44.01)
            v.N2oE[t]   = p.N2oEFarm[t] / 1e9 * (28.01/44.01) + p.N2oERCP[t]
        else
            v.MethE[t] = p.MethEFarm[t] / 1e9 + p.MethERCP[t] + p.MethPulse
            v.N2oE[t]   = p.N2oEFarm[t] / 1e9 * (28.01/44.01) + p.N2oERCP[t] + p.N2oPulse
        end
    end
end
