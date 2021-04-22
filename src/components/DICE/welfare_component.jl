@defcomp welfare begin

    rho             = Parameter()             # Average utility social discount rate (annual)
    elasmu          = Parameter()             # Elasticity of marginal utility of consumption
    scale1          = Parameter()             # Multiplicative scaling coefficient
    scale2          = Parameter()             # Additive scaling coefficient
    CPC             = Parameter(index=[time]) # Per capita consumption (thousands 2010 USD per year)
    l               = Parameter(index=[time]) # Level of population and labor (Millions)

    UTILITY         = Variable()              # Welfare Function
    CEMUTOTPER      = Variable(index=[time])  # Period utility
    CUMCEMUTOTPER   = Variable(index=[time])  # Cumulative period utility
    PERIODU         = Variable(index=[time])  # One period utility function
    rr              = Variable(index=[time])  # Pure social discount rate for that period


    function run_timestep(p, v, d, t)

        # Define function for PERIODU
        if p.elasmu!=1
            v.PERIODU[t] = (p.CPC[t] ^ (1 - p.elasmu) - 1) / (1 - p.elasmu)
        else
            v.PERIODU[t] = log(p.CPC[t])
        end

        #Define function for rr
        if is_first(t)
            v.rr[t] = 1.
        else
            v.rr[t] = v.rr[t-1]*(1-p.rho)
        end

        # Define function for CEMUTOTPER
        v.CEMUTOTPER[t] = v.PERIODU[t] * p.l[t] * v.rr[t]

        # Define function for CUMCEMUTOTPER
        v.CUMCEMUTOTPER[t] = v.CEMUTOTPER[t] + (!is_first(t) ? v.CUMCEMUTOTPER[t-1] : 0)

        # Define function for UTILITY
        if is_last(t)
            v.UTILITY =  p.scale1 * v.CUMCEMUTOTPER[t] + p.scale2
        end
    end
end
