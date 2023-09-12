# UrnBasedDynamicNetworkModel
[日本語](README.md) | English

## Abstruct
This is the repository for the article "Simulating Emergence of Novelties Using Agent-Based Models", which was submitted to PLOSONE.

## Set Up
### Julia
Requires a Julia environment. Refer to the official page to install.
After installation, follow the steps below to build an experimental environment.
Note that the parts enclosed with `<>` are keyboard keystrokes.

```sh
$ julia --proj
julia> <]>
(AROB2023) pkg> instantiate
(AROB2023) pkg> <delete>
```

### Python
Some analyses require Python environment.

```sh
# Install the required modules.
poetry install
```

## Experiment
### Generate the target data, the APS data.
- Download the data from https://doi.org/10.6084/m9.figshare.13308428.v1 and execute the following commands.
  - Unzip the zip file and you will find the `APS_aff_data_ISI_original` directory inside.
- As the generated data is already stored in `data/`, you can use this as it is.

```sh
julia --proj src/tasks/PreprocessingAPS.jl <path-to-APS_aff_data_ISI_original>
```

### Running the model to generate interaction history data.
#### Proposed Model
The following command is used to enter the strategy s and execute it.
(As it takes time to execute, it can be executed separately for each strategy.)
```sh
# Enter the strategy "asw" or "wsw" for <s>.
julia --proj --threads=auto src/tasks/RunModel.jl <s>
```
The generated data is stored in `results/generated_histories`.

#### Ubaldi et al. Model
```sh
julia --proj --threads=auto src/tasks/RunBaseModel.jl
```
The generated data is stored in `results/generated_histories--base`.

#### Suda et al. Model
```sh
julia --proj --threads=auto src/tasks/RunPgbkModel.jl
```
The generated data is stored in `results/generated_histories--pgbk`.


### Analysing historical data of interactions to produce various measurements.
[Running the model to generate interaction history data.](#running-the-model-to-generate-interaction-history-data) must be performed beforehand.

```sh
# For <model> enter "proposed", "base" or "pgbk".
# If not specified, the Proposed Model is used.
julia --proj --threads=auto src/tasks/AnalyzeModels.jl <model>
```
The results are stored in `results/analyzed_models/` for each model and strategy in the following format.

```CSV
rho,nu,zeta,eta,gamma,c,oc,oo,nc,no,y,r,h,g
1,1,0.1,0.1,0.978818015295141,0.4047009698275862,0.30058742657167853,0.13123359580052493,0.20784901887264093,0.3603299587551556,0.5129046442573314,4.261350121900458,0.9715045696696164,0.45763423462530417
```

### Analysing target data to produce various measurements.

```sh
julia --proj src/tasks/AnalyzeTargets.jl
```
The generated data is stored in `results/analyzed_targets`.

```CSV
rho,nu,zeta,eta,gamma,c,oc,oo,nc,no,y,r,h,g
0,0,0.0,0.0,0.9984550695169351,0.03842432619212163,0.009248843894513185,0.14085739282589677,0.019997500312460944,0.8298962629671292,0.7471551524820348,0.05822546891664884,0.989713855195076,0.21895938205559523
```

### Fitting various measurements to target data
Calculate the difference between the target data and the various measurements resulting from running the model.

The following must be done in advance.
- [Analysing historical data of interactions to produce various measurements.](#analysing-historical-data-of-interactions-to-produce-various-measurements)
- [Analysing target data to produce various measurements.](#analysing-target-data-to-produce-various-measurements)

```sh
# For <model> enter "proposed", "base" or "pgbk".
# If not specified, the Proposed Model is used.
julia --proj src/tasks/CalcDiffs.jl <model>
```

The generated data is stored in `results/distances`,`results/distances--base` or `results/distances--pgbk`.

```CSV
rho,nu,zeta,eta,aps
8,10,0.1,0.5,0.3017873533979937
```


### Analysing changes in classifications
```sh
julia --proj src/tasks/AnalyzeClassification.jl
```

The generated data is stored in `results/analyzed_classification`.


### Analysing agents' cumulative number of activities and class affiliation
[Analysing changes in classifications](#analysing-changes-in-classifications) must be performed beforehand.
```sh
julia --proj src/tasks/AnalyzeAgentActivity.jl
```

The generated data is stored in `results/triangle/aps`.


### Take the average of the various indicators for the 10 times of the Proposed Model.
Script for a diagram showing the relationship between the parameters ζ/η and the indicators G, <h>, R and Y in the proposed model.
Note that it takes a considerable amount of time to run.

#### Run the Proposed Model 10 times.
```sh
julia --proj src/tasks/RunModel_10times.jl
```
The generated data is stored in `results/generated_histories_10times`.

#### Analysing historical data to produce various measurements.
```sh
julia --proj src/tasks/AnalyzeHistory_10times.jl
```
The generated data is stored in `results/analyzed_model_10times`.

#### Produce an average of the measured values.
```sh
julia --proj src/tasks/MergeAnalyzedHistories.jl
```
The generated data is stored in `results/analyzed_model_10times/mean.csv`.


## Visualize
### Plotting various graphs.
The following four types of graphs are generated. The figure numbers correspond to the papers.
- Fig2: Bar chart showing distance to target data
- Fig3: Radar chart showing various indicators
- Fig4: Scatterplot showing the relationship between the agents that attracted attention during the interval and the birth step
- Fig5: Scatterplot showing the relationship between the step at which an agent was born and its active frequency

The following must be done in advance.
- [Running the model to generate interaction history data.](#running-the-model-to-generate-interaction-history-data)
- [Analysing historical data of interactions to produce various measurements.](#analysing-historical-data-of-interactions-to-produce-various-measurements)
- [Analysing target data to produce various measurements.](#analysing-target-data-to-produce-various-measurements)
- [Fitting various measurements to target data](#fitting-various-measurements-to-target-data)

```sh
julia --proj src/tasks/PlotGraphs.jl
```
The output diagrams are stored under `results/imgs`.


### Plot a diagram showing the relationship between the parameters ζ/η and the indicators G, <h>, R and Y of the Proposed Model.
The diagram in Fig6 is generated.
[Take the average of the various indicators for the 10 times of the Proposed Model.](#take-the-average-of-the-various-indicators-for-the-10-times-of-the-proposed-model) must be performed beforehand.

Run `params_and_novelty.ipynb` in sequence.


### Plotting the results of the classification
The following two types of graphs are generated
- Fig7: showing the number of agents belonging to each class
- Fig8: showing the probability of each class being selected

[Analysing changes in classifications](#analysing-changes-in-classifications) must be performed beforehand.
```sh
julia --proj src/tasks/PlotAnalyzedClassification.jl
```
The output diagrams are stored in `results/imgs/classification`.


### Plotting a diagram showing the relationship between the cumulative number of active agents and class
The diagram in Fig9 is generated.
[Analysing agents' cumulative number of activities and class affiliation](#analysing-agents-cumulative-number-of-activities-and-class-affiliation) must be performed beforehand.
```sh
poetry run python python/triangle.py
```
The output diagrams are stored in `results/imgs/triangle/aps`.


## Notes
Scripts not related to the experiments in the paper have been removed due to inconsistencies caused by changes in the output format when the paper was resubmitted.
Please refer to the scripts as of [v0.1.1](https://github.com/tsukuba-websci/UrnBasedDynamicNetworkModel/releases/tag/v0.1.1) if necessary.