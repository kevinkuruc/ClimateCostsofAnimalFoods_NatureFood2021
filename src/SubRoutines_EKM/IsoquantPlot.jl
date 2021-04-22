#######################################################################################################################
# Calculate Tradeoffs Between Industrial and Animal Greenhouse Gas Emissions.
#######################################################################################################################
# Description: This function calculates the isoquant curves that show the combinations of industrial emissions and
#              agricultural emissions reductions to achieve different temperature targets over the next century. It
#              then plots and saves the results for Figure 3 in the manuscript.
#----------------------------------------------------------------------------------------------------------------------

function Isoquants()

    # Get index for 2020
    index_2020 = findfirst(x -> x == 2020, 1765:2500)

    # Set temperature targets.
    isotemps = [1.5 2 2.5 3]

    # Set range of agriculture animal product reductions.
    MReduc1 = collect(0:.02:1)

    # Initialize array to store industrial reductions.
    EIndReduc1 = zeros(length(MReduc1), length(isotemps))

    # Create an instance of DICE-FARM.
    m = create_dice_farm()

    # Loop through to calculate carbon and agriculture emissions combinations to meet a given temperautre target.
    for MAXTEMP = 1:length(isotemps)
        println("Finished a temp!")
        for j = 1:length(MReduc1)
            global CO2step = .002
            global Co2Reduc = 1 + CO2step
            maxtemp = 1.

            # Set condition while maximum modeled temperature is lower than target isoquant temperature.
            while maxtemp<isotemps[MAXTEMP]
                Co2Reduc = Co2Reduc - CO2step
                update_param!(m, :MeatReduc, MReduc1[j])
                update_param!(m, :EIndReduc, Co2Reduc)
                run(m)
                temp = m[:co2_cycle, :T]
                maxtemp = maximum(temp[index_2020:index_2020+100])  #temp in next 100 years
            end

        # Assign mitigation level and maximum temperature to an array.
        EIndReduc1[j, MAXTEMP] = Co2Reduc
        end
    end

    # Calcualte mitigation % levels and create Figure 3.
    M1 = 100*(ones(length(MReduc1)) - MReduc1)
    E1 = 100*(ones(size(EIndReduc1)[1], length(isotemps)) - EIndReduc1)
    plot(E1, M1, label=["1.5 Deg" "2 Deg" "2.5 Deg" "3 Deg"], color=:black, linestyle=[:solid :dash :dashdot :dot], linewidth=2, ylabel="Agricultural Emissions \n (% of Baseline)", xlabel="Industrial Emissions \n (% of Baseline)", xlims=(0, 100), xticks=0:10:100, yticks=0:10:100, legend=:topright, grid=false)
    savefig(joinpath(output_directory, "Figure2.pdf"))
    savefig(joinpath(output_directory, "Figure2.svg"))
end
