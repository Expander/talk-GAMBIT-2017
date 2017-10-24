# http://www.gnu.org/software/make/manual/make.html

OUTFILENAME := talk.pdf
PLOTS       := \
		plots/HSSUSY/Mh_Xt_TB-5_MS-5000.pdf \
		plots/HSSUSY/Mh_MS_TB-5_Xt-0.pdf \
		plots/HSSUSY/Mh_MS_TB-5_Xt-2_EFT.pdf \
		plots/HSSUSY/Mh_MS_TB-5_Xt-2_EFT_uncertainty.pdf \
		plots/MRSSM/MRSSMEFTHiggs_MS_amu_Mh.pdf

TEXDIRS     := $(PLOTSDIR)
BIBTEX      := bibtex

.PHONY: all clean

all: $(OUTFILENAME)

plots/HSSUSY/Mh_Xt_TB-5_MS-5000.pdf: plots/HSSUSY/plot_Mh_Xt.py plots/HSSUSY/*.dat
	$<

plots/HSSUSY/Mh_MS_TB-5_Xt-0.pdf: plots/HSSUSY/plot_Mh_MS.py plots/HSSUSY/*.dat
	$<

plots/HSSUSY/Mh_MS_TB-5_Xt-2_EFT.pdf: plots/HSSUSY/plot_Mh_MS_EFT.py plots/HSSUSY/*.dat
	$<

plots/HSSUSY/Mh_MS_TB-5_Xt-2_EFT_uncertainty.pdf: plots/HSSUSY/plot_Mh_MS_EFT_uncertainty.py plots/HSSUSY/*.dat
	$<

plots/MRSSM/MRSSMEFTHiggs_MS_amu_Mh.pdf: plots/MRSSM/plot_MS.py plots/MRSSM/*.dat
	$<

%.pdf: %.tex $(PLOTS)
	pdflatex $<
	cd Feynman && ./makeall.sh
	pdflatex $<

clean:
	rm -f *~ *.bak *.aux *.log *.toc *.bbl *.blg *.nav *.out *.snm *.backup
	rm -f plots/*.aux plots/*.log
	rm -f $(PLOTS)

distclean: clean
	rm -f $(OUTFILENAME)
