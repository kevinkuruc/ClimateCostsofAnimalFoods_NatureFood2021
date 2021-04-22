@defcomp farm begin

    # --------- Inputs (Number of Kg of each Animal consumed; Emissions Intensities; Control Variables for Looping --------- #

    MeatReduc           = Parameter()               #Control Variable for IsoCost Curves

    sigmaBeefMeth       = Parameter() # Kg of CH₄ Emissions from Beef (need to convert millions of animals into Megatons CH4)
    sigmaBeefCo2        = Parameter() # Kg of CO₂ per kg of protein from Beef (need to convert millions of animals into Gigatons)
    sigmaBeefN2o        = Parameter() # Kg of N₂O per kg of protein from Beef

    sigmaDairyMeth      = Parameter() # Kg of CH₄ Emissions from Beef (need to convert millions of animals into Megatons CH4)
    sigmaDairyCo2       = Parameter() # Kg of CO₂ per kg of protein from Beef (need to convert millions of animals into Gigatons)
    sigmaDairyN2o       = Parameter() # Kg of N₂O per kg of protein from Beef

    sigmaPoultryMeth    = Parameter() # Kg of CH₄ Emissions from Beef (need to convert millions of animals into Megatons CH4)
    sigmaPoultryCo2     = Parameter() # Kg of CO₂ per kg of protein from Beef (need to convert millions of animals into Gigatons)
    sigmaPoultryN2o     = Parameter() # Kg of N₂O per kg of protein from Beef

    sigmaPorkMeth       = Parameter() # Kg of CH₄ Emissions from Beef (need to convert millions of animals into Megatons CH4)
    sigmaPorkCo2        = Parameter() # Kg of CO₂ per kg of protein from Beef (need to convert millions of animals into Gigatons)
    sigmaPorkN2o        = Parameter() # Kg of N₂O per kg of protein from Beef

    sigmaEggsMeth       = Parameter() # Kg of CH₄ Emissions from Beef (need to convert millions of animals into Megatons CH4)
    sigmaEggsCo2        = Parameter() # Kg of CO₂ per kg of protein from Beef (need to convert millions of animals into Gigatons)
    sigmaEggsN2o        = Parameter() # Kg of N₂O per kg of protein from Beef

    sigmaSheepGoatMeth  = Parameter() # Kg of CH₄ Emissions from Beef (need to convert millions of animals into Megatons CH4)
    sigmaSheepGoatCo2   = Parameter() # Kg of CO₂ per kg of protein from Beef (need to convert millions of animals into Gigatons)
    sigmaSheepGoatN2o   = Parameter() # Kg of N₂O per kg of protein from Beef

    Beef                = Parameter(index=[time]) # Beef Produced (kgs of protein) [Annual]
    Dairy               = Parameter(index=[time]) # Dairy Produced (kgs of protein) [Annual]
    Poultry             = Parameter(index=[time]) # Poultry Produced (kgs of protein) [Annual]
    Pork                = Parameter(index=[time]) # Pork Produced (kgs of protein) [Annual]
    Eggs                = Parameter(index=[time]) # Eggs Produced (kgs of protein) [Annual]
    SheepGoat           = Parameter(index=[time]) # Sheep & Goat Produced (kgs of protein) [Annual]

    # ------ Output of Farm (Emissions) ---------- #

    Co2EFarm        = Variable(index=[time])    # GtCO₂
    MethEFarm       = Variable(index=[time])    # kg
    N2oEFarm        = Variable(index=[time])    # kg

    MethEBeef       = Variable(index=[time])    # CH₄ emitted Beef (kg)
    Co2EBeef        = Variable(index=[time])    # CO₂ emitted from Beef (kg)
    N2oEBeef        = Variable(index=[time])    # N₂O emitted from Beef (kg)

    MethEDairy      = Variable(index=[time])    # CH₄ emitted Beef (kg)
    Co2EDairy       = Variable(index=[time])    # CO₂ emitted from Beef (kg)
    N2oEDairy       = Variable(index=[time])    # N₂O emitted from Beef (kg)

    MethEPoultry    = Variable(index=[time])    # CH₄ emitted Beef (kg)
    Co2EPoultry     = Variable(index=[time])    # CO₂ emitted from Beef (kg)
    N2oEPoultry     = Variable(index=[time])    # N₂O emitted from Beef (kg)

    MethEPork       = Variable(index=[time])    # CH₄ emitted Beef (kg)
    Co2EPork        = Variable(index=[time])    # CO₂ emitted from Beef (kg)
    N2oEPork        = Variable(index=[time])    # N₂O emitted from Beef (kg)

    MethEEggs       = Variable(index=[time])    # CH₄ emitted Beef (kg)
    Co2EEggs        = Variable(index=[time])    # CO₂ emitted from Beef (kg)
    N2oEEggs        = Variable(index=[time])    # N₂O emitted from Beef (kg)

    MethESheepGoat  = Variable(index=[time])    # CH₄ emitted Beef (kg)
    Co2ESheepGoat   = Variable(index=[time])    # CO₂ emitted from Beef (kg)
    N2oESheepGoat   = Variable(index=[time])    # N₂O emitted from Beef (kg)


    function run_timestep(p, v, d, t)

        if gettime(t) >= 2020 # Allows planner to solve for optimal veg frac after 2020
            Beef = (1-p.MeatReduc)*p.Beef[t]
            Pork = (1-p.MeatReduc)*p.Pork[t]
            Poultry = (1-p.MeatReduc)*p.Poultry[t]
            Dairy = (1-p.MeatReduc)*p.Dairy[t]
            Eggs = (1-p.MeatReduc)*p.Eggs[t]
            SheepGoat = (1-p.MeatReduc)*p.SheepGoat[t]
        else
            Beef = p.Beef[t]
            Pork = p.Pork[t]
            Poultry = p.Poultry[t]
            Dairy = p.Dairy[t]
            Eggs = p.Eggs[t]
            SheepGoat = p.SheepGoat[t]
        end

        # Calculate different agricutlure emissions for CO₂, N₂O, and CH₄.
        v.MethEBeef[t]      = p.sigmaBeefMeth*Beef
        v.Co2EBeef[t]       = p.sigmaBeefCo2*Beef
        v.N2oEBeef[t]       = p.sigmaBeefN2o*Beef

        v.MethEDairy[t]     = p.sigmaDairyMeth*Dairy
        v.Co2EDairy[t]      = p.sigmaDairyCo2*Dairy
        v.N2oEDairy[t]      = p.sigmaDairyN2o*Dairy

        v.MethEPoultry[t]   = p.sigmaPoultryMeth*Poultry
        v.Co2EPoultry[t]    = p.sigmaPoultryCo2*Poultry
        v.N2oEPoultry[t]    = p.sigmaPoultryN2o*Poultry

        v.MethEPork[t]      = p.sigmaPorkMeth*Pork
        v.Co2EPork[t]       = p.sigmaPorkCo2*Pork
        v.N2oEPork[t]       = p.sigmaPorkN2o*Pork

        v.MethEEggs[t]      = p.sigmaEggsMeth*Eggs
        v.Co2EEggs[t]       = p.sigmaEggsCo2*Eggs
        v.N2oEEggs[t]       = p.sigmaEggsN2o*Eggs

        v.MethESheepGoat[t] = p.sigmaSheepGoatMeth*SheepGoat
        v.Co2ESheepGoat[t]  = p.sigmaSheepGoatCo2*SheepGoat
        v.N2oESheepGoat[t]  = p.sigmaSheepGoatN2o*SheepGoat

        # Total emissions output
        v.MethEFarm[t]      = (v.MethEBeef[t] + v.MethEDairy[t] + v.MethEPoultry[t] + v.MethEPork[t] + v.MethEEggs[t] + v.MethESheepGoat[t])
        v.Co2EFarm[t]       = ((v.Co2EBeef[t] + v.Co2EDairy[t] + v.Co2EPoultry[t] + v.Co2EPork[t] + v.Co2EEggs[t] + v.Co2ESheepGoat[t])/1e12)
        v.N2oEFarm[t]       = (v.N2oEBeef[t] + v.N2oEDairy[t] + v.N2oEPoultry[t] + v.N2oEPork[t] + v.N2oEEggs[t] + v.N2oESheepGoat[t])
    end
end
