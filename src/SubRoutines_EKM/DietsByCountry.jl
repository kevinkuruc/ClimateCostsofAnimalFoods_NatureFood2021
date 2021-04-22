#######################################################################################################################
# Calculate Dietary Social Costs by Country.
#######################################################################################################################
# Description: This function calculates the spatial variation in the climate costs of animal product consumption and
#              production across countries. It produces a table of data used to create Figure 4.
#
#----------------------------------------------------------------------------------------------------------------------


function DietaryCostsByCountry()

    # Load relevant data.
    d = CSV.read(joinpath(data_directory, "2013Diets.csv"), DataFrame)

    # Initialize costs.
    VegCosts = zeros(size(d)[1], 2)

    # Initialize intensity values.
    ESEA_Intensities    = [49.9 6.51 .27    ; 19.9 1.60 .07     ; 35.7 .02 .05  ; 26.7 .60 .05 ; 26.9 .04 .04   ; 30.0 3.20 .13]
    EEU_Intensities     = [29.9 1.55 .07    ; 10.1 0.84 .03     ; 14.4 .01 .02  ; 25.1 .27 .03  ; 8.2 .01 .03   ; 14.3 1.35 .05]
    LatAm_Intensities   = [141.8 5.80 .24   ; 13.1 2.14 .24     ; 25.4 .01 .02  ; 27.4 .46 .04 ; 16.9 .13 .02  ; 12.5 4.62 .13]
    MidEast_Intensities = [16.0 4.13  .43   ; 14.9 2.60 .25     ; 27.3 .02 .03  ; 39.9 .48 .04 ; 14.2 .08 .02  ; 24.3 3.91 .40]
    NO_Intensities      = [14.1 2.70 .14    ; 14.4 1.06 .02     ; 14.4 .01 .02  ; 15.2 .45 .02 ; 7.6 .09 .02   ; 22.3 3.06 .18]
    Oceania_Intensities = [21.7 3.23 .22    ; 15.0 0.80 .05     ; 28.4 .02 .02  ; 25.0 1.47 .02 ; 12.8 .03 .02  ; 16.3 2.15 .10]
    Russia_Intensities  = [27.0 1.53 .06    ; 8.8 0.90 .03      ; 17.9 .01 .01  ; 20.8  .20  .03; 9.1 .02  .01  ; 13.0 3.04 .12]
    SAS_Intensities     = [58.5 9.33 .32    ; 25.1 2.4 .10      ; 24.3 .02 .04  ; 21.5 1.12 .05 ; 14.0 .05 .03  ; 36.6 5.10 .16]
    SSA_Intensities     = [5.9 8.31 .41     ; 5.6 3.84 .16      ; 28.5 .03 .03  ; 13.3 0.86 .04 ; 10.8 .06 .04  ; 6.3 5.35 .20]
    WEU_Intensities     = [26.4 1.91 .12    ; 12.2 0.73 .04     ; 23.9 .01 .02  ; 27.2 .34 .04  ; 15.2 .02 .02  ; 18.9 1.79 .09]

    # Loop through diets by type.
    for i = 1:length(VegCosts[:,1])
        Diets = zeros(6)
        Diets[1] = d[i, :bovine]
        Diets[2] = d[i, :milk]
        Diets[3] = d[i, :poultry]
        Diets[4] = d[i, :pig]
        Diets[5] = d[i, :eggs]
        Diets[6] = d[i, :muttongoat]

        # Assign region-based intensity.
        if d[i, :gleam_region]=="ne_na"
            intensity = MidEast_Intensities
        elseif d[i, :gleam_region]=="s_asia"
            intensity = SAS_Intensities
        elseif d[i, :gleam_region]=="w_europe"
            intensity = WEU_Intensities
        elseif d[i, :gleam_region]=="ssa"
            intensity = SSA_Intensities
        elseif d[i, :gleam_region]=="lac"
            intensity = LatAm_Intensities
        elseif d[i, :gleam_region]=="oceania"
            intensity = Oceania_Intensities
        elseif d[i, :gleam_region]=="northam"
            intensity = NO_Intensities
        elseif d[i, :gleam_region]=="e_se_asia"
            intensity = ESEA_Intensities
        elseif d[i, :gleam_region]=="e_europe"
            intensity = EEU_Intensities
        elseif d[i, :gleam_region]=="russianfed"
            intensity = Russia_Intensities
        end

        # Calcualte country-level social costs.
        sol = VegSocialCosts(Diets, intensity)
        VegCosts[i,1] = sol[1,2]
        VegCosts[i,2] = sol[2,2]
        Country = d[i, :country]

        # Track completed countries.
        println("Finished $Country")
    end

    # Create DataFrame of country level costs.
    out = DataFrame(Country = d[!,:country], VeganCosts = VegCosts[:,1], VegetarianCosts = VegCosts[:,2])

    # Return results.
    return out
end
