# sm3
Simple Snakemake example

This repo is intended as an easy-to-use starting point for making a quick
reproducible bioinformatics analysis using Snakemake.


## Usage
1. Clone the repo to create your analysis folder
```
git clone git@github.com:ctmrbio/sm3 my_analysis
```
2. Modify the Snakefile according to your needs. Add rules to produce output
   files and add desired final output files to the `all` rule.
4. Define the environment required to run the rules in `workflows/envs/conda.yaml`.
3. Create an `input` directory and put your input files there (a symlink usually works fine).


## Running
Run the workflow locally:
```
snakemake --use-conda --jobs 10
```

Run the workflow using Slurm on Gandalf:
```
snakemake --use-conda --profile profiles/ctmr_gandalf
```


## Example
```
git clone git@github.com:ctmrbio/sm3
cd sm3
ln -s example_input input
snakemake --use-conda --jobs 1
```
