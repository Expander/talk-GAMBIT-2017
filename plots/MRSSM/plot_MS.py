#!/usr/bin/env python

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as tck
import matplotlib.patches as patches
import scipy.interpolate
plt.rcParams['text.usetex'] = True

directory = r'plots/MRSSM/'

# plot Mh(MS)

outfile = directory + r'MRSSMEFTHiggs_MS_amu_Mh_MW_MG.pdf'

try:
    data = np.genfromtxt(directory + r'scan_MRSSMEFTHiggs_MS_amu_Mh_MW_MG.dat')
except:
    print "Error: could not load numerical data from file"
    exit

MS          = data[:,0]
amu         = data[:,1] * 10**10
Mh          = data[:,2]
MW          = data[:,3]
MG          = data[:,4]

plt.rc('text', usetex=True)
plt.rc('font', family='serif', weight='normal')
fig = plt.figure(figsize=(4.5,4))
plt.gcf().subplots_adjust(bottom=0.15, left=0.15) # room for xlabel
ax = plt.gca()
ax.set_axisbelow(True)
# ax.xaxis.set_major_formatter(tck.FormatStrFormatter(r'$%d$'))
# ax.yaxis.set_major_formatter(tck.FormatStrFormatter(r'$%d$'))
ax.get_yaxis().set_tick_params(which='both',direction='in',colors='r')
ax.get_xaxis().set_tick_params(which='both',direction='in')
plt.rcParams['text.latex.preamble']=[r"\usepackage{amsmath}"]
# plt.grid(color='0.5', linestyle=':', linewidth=0.2, dashes=(0.5,1.5))

plt.xscale('log')
plt.xlabel(r'$M_S\,/\,\mathrm{GeV}$')
plt.ylabel(r'$M_h\,/\,\mathrm{GeV}$',color='r')

plt.plot(MS, Mh, 'r-' , linewidth=1.2)
# plt.plot(MS, MW, 'b--', linewidth=1.2)
# plt.plot(MS, MG, 'b:' , linewidth=1.2)

# leg = plt.legend([r'$M_h$'
#                   # r'$M_W$'
#                   # r'$M_{\tilde{g}}$'
#                  ],
#            loc='center right', fontsize=10, fancybox=None, framealpha=None)
# leg.get_frame().set_alpha(1.0)
# leg.get_frame().set_edgecolor('black')
plt.ylim([80,130])
plt.title(r'$\lambda_u = \lambda_t = \Lambda_u = \Lambda_d = -0.5, \tan\beta = 10$')

Mhexp = 125.09
sigma = 0.32

ax.add_patch(
    patches.Rectangle(
        (ax.get_xlim()[0], Mhexp - sigma)  , # (x,y)
        ax.get_xlim()[1] - ax.get_xlim()[0], # width
        2*sigma                            , # height
        color='orange', alpha=0.5, zorder=-1
    )
)

plt.text(ax.get_xlim()[0] + 1500, Mhexp + sigma + 0.4, r"ATLAS/CMS $\pm1\sigma$", fontsize=8)

### g-2 ###

ax2 = ax.twinx()
ax2.plot(MS, amu, 'b--', linewidth=1.2)
ax2.set_ylabel(r'$(g-2)_\mu \times 10^{10}$', color='b')
ax2.tick_params('y', colors='b',direction='in')

plt.xlim([100,10000])

plt.tight_layout()
plt.savefig(outfile)
print "saved plot in ", outfile
plt.close(fig)
