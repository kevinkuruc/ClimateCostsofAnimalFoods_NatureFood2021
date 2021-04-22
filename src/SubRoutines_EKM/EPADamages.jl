#######################################################################################################################
# Calculate EPA Consistent Damages.
#######################################################################################################################
# Description: This function calculates climate damages/impacts consistent with the EPA discounting framework.
#
# Function Arguments:
#
#       Cons1    = Consumption in the scenario case with additional emissions.
#		BaseCons = Baseline consumption level.
#		rho      = Pure rate of time preference.
#----------------------------------------------------------------------------------------------------------------------

function EPADamages(Cons1::Array, BaseCons::Array, rho::Float64)

	# Calculate damages.
	Damages = BaseCons-Cons1

	# Calculate discount factors.
	discount = ones(length(Damages))
	for i = 2:length(Damages)
		discount[i] = (1-rho)*discount[i-1] 
	end

	# Calculate discounted damages.
	DiscountedDamages = discount.*Damages

	# Calculate sum of discounted damages over time.
	Tot = sum(DiscountedDamages)

	# Return results.
	return Tot
end
