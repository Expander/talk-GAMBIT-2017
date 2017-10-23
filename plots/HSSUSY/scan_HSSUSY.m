Get["models/HSSUSY/HSSUSY_librarylink.m"];
Get["models/HSSUSY1L/HSSUSY1L_librarylink.m"];

(* generate logarithmically spaced range [start, stop] *)
LogRange[start_, stop_, steps_] :=
    Exp /@ Range[Log[start], Log[stop], (Log[stop] - Log[start])/steps];

settings = {
    precisionGoal -> 1.*^-5,
    maxIterations -> 1000,
    poleMassLoopOrder -> 3,
    ewsbLoopOrder -> 3,
    calculateStandardModelMasses -> 1,
    thresholdCorrectionsLoopOrder -> 2,
    thresholdCorrections -> 122111121
};

smpars = {
    alphaEmMZ -> 1/127.916, (* SMINPUTS[1] *)
    GF -> 1.166378700*^-5,  (* SMINPUTS[2] *)
    alphaSMZ -> 0.1184,     (* SMINPUTS[3] *)
    MZ -> 91.1876,          (* SMINPUTS[4] *)
    mbmb -> 4.18,           (* SMINPUTS[5] *)
    Mt -> 173.34,           (* SMINPUTS[6] *)
    Mtau -> 1.77699,        (* SMINPUTS[7] *)
    Mv3 -> 0,               (* SMINPUTS[8] *)
    MW -> 80.385,           (* SMINPUTS[9] *)
    Me -> 0.000510998902,   (* SMINPUTS[11] *)
    Mv1 -> 0,               (* SMINPUTS[12] *)
    Mm -> 0.1056583715,     (* SMINPUTS[13] *)
    Mv2 -> 0,               (* SMINPUTS[14] *)
    md2GeV -> 0.00475,      (* SMINPUTS[21] *)
    mu2GeV -> 0.0024,       (* SMINPUTS[22] *)
    ms2GeV -> 0.104,        (* SMINPUTS[23] *)
    mcmc -> 1.27,           (* SMINPUTS[24] *)
    CKMTheta12 -> 0,
    CKMTheta13 -> 0,
    CKMTheta23 -> 0,
    CKMDelta -> 0,
    PMNSTheta12 -> 0,
    PMNSTheta13 -> 0,
    PMNSTheta23 -> 0,
    PMNSDelta -> 0,
    PMNSAlpha1 -> 0,
    PMNSAlpha2 -> 0,
    alphaEm0 -> 1/137.035999074,
    Mh -> 125.09
};

CalcMh[MS_, TB_, Xtt_] :=
    Module[{handle, spec},
           handle = FSHSSUSYOpenHandle[
               fsSettings -> settings,
               fsSMParameters -> smpars,
               fsModelParameters -> {
                   TanBeta -> TB,
                   MEWSB -> 173.34,
                   MSUSY -> MS,
                   M1Input -> MS,
                   M2Input -> MS,
                   M3Input -> MS,
                   MuInput -> MS,
                   mAInput -> MS,
                   AtInput -> (Xtt + 1/TB) MS,
                   msq2 -> MS^2 IdentityMatrix[3],
                   msu2 -> MS^2 IdentityMatrix[3],
                   msd2 -> MS^2 IdentityMatrix[3],
                   msl2 -> MS^2 IdentityMatrix[3],
                   mse2 -> MS^2 IdentityMatrix[3],
                   LambdaLoopOrder -> 2,
                   TwoLoopAtAs -> 1,
                   TwoLoopAbAs -> 1,
                   TwoLoopAtAb -> 1,
                   TwoLoopAtauAtau -> 1,
                   TwoLoopAtAt -> 1
               }
           ];
           spec = FSHSSUSYCalculateSpectrum[handle];
           FSHSSUSYCloseHandle[handle];
           If[spec === $Failed, $Failed,
              Pole[M[hh]] /. (HSSUSY /. spec)]
          ];

CalcMh1L[MS_, TB_, Xtt_, loops_, deltaEFT_] :=
    Module[{handle, spec},
           handle = FSHSSUSY1LOpenHandle[
               fsSettings -> settings,
               fsSMParameters -> smpars,
               fsModelParameters -> {
                   TanBeta -> TB,
                   MEWSB -> 173.34,
                   MSUSY -> MS,
                   (* M1Input -> MS, *)
                   (* M2Input -> MS, *)
                   (* M3Input -> MS, *)
                   MuInput -> MS,
                   (* mAInput -> MS, *)
                   AtInput -> (Xtt + 1/TB) MS,
                   (* msq2 -> MS^2 IdentityMatrix[3], *)
                   (* msu2 -> MS^2 IdentityMatrix[3], *)
                   (* msd2 -> MS^2 IdentityMatrix[3], *)
                   (* msl2 -> MS^2 IdentityMatrix[3], *)
                   (* mse2 -> MS^2 IdentityMatrix[3], *)
                   LambdaLoopOrder -> loops,
                   (* TwoLoopAtAs -> 1, *)
                   (* TwoLoopAbAs -> 1, *)
                   (* TwoLoopAtAb -> 1, *)
                   (* TwoLoopAtauAtau -> 1, *)
                   (* TwoLoopAtAt -> 1, *)
                   DeltaEFT -> deltaEFT
               }
           ];
           spec = FSHSSUSY1LCalculateSpectrum[handle];
           FSHSSUSY1LCloseHandle[handle];
           If[spec === $Failed, $Failed,
              Pole[M[hh]] /. (HSSUSY1L /. spec)]
          ];

LaunchKernels[];
DistributeDefinitions[CalcMh];

Xtt = 0;
TB  = 5;

data = ParallelMap[
    { N[#],
      CalcMh1L[#, TB, Xtt, 0, 0],
      CalcMh1L[#, TB, Xtt, 1, 0],
      CalcMh[#, TB, Xtt],
      CalcMh1L[#, TB, Xtt, 1, 1]
    }&,
    LogRange[100, 5 10^4, 100]
];

Export["Mh_MS_TB-" <> ToString[TB] <> "_Xt-0.dat", data];

MS = 5000;

data = ParallelMap[
    { N[#],
      CalcMh1L[MS, TB, #, 0, 0],
      CalcMh1L[MS, TB, #, 1, 0],
      CalcMh[MS, TB, #],
      CalcMh1L[MS, TB, #, 1, 1]
    }&,
    Range[-3.5, 3.5, 0.1]
];

Export["Mh_Xt_TB-" <> ToString[TB] <> "_MS-" <> ToString[MS] <> ".dat", data];
