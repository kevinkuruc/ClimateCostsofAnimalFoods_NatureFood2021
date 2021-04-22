#######################################################################################################################
# Calculate social costs of differnet products under EPA framework.
#######################################################################################################################
# Description: This function calculates social costs of different dietary choices and animal/agricultural products using
#              the EPA discounting framework.
#
# Function Arguments:
#
#       Diets       = Dietary values for different countries/regions.
#       Intensities = Dietary intensities for different countries/regions.
#       discounts   = Pure rate of time preference.
#----------------------------------------------------------------------------------------------------------------------


function VegSocialCosts_EPA(Diets, Intensities, discounts)

    # Get index for 2020
    index_2020 = findfirst(x -> x == 2020, 1765:2500)

    # Initialize DICE-FARM with provided intensity and discount rate values.
    DICEFARM = create_dice_farm()
    update_intensities(DICEFARM, Intensities)
    run(DICEFARM)

    # Calculate baseline welfare and consumption.
    BaseWelfare = DICEFARM[:welfare, :UTILITY]
    BaseCons    = 1e12*DICEFARM[:neteconomy, :C][index_2020:end]

    # Initialize social costs for vegan, vegetarian and then each of 6 animal products.
    SocialCosts = zeros(length(discounts), 8)

    # Calculate baseline amount of animal products consumed.
    OrigBeef      = DICEFARM[:farm, :Beef]
    OrigDairy     = DICEFARM[:farm, :Dairy]
    OrigPork      = DICEFARM[:farm, :Pork]
    OrigPoultry   = DICEFARM[:farm, :Poultry]
    OrigEggs      = DICEFARM[:farm, :Eggs]
    OrigSheepGoat = DICEFARM[:farm, :SheepGoat]

    # Create copies of animal product consumtpion for vegan emissions pulse.
    BeefPulse      = copy(OrigBeef)
    DairyPulse     = copy(OrigDairy)
    PorkPulse      = copy(OrigPork)
    PoultryPulse   = copy(OrigPoultry)
    EggsPulse      = copy(OrigEggs)
    SheepGoatPulse = copy(OrigSheepGoat)

    # Calculate pulses.
    BeefPulse[index_2020]      = OrigBeef[index_2020] + 100000*(Diets[1])
    DairyPulse[index_2020]     = OrigDairy[index_2020] + 100000*(Diets[2])
    PoultryPulse[index_2020]   = OrigPoultry[index_2020] + 100000*(Diets[3])
    PorkPulse[index_2020]      = OrigPork[index_2020]  + 100000*(Diets[4])
    EggsPulse[index_2020]      = OrigEggs[index_2020]  + 100000*(Diets[5])
    SheepGoatPulse[index_2020] = OrigSheepGoat[index_2020] + 100000*(Diets[6])

    # Calculate vegan pulse response.
    VeganPulse = create_dice_farm()
    update_intensities(VeganPulse, Intensities)
    update_param!(VeganPulse, :Beef, BeefPulse)
    update_param!(VeganPulse, :Dairy, DairyPulse)
    update_param!(VeganPulse, :Pork, PorkPulse)
    update_param!(VeganPulse, :Poultry, PoultryPulse)
    update_param!(VeganPulse, :Eggs, EggsPulse)
    update_param!(VeganPulse, :SheepGoat, SheepGoatPulse)
    run(VeganPulse)
    VeganCons  = 1e12*VeganPulse[:neteconomy, :C][index_2020:end]

    # Calculate social costs for EPA framework.
    for (i, d) in enumerate(discounts)
        SocialCosts[i,1] = 1e-5*EPADamages(VeganCons, BaseCons, d)
    end

    # Create copies for vegetarian pulse.
    BeefPulse      = copy(OrigBeef)
    PoultryPulse   = copy(OrigPoultry)
    PorkPulse      = copy(OrigPork)
    SheepGoatPulse = copy(OrigSheepGoat)

    # Calculate pulse responses.
    BeefPulse[index_2020]      = OrigBeef[index_2020] + 100000*(Diets[1])
    PoultryPulse[index_2020]   = OrigPoultry[index_2020] + 100000*(Diets[3])
    PorkPulse[index_2020]      = OrigPork[index_2020]  + 100000*(Diets[4])
    SheepGoatPulse[index_2020] = OrigSheepGoat[index_2020] + 100000*(Diets[6])

    # Calculate vegetarin pulse response.
    VegetarianPulse = create_dice_farm()
    update_intensities(VegetarianPulse, Intensities)
    update_param!(VegetarianPulse, :Beef, BeefPulse)
    update_param!(VegetarianPulse, :Poultry, PoultryPulse)
    update_param!(VegetarianPulse, :Pork, PorkPulse)
    update_param!(VegetarianPulse, :SheepGoat, SheepGoatPulse)
    run(VegetarianPulse)
    VegetarianCons  = 1e12*VegetarianPulse[:neteconomy, :C][index_2020:end]

    # Calculate social costs for EPA framework.
    for (i, d) in enumerate(discounts)
        SocialCosts[i,2] = 1e-5*EPADamages(VegetarianCons, BaseCons, d)
    end

    # Calculate social costs by animal/agricultural product.
    Meats = [:Beef, :Dairy, :Poultry, :Pork,  :Eggs, :SheepGoat]
    Origs = [OrigBeef, OrigDairy, OrigPoultry, OrigPork, OrigEggs, OrigSheepGoat]
    j = collect(1:1:length(Meats))
    for (meat, O, j) in zip(Meats, Origs, j)
        tempModel = create_dice_farm();
        update_intensities(tempModel, Intensities)
        Pulse = copy(O)
        Pulse[index_2020] = Pulse[index_2020] + 2000.0 #add 2000 kg of protein (or 2000000 grams)
        update_param!(tempModel, meat, Pulse)
        run(tempModel)
        tempCons = 1e12*tempModel[:neteconomy, :C][index_2020:end]
        for (i,d) in enumerate(discounts)
            SocialCosts[i, j+2] = 1e-5*EPADamages(tempCons, BaseCons, d)
        end
    end

    # Assign diet names.
    Diets = ["Vegan", "Vegetarian", "Beef", "Dairy", "Poultry", "Pork", "Eggs", "Sheep/Goat"]

    # Return social cost results by diet type.
    return SocialCosts
end
