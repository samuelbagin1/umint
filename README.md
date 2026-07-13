# UMINT — Artificial Intelligence

MATLAB coursework for **Umelá inteligencia (Artificial Intelligence)**, covering genetic algorithms, neural networks, and fuzzy-logic control. The repository is organised as three independent blocks:

| Block | Topic | Main deliverable |
| --- | --- | --- |
| [01](ulohy/blok01) | Genetic algorithms | Optimisation, travelling-salesperson, and constrained investment problems |
| [02](ulohy/blok02) | Neural networks | MLP classification/regression and CNN digit recognition |
| [03](ulohy/blok03) | Fuzzy logic | Adaptive traffic-light control for a seven-lane intersection |

The code targets MATLAB and its Neural Network / Deep Learning and Fuzzy Logic toolboxes. Individual assignments and reports are in Slovak; this README provides a technical English overview.

## Repository layout

```text
prednasky/                         Course lecture material
ulohy/
├── blok01/                        Genetic-algorithm assignments and report
│   ├── main1.m ... main4.m         Entry scripts for tasks 1–4
│   ├── dokumentacia.docx           Submitted results and discussion
│   └── GA_tbx_manual4.pdf          Genetic-algorithm toolbox manual
├── blok02/                        Neural-network assignments and report
│   ├── NS/                         Submitted task scripts and report
│   ├── programy_ulohy56/           Tasks 5a, 5b, and 6 scripts
│   ├── programy_ulohy78/           Tasks 7 and 8 scripts
│   └── UI_25_ulohy5678.pdf         Assignment specification
├── blok03/
│   ├── UI25_uloha_9/               Intersection simulator and fuzzy controller
│   └── UI_25_uloha9.pdf            Assignment specification
└── genetic/                        Reusable GA operator library (also copied in blok01)
```

The `.mat` datasets required by Block 02 are referenced by the scripts but are not included in this repository. Obtain them from the course distribution before running those tasks.

## Requirements

- MATLAB.
- For Block 01: the GA functions in `ulohy/blok01` or `ulohy/genetic` must be on the MATLAB path.
- For Block 02: Deep Learning Toolbox / Neural Network Toolbox. Task 8 additionally uses CNN training support and benefits from a GPU, but can be run on CPU after adjusting the training options if necessary.
- For Block 03: Fuzzy Logic Toolbox. `viz = 1` also requires Computer Vision Toolbox because the simulator draws labels, shapes, and cars over `crossroad.jpg`.

Open MATLAB in the directory of the block you want to run, or add that directory to the path. The scripts load files by name, so their working directory matters.

## Block 01 — Genetic algorithms

Sources: [assignment code](ulohy/blok01), [GA toolbox manual](ulohy/blok01/GA_tbx_manual4.pdf), and [submitted report](ulohy/blok01/dokumentacia.docx).

This block combines direct local search with a real-valued genetic-algorithm toolbox. The toolbox is **minimising**: a lower fitness/objective value is preferred. Its reusable operators include population generation (`genrpop`), elite/diversity/roulette selection (`selbest`, `seldiv`, `selsus`), crossover (`crossov`, `around`, `swappart`), mutation (`mutx`, `muta`, `mutm`, `swapgen`, `invord`), and duplicate removal (`change`). The operator sources are also available in [ulohy/genetic](ulohy/genetic).

### Task 1 — Local search on a shifted Schwefel function

Entry scripts: [main1.m](ulohy/blok01/main1.m) and [main1b.m](ulohy/blok01/main1b.m). Objective: [testfn3b.m](ulohy/blok01/testfn3b.m).

`main1.m` performs a one-dimensional hill-climb/minimisation. It samples a random initial point in `[-800, 800]`, evaluates the current point and neighbours at a step of 10, then moves to the best available neighbour. Reaching a local minimum triggers a restart; after three stagnation events, the best value across restarts is reported. The plot marks the initial point, search trajectory, local minima, and best discovered minimum.

`main1b.m` extends the same idea to two dimensions. It evaluates four axis-aligned neighbours (left, right, down, up), keeps moves inside the search square, and restarts after a local minimum. The report records approximately 80% success over five one-dimensional runs and 60% for the limited two-dimensional search; the intentionally small restart budget keeps the visual search short rather than exhaustive.

### Task 2 — Ten-dimensional GA minimisation

Entry script: [main2.m](ulohy/blok01/main2.m).

The program minimises the shifted Schwefel objective in 10 dimensions. Each of 10 runs uses a population of 100 chains for 500 generations, with values constrained to `[-800, 800]`. Every generation:

1. evaluates the population with `testfn3b`,
2. preserves two elite solutions,
3. selects the remaining parents with stochastic-universal-sampling/roulette selection (`selsus`),
4. applies two-point crossover (`crossov`), and
5. applies ordinary mutation (`mutx`) at a 10% rate.

The script saves a convergence plot and reports the best run. The submitted report records a best fitness of `-4650.46` near the optimum, about 95% success with this configuration, and convergence commonly within 50–80 generations.

### Task 3 — Travelling salesperson problem

Entry script: [main3.m](ulohy/blok01/main3.m).

Twenty fixed city coordinates are encoded directly in the script. A chromosome is a permutation whose first and last cities are fixed at 1 and 20; only the 18-city middle section evolves. Fitness is the sum of Euclidean lengths of consecutive route segments (the code does not add a final return edge to city 1).

For each of 10 runs, the GA keeps two elites, selects parents with `selsus`, and applies permutation-safe operators to the mutable route segment: `swappart`, `invord`, and `swapgen`. It runs for 1,000 generations with a population of 50 and mutation rate 0.3, then plots both the convergence histories and the best route. The report records a route of length `369.24` and an approximately 90% success rate, with good routes typically appearing around generation 200.

### Task 4 — Constrained investment allocation

Entry script: [main4.m](ulohy/blok01/main4.m).

The chromosome contains five non-negative allocations: ordinary shares (4%), preferred shares (7%), corporate bonds (11%), government bonds (6%), and bank savings (5%). The objective maximises return by minimising its negative. The solution must satisfy a €10M total budget, a €2.5M shares cap, savings no greater than government bonds, and the portfolio-balance inequality defined in the script.

The program compares three penalty strategies for infeasible candidates:

- **Death penalty**: any violation receives a very large penalty.
- **Step penalty**: a fixed charge per violated constraint.
- **Proportional penalty**: a charge scaled by the amount of each violation.

Each run uses 100 candidates, 200 generations, elite and diversity-preserving selection, two-point-style crossover (`around`), several mutation/shuffle steps, and duplicate elimination. The report notes that proportional penalties produced the most stable fitness progression and the best observed success rate (about 40%), while the other two approaches were around 30%.

## Block 02 — Neural networks

Sources: [assignment PDF](ulohy/blok02/UI_25_ulohy5678.pdf), [submitted report](ulohy/blok02/NS/Samuel%20Bagin%20dokumentacia.docx), submitted scripts in [NS](ulohy/blok02/NS), and task scripts in [programy_ulohy56](ulohy/blok02/programy_ulohy56) / [programy_ulohy78](ulohy/blok02/programy_ulohy78).

The assignment covers five neural-network problems: two introductory MLP tasks, medical-data classification, MNIST-style digit classification with an MLP, and a CNN comparison. Results below are the figures stated in the submitted report; neural-network runs are stochastic, so a rerun can differ.

| Task | Script(s) | Model and data | Reported result |
| --- | --- | --- | --- |
| 5a | [uloha5a.m](ulohy/blok02/programy_ulohy56/uloha5a.m) | `patternnet`, 3D points in five classes | 12 hidden neurons; over 98% accuracy |
| 5b | [uloha5b.m](ulohy/blok02/programy_ulohy56/uloha5b.m) | `fitnet` nonlinear regression | 25 hidden neurons; MSE below `1e-4` |
| 6 | [main6.m](ulohy/blok02/NS/main6.m) | MLP classification of CTG records | 35 hidden neurons; 92.3% mean test accuracy, 96.2% best run |
| 7 | [main7.m](ulohy/blok02/NS/main7.m) | MLP classification of handwritten digits | 100 hidden neurons; 95.5% mean, 98.4% best run |
| 8 | [main8.m](ulohy/blok02/NS/main8.m) | CNN classification of handwritten digits | 99.7% test accuracy; about 99.5% across five runs |

### Task 5a — Five-class 3D point classifier

The code loads `databody.mat`, combines five groups of 50 `(x, y, z)` points, and creates a five-row one-hot target matrix. A `patternnet(12)` classifier uses a random 80/20 train/test split, a target goal of `1e-5`, and at most 100 epochs. It visualises the source point clouds, network structure, and confusion matrix, then predicts classes for five new points. This directly addresses the assignment requirement to find a compact hidden layer while retaining near-perfect classification.

### Task 5b — Nonlinear function approximation

The regression script loads `datafun.mat` and creates `fitnet(25)`, an MLP with one input and one output. It uses the provided `indx_train` and `indx_test` arrays through `divideind`, rather than relying on a fresh random split. After training it evaluates the function on all samples and separately reports SSE, MSE, and the maximum absolute deviation for training and test subsets. The final plot contrasts measured training points, measured test points, and the network curve. The report observes underfitting with five neurons and overfitting with 30 neurons.

### Task 6 — CTG medical-data classification

`main6.m` loads `CTGdata.mat`: `NDATA` contains 25 features from 2,126 cardiotocography records and `typ_ochorenia` encodes normal, suspicious, and pathological classes. It converts the labels to one-hot targets and trains `patternnet(35)` five times. Each run uses a 60/40 random train/test split, up to 100 epochs, target `1e-5`, and no separate validation subset. It calculates training, test, and overall accuracy from the winning output neuron, draws a test confusion matrix per run, retains the highest-test-accuracy network, and evaluates representative records.

### Task 7 — MLP digit recognition

`main7.m` operates on 28 × 28 flattened digit images (`XDataall`) with one-hot labels (`YDataall`). The 784 input values are supplied to `patternnet(100)`. Five random runs use a 60/20/20 train/validation/test split, a goal of `1e-6`, a 100-epoch limit, and early stopping after 10 validation failures. The script prints fold-level and mean accuracy, plots confusion matrices for each test subset, keeps the best model, and asks it to identify one supplied example of every digit 0–9.

### Task 8 — CNN digit recognition and comparison

`main8.m` reshapes the same 784-element vectors to `28 × 28 × 1` images, derives categorical labels, fixes the random seed, and splits data 60/40 for training/test. Its CNN consists of:

```text
image input → 5×5 convolution (6 filters) → batch norm → ReLU → 2×2 max pool
            → 5×5 convolution (12 filters) → batch norm → ReLU
            → fully connected (32) → dropout (0.5) → fully connected (10)
            → softmax → classification
```

Stochastic gradient descent with momentum (`sgdm`) trains for up to 20 epochs at an initial learning rate of `1e-2`, with mini-batches of 256 and validation patience of five checks. The script reports train/test CNN accuracy, shows train and test confusion charts, repeats random hold-out evaluation five times, and trains a 100-neuron MLP baseline for comparison. The second max-pooling layer remains commented out; the submitted report says the one-pooling configuration performed markedly better.

## Block 03 — Fuzzy traffic-light control

Sources: [assignment PDF](ulohy/blok03/UI_25_uloha9.pdf), [run_krizovatka.m](ulohy/blok03/UI25_uloha_9/run_krizovatka.m), [init_krizovatka.m](ulohy/blok03/UI25_uloha_9/init_krizovatka.m), [crossroad_solver.m](ulohy/blok03/UI25_uloha_9/crossroad_solver.m), and the submitted Mamdani controller [bagin.fis](ulohy/blok03/UI25_uloha_9/bagin.fis).

### Goal

The simulator models the intersection between FEI and ZOO with seven incoming lanes: A1–A3, B1–B2, and C1–C2. It cycles through three non-conflicting green-light configurations:

1. `A1, A2, A3`
2. `B1, B2, C2`
3. `B2, C1, C2`

The task is to minimise the queue of waiting cars and improve throughput by comparing fixed green durations against fuzzy control. The assignment asks that fuzzy control be tested in traffic modes 3–6, including the combined-peak scenario (mode 6).

### Running the simulation

In MATLAB, change to `ulohy/blok03/UI25_uloha_9` and run:

```matlab
run_krizovatka
```

Configure these variables at the top of [run_krizovatka.m](ulohy/blok03/UI25_uloha_9/run_krizovatka.m):

| Variable | Meaning |
| --- | --- |
| `rezim` | Traffic scenario: 1 low traffic, 2 denser traffic, 3 peak from C, 4 peak from B, 5 peak from A, 6 combined peak |
| `fuzzy_volba` | `0` disables fuzzy control; `1` enables it |
| `fuzzy_meno` | Name of the `.fis` controller without its extension, e.g. `'bagin'` |
| `vlastne_intervaly` | `1` enables the fixed interval vector when fuzzy control is disabled |
| `intervaly` | Fixed green durations for configurations A, B, C, e.g. `[10 10 10]` |
| `viz` | `1` displays the animated intersection; `0` runs without the animation |

For a fixed-duration baseline, set `fuzzy_volba = 0`, `vlastne_intervaly = 1`, and use values generally between 8 and 15 steps. For the fuzzy run, set `fuzzy_volba = 1` and `vlastne_intervaly = 0`.

### Simulation flow

`init_krizovatka` loads the initial queues and arrivals for the selected scenario from `scenarios.mat`, creates seven lane counters, and runs 150 simulation steps (500 in the combined-peak mode). On each step it:

1. calls `crossroad_solver` to add arrivals and release vehicles from green lanes;
2. advances or switches the active light configuration when its green duration expires;
3. determines the next duration from either `intervaly` or the fuzzy inference system;
4. saves vehicle and light states; and
5. prints the final queue and maximum total queue, then plots each lane’s queue/light history and the total queue over time.

The solver models driver reaction time before a queued vehicle can depart. With scenario maps enabled (the default), precomputed arrival data determine incoming traffic; without maps, arrivals are randomised from the intensity and timing parameters. When `viz = 1`, it overlays light states, lane labels, car rectangles, queue counts, and simulation step on `crossroad.jpg`.

### Submitted fuzzy controller

`bagin.fis` is a Mamdani system with min/max inference and centroid defuzzification. It uses two inputs, both in the range 0–40:

- `green_cars`: total cars presently served by the active green configuration;
- `red_cars`: total cars waiting at red lights.

Each input has triangular **low**, **medium**, and **high** membership functions. The output `green_time` ranges from 8 to 50 steps and has triangular **short**, **medium**, and **long** membership functions. Its nine rules cover every combination of the two inputs. In practical terms, a high number of cars on the active green lanes produces a long extension; a low green queue with medium/high red demand produces a short interval so the cycle can advance. Medium green demand keeps a medium duration. This makes the current phase responsive to demand while ensuring the red side is not ignored.

The controller inputs are computed in `init_krizovatka` as:

```matlab
cars_green = sum(lights .* cars);
cars_red = sum(cars) - cars_green;
green_duration = evalfis(..., [cars_green, cars_red]);
```

The implementation supports both the older and newer MATLAB `evalfis` argument order through a `try`/`catch` fallback. A duration below one step is clamped to one, preventing an invalid cycle.

### Evaluation criteria

The assignment’s mode-6 target for fuzzy control is:

- no more than 10 cars per lane, except A2 which may reach 15;
- a maximum total queue below 40 cars; and
- fewer than 20 cars remaining at the end of the scenario.

These are target criteria from the task specification, not measured results claimed by this README. To compare controllers fairly, run the same traffic mode first with fixed intervals and then with `bagin.fis`, and compare the printed final/max queue figures and the total-queue plot.

## Attribution

The genetic-algorithm toolbox is attributed in the accompanying manual to **Ivan Sekaj**. The Block 03 simulator files credit **Jaromír Škirkanič and Adrián Falb**. Student task implementations and documentation are preserved in their original folders.
