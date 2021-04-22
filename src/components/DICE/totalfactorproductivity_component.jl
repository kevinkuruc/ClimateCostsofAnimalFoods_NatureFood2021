@defcomp totalfactorproductivity begin

    a0      = Parameter()            # Initial level of total factor productivity
    ga0     = Parameter()            # Initial growth rate for TFP per 5 years
    dela    = Parameter()            # Decline rate of TFP per 5 years

    GA      = Variable(index=[time]) # Growth rate of productivity
    AL      = Variable(index=[time]) # Level of total factor productivity


    function run_timestep(p, v, d, t)

        #Define function for GA
        if is_first(t)
            v.GA[t] = (1+p.ga0)^.2 - 1
        else
            v.GA[t] = v.GA[t - 1] * exp(-p.dela)
        end

        #Define function for AL
        if is_first(t)
            v.AL[t] = p.a0
        else
            v.AL[t] = v.AL[t-1]/(1 - v.GA[t-1])
        end
    end
end
