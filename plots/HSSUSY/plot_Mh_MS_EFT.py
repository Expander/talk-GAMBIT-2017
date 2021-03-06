#!/usr/bin/env python

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as tck
import scipy.interpolate
plt.rcParams['text.usetex'] = True

directory = r'plots/HSSUSY/'

# plot Mh(MS)

outfile = directory + r'Mh_MS_TB-5_Xt-2_EFT.pdf'

try:
    data = np.genfromtxt(directory + r'Mh_MS_TB-5_Xt-2.dat')
except:
    print "Error: could not load numerical data from file"
    exit

MS          = data[:,0]
Mh0L        = data[:,1]
Mh1L        = data[:,2]
Mh2L        = data[:,3]
Mh1LEFT     = data[:,4]

plt.rc('text', usetex=True)
plt.rc('font', family='serif', weight='normal')
fig = plt.figure(figsize=(4,4))
plt.gcf().subplots_adjust(bottom=0.15, left=0.15) # room for xlabel
ax = plt.gca()
ax.set_axisbelow(True)
ax.xaxis.set_major_formatter(tck.FormatStrFormatter(r'$%d$'))
ax.yaxis.set_major_formatter(tck.FormatStrFormatter(r'$%d$'))
ax.get_yaxis().set_tick_params(which='both',direction='in')
ax.get_xaxis().set_tick_params(which='both',direction='in')
plt.rcParams['text.latex.preamble']=[r"\usepackage{amsmath}"]
plt.grid(color='0.5', linestyle=':', linewidth=0.2, dashes=(0.5,1.5))

plt.xscale('log')
plt.xlabel(r'$M_S\,/\,\mathrm{GeV}$')
plt.ylabel(r'$M_h\,/\,\mathrm{GeV}$')

# plt.plot(MS, Mh0L, 'r-' , linewidth=1.2)
plt.plot(MS, Mh1L, 'b--', linewidth=1.2, dashes=(3,2,3,2))
# plt.plot(MS, Mh2L, 'r-' , linewidth=1.2)
plt.plot(MS, Mh1LEFT, 'b:', linewidth=1.2)

leg = plt.legend([r'$\lambda^{(1L)}, \delta_{\mathrm{EFT}} = 0$',
                  r'$\lambda^{(1L)}, \delta_{\mathrm{EFT}} = 1$'],
           loc='lower right', fontsize=10, fancybox=None, framealpha=None)
leg.get_frame().set_alpha(1.0)
leg.get_frame().set_edgecolor('black')
plt.ylim([90,140])
plt.xlim([100,50000])
plt.title(r'$X_t/M_S = 2, \tan\beta = 5$')
plt.tight_layout()

plt.savefig(outfile)
print "saved plot in ", outfile
plt.close(fig)
