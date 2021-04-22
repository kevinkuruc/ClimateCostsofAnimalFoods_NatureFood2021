# -------------------------------------------------------------------------------------
# This file replicates Table 1 using 20, 100, and 500 year global warming potentials.
# -------------------------------------------------------------------------------------

# Add a check for which SCC to use (options = :EPA for U.S. SCC estimate from DICE or :Nordhaus for Nordhaus PNAS 2017 estimate).
scc_version = :Nordhaus

# 20, 100, and 500 year GWPs
# From Table 2.14 (https://www.ipcc.ch/site/assets/uploads/2018/02/ar4-wg1-chapter2-1.pdf)
gwp_ch4_20 = 72
gwp_n2o_20 = 289

gwp_ch4_100 = 25
gwp_n2o_100 = 298

gwp_ch4_500 = 7.6
gwp_n2o_500 = 153

# Beef emissions intensities (in kg gas / kg protein) from Table S7 in manuscript.
beef_co2 = 65.1
beef_ch4 = 6.5
beef_n2o = 0.22

dairy_co2 = 14.6
dairy_ch4 = 2.1
dairy_n2o = 0.22

poultry_co2 = 25.6
poultry_ch4 = 0.02
poultry_n2o = 0.03

pork_co2 = 25.1
pork_ch4 = 0.70
pork_n2o = 0.04

eggs_co2 = 20.1
eggs_ch4 = 0.07
eggs_n2o = 0.03

sheepgoat_co2 = 20.0
sheepgoat_ch4 = 4.5
sheepgoat_n2o = 0.16

# SAD (kg protein annually)
beef_SAD 		= 4.5
dairy_SAD 		= 8
poultry_SAD 	= 6.5
pork_SAD 		= 2.7
eggs_SAD		= 1.6
sheepgoat_SAD 	= 0.06

#Global Diet (population times per capita consumption in kg per year)
beef_global 	= 1e6*7852.9*1.4
dairy_global 	= 1e6*7852.9*2.6
poultry_global 	= 1e6*7852.9*2.0
pork_global 	= 1e6*7852.9*2.0
eggs_global		= 1e6*7852.9*1.25
sheepgoat_global= 1e6*7852.9*0.4

# Nordhaus SCC from PNAS - Revisiting the Social Cost of Carbon
# EPA SCC for DICE (averaged over 5 scenarios) in 2020 under 3% discount rate
# See Table A3: https://19january2017snapshot.epa.gov/sites/production/files/2016-12/documents/sc_co2_tsd_august_2016.pdf
if scc_version == :EPA
	scc = 37.8
elseif scc_version == :Nordhaus
	scc = 31.0
else
	println("You picked an incorrect SCC version.")
end

# ------------------------------
# 20 Year GWP
#-------------------------------

# Calculate CO₂ and CO₂ equivalent emissions for 20 grams (0.02 kg) beef.
beef_co2_emiss_20 		= beef_co2 * 0.02
beef_ch4_equiv_20 		= beef_ch4 * 0.02 * gwp_ch4_20
beef_n2o_equiv_20 		= beef_n2o * 0.02 * gwp_n2o_20

dairy_co2_emiss_20 		= dairy_co2 * 0.02
dairy_ch4_equiv_20 		= dairy_ch4 * 0.02 * gwp_ch4_20
dairy_n2o_equiv_20 		= dairy_n2o * 0.02 * gwp_n2o_20

poultry_co2_emiss_20 	= poultry_co2 * 0.02
poultry_ch4_equiv_20 	= poultry_ch4 * 0.02 * gwp_ch4_20
poultry_n2o_equiv_20 	= poultry_n2o * 0.02 * gwp_n2o_20

pork_co2_emiss_20 		= pork_co2 * 0.02
pork_ch4_equiv_20 		= pork_ch4 * 0.02 * gwp_ch4_20
pork_n2o_equiv_20 		= pork_n2o * 0.02 * gwp_n2o_20

eggs_co2_emiss_20 		= eggs_co2 * 0.02
eggs_ch4_equiv_20 		= eggs_ch4 * 0.02 * gwp_ch4_20
eggs_n2o_equiv_20 		= eggs_n2o * 0.02 * gwp_n2o_20

sheepgoat_co2_emiss_20 	= sheepgoat_co2 * 0.02
sheepgoat_ch4_equiv_20 	= sheepgoat_ch4 * 0.02 * gwp_ch4_20
sheepgoat_n2o_equiv_20 	= sheepgoat_n2o * 0.02 * gwp_n2o_20

# Calculate total CO₂ and CO₂ equivalent emissions and scale to tonnes.
beef_total_co2_tons_20 		= (beef_co2_emiss_20 + beef_ch4_equiv_20 + beef_n2o_equiv_20) / 1000
dairy_total_co2_tons_20 	= (dairy_co2_emiss_20 + dairy_ch4_equiv_20 + dairy_n2o_equiv_20) /1000
poultry_total_co2_tons_20 	= (poultry_co2_emiss_20 + poultry_ch4_equiv_20 + poultry_n2o_equiv_20) /1000
pork_total_co2_tons_20 		= (pork_co2_emiss_20 + pork_ch4_equiv_20 + pork_n2o_equiv_20) /1000
eggs_total_co2_tons_20 		= (eggs_co2_emiss_20 + eggs_ch4_equiv_20 + eggs_n2o_equiv_20) /1000
sheepgoat_total_co2_tons_20 = (sheepgoat_co2_emiss_20 + sheepgoat_ch4_equiv_20 + sheepgoat_n2o_equiv_20) /1000

# Total SAD CO₂ equivalent = diet times CO₂ equivalent of serving (times 50 because annual diet in kg, not 20 g serving).
SAD_total_co2_tons_20   	= 50*(beef_SAD*beef_total_co2_tons_20 + dairy_SAD*dairy_total_co2_tons_20 + poultry_SAD*poultry_total_co2_tons_20 + pork_SAD*pork_total_co2_tons_20 + eggs_SAD*eggs_total_co2_tons_20 + sheepgoat_SAD*sheepgoat_total_co2_tons_20)
vegetarian_total_co2_tons_20= 50*(dairy_SAD*dairy_total_co2_tons_20 + eggs_SAD*eggs_total_co2_tons_20)

# Total global CO₂ equivalent.
global_total_co2_tons_20 	= 50*(beef_global*beef_total_co2_tons_20 + dairy_global*dairy_total_co2_tons_20 + poultry_global*poultry_total_co2_tons_20 + pork_global*pork_total_co2_tons_20 + eggs_global*eggs_total_co2_tons_20 + sheepgoat_global*sheepgoat_total_co2_tons_20)

# Multiply these by the SCC.
sc_global_20 	= global_total_co2_tons_20 * epa_scc
sc_SAD_20 		= SAD_total_co2_tons_20 * epa_scc
sc_vegetarian_20= vegetarian_total_co2_tons_20 * epa_scc
sc_beef_20 		= beef_total_co2_tons_20 * epa_scc
sc_dairy_20 	= dairy_total_co2_tons_20 * epa_scc
sc_poultry_20 	= poultry_total_co2_tons_20 * epa_scc
sc_pork_20 		= pork_total_co2_tons_20 * epa_scc
sc_eggs_20 		= eggs_total_co2_tons_20 * epa_scc
sc_sheepgoat_20 = sheepgoat_total_co2_tons_20 * epa_scc

# ------------------------------
# 100 Year GWP
#-------------------------------

# Calculate CO₂ and CO₂ equivalent emissions for 20 grams (0.02 kg) beef.
beef_co2_emiss_100 		= beef_co2 * 0.02
beef_ch4_equiv_100 		= beef_ch4 * 0.02 * gwp_ch4_100
beef_n2o_equiv_100 		= beef_n2o * 0.02 * gwp_n2o_100

dairy_co2_emiss_100 	= dairy_co2 * 0.02
dairy_ch4_equiv_100 	= dairy_ch4 * 0.02 * gwp_ch4_100
dairy_n2o_equiv_100 	= dairy_n2o * 0.02 * gwp_n2o_100

poultry_co2_emiss_100 	= poultry_co2 * 0.02
poultry_ch4_equiv_100 	= poultry_ch4 * 0.02 * gwp_ch4_100
poultry_n2o_equiv_100 	= poultry_n2o * 0.02 * gwp_n2o_100

pork_co2_emiss_100 		= pork_co2 * 0.02
pork_ch4_equiv_100 		= pork_ch4 * 0.02 * gwp_ch4_100
pork_n2o_equiv_100 		= pork_n2o * 0.02 * gwp_n2o_100

eggs_co2_emiss_100 		= eggs_co2 * 0.02
eggs_ch4_equiv_100 		= eggs_ch4 * 0.02 * gwp_ch4_100
eggs_n2o_equiv_100 		= eggs_n2o * 0.02 * gwp_n2o_100

sheepgoat_co2_emiss_100 = sheepgoat_co2 * 0.02
sheepgoat_ch4_equiv_100 = sheepgoat_ch4 * 0.02 * gwp_ch4_100
sheepgoat_n2o_equiv_100 = sheepgoat_n2o * 0.02 * gwp_n2o_100

# Calculate total CO₂ and CO₂ equivalent emissions and scale to tonnes.
beef_total_co2_tons_100 	= (beef_co2_emiss_100 + beef_ch4_equiv_100 + beef_n2o_equiv_100) / 1000
dairy_total_co2_tons_100 	= (dairy_co2_emiss_100 + dairy_ch4_equiv_100 + dairy_n2o_equiv_100) /1000
poultry_total_co2_tons_100 	= (poultry_co2_emiss_100 + poultry_ch4_equiv_100 + poultry_n2o_equiv_100) /1000
pork_total_co2_tons_100 	= (pork_co2_emiss_100 + pork_ch4_equiv_100 + pork_n2o_equiv_100) /1000
eggs_total_co2_tons_100 	= (eggs_co2_emiss_100 + eggs_ch4_equiv_100 + eggs_n2o_equiv_100) /1000
sheepgoat_total_co2_tons_100= (sheepgoat_co2_emiss_100 + sheepgoat_ch4_equiv_100 + sheepgoat_n2o_equiv_100) /1000

#Total SAD CO₂ equivalent = diet times CO₂ equivalent of serving (times 50 because annual diet in kg, not 20 g serving).
SAD_total_co2_tons_100   	 	= 50*(beef_SAD*beef_total_co2_tons_100 + dairy_SAD*dairy_total_co2_tons_100 + poultry_SAD*poultry_total_co2_tons_100 + pork_SAD*pork_total_co2_tons_100 + eggs_SAD*eggs_total_co2_tons_100 + sheepgoat_SAD*sheepgoat_total_co2_tons_100)
vegetarian_total_co2_tons_100	= 50*(dairy_SAD*dairy_total_co2_tons_100 + eggs_SAD*eggs_total_co2_tons_100)

#Total Global CO₂ equivalent.
global_total_co2_tons_100 		= 50*(beef_global*beef_total_co2_tons_100 + dairy_global*dairy_total_co2_tons_100 + poultry_global*poultry_total_co2_tons_100 + pork_global*pork_total_co2_tons_100 + eggs_global*eggs_total_co2_tons_100 + sheepgoat_global*sheepgoat_total_co2_tons_100)

# Multiply these by the SCC.
sc_global_100 		= global_total_co2_tons_100 * epa_scc
sc_SAD_100 			= SAD_total_co2_tons_100 * epa_scc
sc_vegetarian_100	= vegetarian_total_co2_tons_100 * epa_scc
sc_beef_100 		= beef_total_co2_tons_100 * epa_scc
sc_dairy_100 		= dairy_total_co2_tons_100 * epa_scc
sc_poultry_100 		= poultry_total_co2_tons_100 * epa_scc
sc_pork_100 		= pork_total_co2_tons_100 * epa_scc
sc_eggs_100 		= eggs_total_co2_tons_100 * epa_scc
sc_sheepgoat_100 	= sheepgoat_total_co2_tons_100 * epa_scc

# ------------------------------
# 500 Year GWP
#-------------------------------

# Calculate CO₂ and CO₂ equivalent emissions for 20 grams (0.02 kg) beef.
beef_co2_emiss_500 		= beef_co2 * 0.02
beef_ch4_equiv_500 		= beef_ch4 * 0.02 * gwp_ch4_500
beef_n2o_equiv_500 		= beef_n2o * 0.02 * gwp_n2o_500

dairy_co2_emiss_500 	= dairy_co2 * 0.02
dairy_ch4_equiv_500 	= dairy_ch4 * 0.02 * gwp_ch4_500
dairy_n2o_equiv_500 	= dairy_n2o * 0.02 * gwp_n2o_500

poultry_co2_emiss_500 	= poultry_co2 * 0.02
poultry_ch4_equiv_500 	= poultry_ch4 * 0.02 * gwp_ch4_500
poultry_n2o_equiv_500 	= poultry_n2o * 0.02 * gwp_n2o_500

pork_co2_emiss_500 		= pork_co2 * 0.02
pork_ch4_equiv_500 		= pork_ch4 * 0.02 * gwp_ch4_500
pork_n2o_equiv_500 		= pork_n2o * 0.02 * gwp_n2o_500

eggs_co2_emiss_500 		= eggs_co2 * 0.02
eggs_ch4_equiv_500 		= eggs_ch4 * 0.02 * gwp_ch4_500
eggs_n2o_equiv_500 		= eggs_n2o * 0.02 * gwp_n2o_500

sheepgoat_co2_emiss_500 = sheepgoat_co2 * 0.02
sheepgoat_ch4_equiv_500 = sheepgoat_ch4 * 0.02 * gwp_ch4_500
sheepgoat_n2o_equiv_500 = sheepgoat_n2o * 0.02 * gwp_n2o_500

# Calculate total CO₂ and CO₂ equivalent emissions and scale to tonnes.
beef_total_co2_tons_500 	= (beef_co2_emiss_500 + beef_ch4_equiv_500 + beef_n2o_equiv_500) / 1000
dairy_total_co2_tons_500 	= (dairy_co2_emiss_500 + dairy_ch4_equiv_500 + dairy_n2o_equiv_500) /1000
poultry_total_co2_tons_500 	= (poultry_co2_emiss_500 + poultry_ch4_equiv_500 + poultry_n2o_equiv_500) /1000
pork_total_co2_tons_500 	= (pork_co2_emiss_500 + pork_ch4_equiv_500 + pork_n2o_equiv_500) /1000
eggs_total_co2_tons_500 	= (eggs_co2_emiss_500 + eggs_ch4_equiv_500 + eggs_n2o_equiv_500) /1000
sheepgoat_total_co2_tons_500= (sheepgoat_co2_emiss_500 + sheepgoat_ch4_equiv_500 + sheepgoat_n2o_equiv_500) /1000

#Total SAD CO₂ equivalent = diet times CO₂ equivalent of serving (times 50 because annual diet in kg, not 20 g serving).
SAD_total_co2_tons_500   		= 50*(beef_SAD*beef_total_co2_tons_500 + dairy_SAD*dairy_total_co2_tons_500 + poultry_SAD*poultry_total_co2_tons_500 + pork_SAD*pork_total_co2_tons_500 + eggs_SAD*eggs_total_co2_tons_500 + sheepgoat_SAD*sheepgoat_total_co2_tons_500)
vegetarian_total_co2_tons_500	= 50*(dairy_SAD*dairy_total_co2_tons_500 + eggs_SAD*eggs_total_co2_tons_500)

#Total Global CO₂ equivalent.
global_total_co2_tons_500 		= 50*(beef_global*beef_total_co2_tons_500 + dairy_global*dairy_total_co2_tons_500 + poultry_global*poultry_total_co2_tons_500 + pork_global*pork_total_co2_tons_500 + eggs_global*eggs_total_co2_tons_500 + sheepgoat_global*sheepgoat_total_co2_tons_500)

# Multiply these by the SCC.
sc_global_500 		= global_total_co2_tons_500 * epa_scc
sc_SAD_500 			= SAD_total_co2_tons_500 * epa_scc
sc_vegetarian_500	= vegetarian_total_co2_tons_500 * epa_scc
sc_beef_500 		= beef_total_co2_tons_500 * epa_scc
sc_dairy_500 		= dairy_total_co2_tons_500 * epa_scc
sc_poultry_500 		= poultry_total_co2_tons_500 * epa_scc
sc_pork_500 		= pork_total_co2_tons_500 * epa_scc
sc_eggs_500 		= eggs_total_co2_tons_500 * epa_scc
sc_sheepgoat_500 	= sheepgoat_total_co2_tons_500 * epa_scc
