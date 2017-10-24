Get["models/MRSSMEFTHiggs/MRSSMEFTHiggs_librarylink.m"];
Get["model_files/MRSSMEFTHiggs/MRSSMEFTHiggs_uncertainty_estimate.m"];

invalid;
scaleFactor = 9;

LinearRange[start_, stop_, steps_] :=
    Table[start + i/steps (stop - start), {i, 0, steps}];

(* generate logarithmically spaced range [start, stop] *)
LogRange[start_, stop_, steps_] :=
    Exp /@ Range[Log[start], Log[stop], (Log[stop] - Log[start])/steps];

MakeInput[MSUSY_?NumericQ] := {
               fsSettings -> {
                   precisionGoal -> 1.*^-5,           (* FlexibleSUSY[0] *)
                   maxIterations -> 10000,            (* FlexibleSUSY[1] *)
                   solver -> 1,                       (* FlexibleSUSY[2] *)
                   calculateStandardModelMasses -> 1, (* FlexibleSUSY[3] *)
                   poleMassLoopOrder -> 3,            (* FlexibleSUSY[4] *)
                   ewsbLoopOrder -> 3,                (* FlexibleSUSY[5] *)
                   betaFunctionLoopOrder -> 3,        (* FlexibleSUSY[6] *)
                   thresholdCorrectionsLoopOrder -> 2,(* FlexibleSUSY[7] *)
                   higgs2loopCorrectionAtAs -> 1,     (* FlexibleSUSY[8] *)
                   higgs2loopCorrectionAbAs -> 1,     (* FlexibleSUSY[9] *)
                   higgs2loopCorrectionAtAt -> 1,     (* FlexibleSUSY[10] *)
                   higgs2loopCorrectionAtauAtau -> 1, (* FlexibleSUSY[11] *)
                   forceOutput -> 0,                  (* FlexibleSUSY[12] *)
                   topPoleQCDCorrections -> 1,        (* FlexibleSUSY[13] *)
                   betaZeroThreshold -> 1.*^-11,      (* FlexibleSUSY[14] *)
                   forcePositiveMasses -> 0,          (* FlexibleSUSY[16] *)
                   poleMassScale -> 0,                (* FlexibleSUSY[17] *)
                   eftPoleMassScale -> 0,             (* FlexibleSUSY[18] *)
                   eftMatchingScale -> 0,             (* FlexibleSUSY[19] *)
                   eftMatchingLoopOrderUp -> 2,       (* FlexibleSUSY[20] *)
                   eftMatchingLoopOrderDown -> 1,     (* FlexibleSUSY[21] *)
                   eftHiggsIndex -> 0,                (* FlexibleSUSY[22] *)
                   calculateBSMMasses -> 1,           (* FlexibleSUSY[23] *)
                   thresholdCorrections -> 122111221, (* FlexibleSUSY[24] *)
                   higgs3loopCorrectionRenScheme -> 0,(* FlexibleSUSY[25] *)
                   higgs3loopCorrectionAtAsAs -> 1,   (* FlexibleSUSY[26] *)
                   higgs3loopCorrectionAbAsAs -> 1,   (* FlexibleSUSY[27] *)
                   higgs3loopCorrectionAtAtAs -> 1,   (* FlexibleSUSY[28] *)
                   higgs3loopCorrectionAtAtAt -> 1,   (* FlexibleSUSY[29] *)
                   parameterOutputScale -> 0          (* MODSEL[12] *)
               },
               fsSMParameters -> {
                   alphaEmMZ -> 1/127.94,  (* SMINPUTS[1] *)
                   GF -> 1.1663787 10^-5,  (* SMINPUTS[2] *)
                   alphaSMZ -> 0.1181,     (* SMINPUTS[3] *)
                   MZ -> 91.1876,          (* SMINPUTS[4] *)
                   mbmb -> 4.18,           (* SMINPUTS[5] *)
                   Mt -> 173.34,           (* SMINPUTS[6] *)
                   Mtau -> 1.77686,        (* SMINPUTS[7] *)
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
               },
               fsModelParameters -> {
                   TanBeta -> 10,
                   MS -> MSUSY,
                   LamTDInput -> -0.5,
                   LamTUInput -> -0.5,
                   LamSDInput -> -0.5,
                   LamSUInput -> -0.5,
                   MuDInput -> -MSUSY,
                   MuUInput -> MSUSY,
                   BMuInput -> MSUSY^2,
                   mq2Input -> scaleFactor MSUSY^2 IdentityMatrix[3],
                   mu2Input -> scaleFactor MSUSY^2 IdentityMatrix[3],
                   ml2Input -> MSUSY^2 IdentityMatrix[3],
                   md2Input -> MSUSY^2 IdentityMatrix[3],
                   me2Input -> MSUSY^2 IdentityMatrix[3],
                   mS2Input -> scaleFactor MSUSY^2,
                   moc2Input -> scaleFactor MSUSY^2,
                   mT2Input -> MSUSY^2,
                   mRd2Input -> MSUSY^2,
                   mRu2Input -> MSUSY^2,
                   MDBSInput -> MSUSY,
                   MDWBTInput -> MSUSY,
                   MDGocInput -> MSUSY
               }
};

RunMRSSMBMP1[MSUSY_?NumericQ] :=
    Module[{handle, spec, obs, Mhh, DMhh},
           handle = FSMRSSMEFTHiggsOpenHandle[Sequence @@ MakeInput[MSUSY]];
           spec = FSMRSSMEFTHiggsCalculateSpectrum[handle];
           obs  = FSMRSSMEFTHiggsCalculateObservables[handle];
           FSMRSSMEFTHiggsCloseHandle[handle];
           If[spec === $Failed, Return[invalid]];
           { Mhh, DMhh } = CalcMRSSMEFTHiggsDMh[Sequence @@ MakeInput[MSUSY]];
           Join[MRSSMEFTHiggs /. spec, MRSSMEFTHiggs /. obs, { MHiggs -> Mhh , DMHiggs -> DMhh }]
          ];

RunMRSSM[MS_] :=
    Module[{spec = RunMRSSMBMP1[MS]},
           If[spec === invalid,
              Array[invalid&, {3}],
              {
                  FlexibleSUSYObservable`aMuon /. spec,
                  (Pole[M[hh]] /. spec)[[1]],
                  (DMHiggs /. spec)
              }
             ]
          ];

(* Print[{ *)
(*     N[#], Sequence @@ RunMRSSM[#] *)
(* }]& /@ LogRange[100, 10000, 5]; *)

data = ParallelMap[
    { N[#], Sequence @@ RunMRSSM[#] }&,
    LogRange[100, 10^4, 60]
];

Export["scan_MRSSMEFTHiggs_MS_amu_Mh_DMh.dat", data];
