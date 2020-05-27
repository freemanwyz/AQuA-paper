# AQuA: Astrocyte Quantification and Analysis
AQuA is a tool to detect events from microscopic time-lapse imaging data of astrocytes. The main repository is https://github.com/yu-lab-vt/AQuA.

This repository contains the code for making synthetic data, running simulation and drawing figures.

It contains wrappers for Suite2P, CaImAn, CaSCaDe and GECI-quant. The scripts for GECI-quant is modified to automate the simulation.

## Getting started
Download all AQuA related data. The file to download is large (~190 GB), and most files are not used in the simulation. I may extract the necessary subset later to reduce the size of file.

1. After download, extract the `iso` file.
2. Open `./util/getWorkPath.m`, add the path containing `glia_kira` to list `topPathLst`.

## Generate simulation data
Use `./x_sim/gen_paper_unfixed.m` to generate synthetic data with *unfixed* events, which change size or position.  
Use `./x_sim/gen_paper_propagation.m` to generate synthetic data with *propagative* events.  
The events used in the synthetic data are from thresholding the delta F signal of real data.

## Run simulation
You need to download the following repositories if you want to test algorithms:
- AQuA: https://github.com/freemanwyz/AQuA-stable-v1 
- CaImAn: https://github.com/freemanwyz/CaImAn-MATLAB
- CaSCaDe: https://github.com/freemanwyz/CaSCaDe
- Suite2P: https://github.com/freemanwyz/Suite2P

The following repository might also be used:
- https://github.com/freemanwyz/OASIS_matlab

There is no need to download GECIQuant since it is already included in this repository.

After download, put all repositories (including this one) to the same folder (`./mthds/geciquant/`). The `./mthds` folder also incldue the helper functions for other methods.

To run the simulation, see `./x_sim/sim_paper.m`.

## Spatial map
For supplement figures 4 and 5, use `./x_sim/misc/compare_methods_2d.m`.  
The script will generate all the sub-figures used in these two figures (count of event with different SNR and methods).  





