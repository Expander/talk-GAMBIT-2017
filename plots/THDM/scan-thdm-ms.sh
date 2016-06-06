#!/bin/sh

# prints SLHA block
print_slha_block_awk='
BEGIN {
   is_block = 0;
   if (block == "") {
      print "Error: block name not defined";
      print "   Please define the block name with -v block=<block-name>";
      exit 1
   }
}
{
   pattern     = "^block[[:blank:]]*" tolower(block) "([^[:graph:]].*)?$";
   not_pattern = "^block[[:blank:]]*.*$";

   if (tolower($0) ~ pattern) {
      is_block = 1
   } else if (tolower($0) ~ not_pattern) {
      is_block = 0
   };

   if (is_block)
      print $0
}
'

# prints block entry
# expects block entry keys in the form x or x:y or x:y:z etc.
print_block_entry_awk='
{
  len = split(keys,k,":");

  matches = 1;

  for (i in k) {
     if ($(i) != k[i])
        matches = 0
  }

  if (matches == 1)
     print $(len + 1)
}
'

slha_templ="
Block FlexibleSUSY
    0   1.000000000e-06      # precision goal
    1   0                    # max. iterations (0 = automatic)
    2   0                    # algorithm (0 = two_scale, 1 = lattice)
    3   1                    # calculate SM pole masses
    4   2                    # pole mass loop order
    5   2                    # EWSB loop order
    6   2                    # beta-functions loop order
    7   2                    # threshold corrections loop order
    8   1                    # Higgs 2-loop corrections O(alpha_t alpha_s)
    9   1                    # Higgs 2-loop corrections O(alpha_b alpha_s)
   10   1                    # Higgs 2-loop corrections O(alpha_t^2 + alpha_t alpha_b + alpha_b^2)
   11   1                    # Higgs 2-loop corrections O(alpha_tau^2)
   12   0                    # force output
   13   1                    # Top quark 2-loop corrections QCD
   14   1.000000000e-11      # beta-function zero threshold
   15   0                    # calculate observables (a_muon, ...)
   16   0                    # force positive majorana masses
   17   1                    # calculate parametric uncertainties
Block SMINPUTS               # Standard Model inputs
    1   1.279440000e+02      # alpha^(-1) SM MSbar(MZ)
    2   1.166380000e-05      # G_Fermi
    3   1.184000000e-01      # alpha_s(MZ) SM MSbar
    4   9.118760000e+01      # MZ(pole)
    5   4.180000000e+00      # mb(mb) SM MSbar
    6   1.733400000e+02      # mtop(pole)
    7   1.777000000e+00      # mtau(pole)
    8   0.000000000e+00      # mnu3(pole)
    9   80.425               # MW pole
   11   5.109989020e-04      # melectron(pole)
   12   0.000000000e+00      # mnu1(pole)
   13   1.056583570e-01      # mmuon(pole)
   14   0.000000000e+00      # mnu2(pole)
   21   4.750000000e-03      # md(2 GeV) MS-bar
   22   2.400000000e-03      # mu(2 GeV) MS-bar
   23   1.040000000e-01      # ms(2 GeV) MS-bar
   24   1.270000000e+00      # mc(mc) MS-bar
Block MINPAR
    3   5                    # TanBeta
"

thdm_models="
THDMIIMSSMBC
THDMIIMSSMBCFull
"

hgthbm_models="
HGTHDMIIMSSMBC
HGTHDMIIMSSMBCFull
"

mA=200
Xt_max=2.44949

ms_steps=100
ms_start="1*10^2"
ms_stop="1*10^16"
tb_steps=100
tb_start=1
tb_stop=10

scan_ms() {
    local model="$1"
    local input="$2"
    local output="$3"
    local Xt="$4"
    local Xb=0
    local Xe=0
    local mu="$5"
    local m1="$6"
    local m2="$7"
    local m3="$8"

    local Mh=
    local DMh=
    local DMh_as_m=
    local DMh_as_p=
    local DMh_Mt_m=
    local DMh_Mt_p=
    local DMh_Q_m=
    local DMh_Q_p=
    local block=
    local slha_output=
    local ms=
    local mu_value=
    local m1_value=
    local m2_value=
    local m3_value=

    echo "> running $model with Xt = $Xt, mu = $mu, m1 = $m1, m2 = $m2, m3 = $m3"

    for i in `seq 0 $ms_steps`; do
        ms=$(cat <<EOF | bc -l
scale=10
e(l($ms_start) + (l($ms_stop) - l($ms_start))*${i} / $ms_steps)
EOF
             )

        mu_value="$mu"; [ "x$mu_value" = "xms" ] && mu_value="$ms"
        m1_value="$m1"; [ "x$m1_value" = "xms" ] && m1_value="$ms"
        m2_value="$m2"; [ "x$m2_value" = "xms" ] && m2_value="$ms"
        m3_value="$m3"; [ "x$m3_value" = "xms" ] && m3_value="$ms"

        slha_input=$(cat <<EOF
${input}
Block EXTPAR                 # Input parameters
    0   ${ms}                # MSUSY
    1   173.34               # MEWSB
    2   ${mu_value}          # Mu
    3   ${m1_value}          # M1
    4   ${m2_value}          # M2
    5   ${m3_value}          # M3
    6   ${mA}                # MA(MEWSB)
    7   ${Xt}                # Xt
    8   ${Xb}                # Xb
    9   ${Xe}                # Xe
  100   2                    # lambda BCs loop order
Block XuIN                   # Xu(MSUSY)
    1  1  0
    2  2  0
    3  3  ${Xt}
Block XdIN                   # Xd(MSUSY)
    1  1  0
    2  2  0
    3  3  ${Xb}
Block XeIN                   # Xe(MSUSY)
    1  1  0
    2  2  0
    3  3  ${Xe}
Block MSLIN                  # msl(MSUSY)
    1  ${ms}
    2  ${ms}
    3  ${ms}
Block MSEIN                  # mel(MSUSY)
    1  ${ms}
    2  ${ms}
    3  ${ms}
Block MSQIN                  # mql(MSUSY)
    1  ${ms}
    2  ${ms}
    3  ${ms}
Block MSUIN                  # mul(MSUSY)
    1  ${ms}
    2  ${ms}
    3  ${ms}
Block MSDIN                  # mdl(MSUSY)
    1  ${ms}
    2  ${ms}
    3  ${ms}
EOF
                  )

        slha_output=$(echo "$slha_input" | models/${model}/run_${model}.x --slha-input-file=- 2>/dev/null)

        block=$(echo "$slha_output" | awk -v block="MASS" "$print_slha_block_awk")
        Mh=$(echo "$block"          | awk -v keys="25" "$print_block_entry_awk" | tail -n 1)

        block=$(echo "$slha_output" | awk -v block="FlexibleSUSYUncertaintyEstimation_MASS" "$print_slha_block_awk")
        DMh=$(echo "$block"         | awk -v keys="25" "$print_block_entry_awk" | tail -n 1)

        block=$(echo "$slha_output" | awk -v block="FlexibleSUSYUncertaintyEstimation_MASS_AlphaSInput" "$print_slha_block_awk")
        DMh_as_m=$(echo "$block"    | awk -v keys="25:0" "$print_block_entry_awk" | tail -n 1)
        DMh_as_p=$(echo "$block"    | awk -v keys="25:1" "$print_block_entry_awk" | tail -n 1)

        block=$(echo "$slha_output" | awk -v block="FlexibleSUSYUncertaintyEstimation_MASS_MTopPoleInput" "$print_slha_block_awk")
        DMh_Mt_m=$(echo "$block"    | awk -v keys="25:0" "$print_block_entry_awk" | tail -n 1)
        DMh_Mt_p=$(echo "$block"    | awk -v keys="25:1" "$print_block_entry_awk" | tail -n 1)

        block=$(echo "$slha_output" | awk -v block="FlexibleSUSYUncertaintyEstimation_MASS_SUSYScale" "$print_slha_block_awk")
        DMh_Q_m=$(echo "$block"     | awk -v keys="25:0" "$print_block_entry_awk" | tail -n 1)
        DMh_Q_p=$(echo "$block"     | awk -v keys="25:1" "$print_block_entry_awk" | tail -n 1)

        [ "x$Mh" = "x" ] && Mh="-"

        printf "%16s %16s %16s %16s %16s %16s %16s %16s %16s\n" "$ms" "$Mh" "$DMh" "$DMh_as_m" "$DMh_as_p" "$DMh_Mt_m" "$DMh_Mt_p" "$DMh_Q_m" "$DMh_Q_p" >> "$output"
    done
}

for m in ${thdm_models}; do
    for Xt in 0 ${Xt_max}; do
        output_file="scale_${m}_Xt-${Xt}.dat"
        rm -f "$output_file"
        printf "# %14s %16s %16s %16s %16s %16s %16s %16s %16s\n" "ms" "Mh" "DMh" "DMh_as_m" "DMh_as_p" "DMh_Mt_m" "DMh_Mt_p" "DMh_Q_m" "DMh_Q_p" >> "$output_file"
        scan_ms "$m" "$slha_templ" "$output_file" "$Xt" ms ms ms ms
    done
done

for m in ${hgthbm_models}; do
    for Xt in 0 ${Xt_max}; do
        output_file="scale_${m}_Xt-${Xt}.dat"
        rm -f "$output_file"
        printf "# %14s %16s %16s %16s %16s %16s %16s %16s %16s\n" "ms" "Mh" "DMh" "DMh_as_m" "DMh_as_p" "DMh_Mt_m" "DMh_Mt_p" "DMh_Q_m" "DMh_Q_p" >> "$output_file"
        scan_ms "$m" "$slha_templ" "$output_file" "$Xt" "$mA" "$mA" "$mA" "$mA"
    done
done
