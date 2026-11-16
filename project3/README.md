# Fire Is Red, Water Is Blue? Predicting a Pokémon's Type from Its Colors

**Group:** Lanturns, DS 4002-002
**Members:** Thieron Cook (Leader), Caroline Clippinger, Ethan Wang

## Contents of This Repository

This repository holds the data, code, and outputs for Project 3 of DS 4002. We collect the normal and shiny Pokémon HOME renders of every Pokémon form from PokéAPI, fine-tune an ImageNet-pretrained ResNet-18 to predict each form's primary type, and compare it with a color-only logistic regression baseline. Our goal is at least 30% accuracy on species held out of training, along with the change in accuracy when those same species are shown in their shiny colors, each with a 95% bootstrap confidence interval.

- `DATA/` holds the two form-level CSV files and their metadata. The sprite images and trained model weights are created when the notebook runs.
- `SCRIPTS/` holds the Jupyter notebook that collects the data, makes the exploratory plots, trains and evaluates both models, and runs the bootstrap.
- `OUTPUT/` holds the exploratory plots and the final model comparison figure.

## Section 1: Software and Platform

**Software**
- Python 3 (developed on Python 3.14.2), run in Jupyter Notebook
- Platform: Windows. The notebook uses relative paths and also runs on Mac or Linux.
- A GPU is optional. The notebook uses CUDA if it is available and the CPU otherwise.

**Python packages**

| Package | Used for |
|---|---|
| `requests` | Querying PokéAPI and downloading sprite images |
| `pandas` | Reading, filtering, and splitting the CSV files |
| `numpy` | Array math and the bootstrap |
| `Pillow` | Opening sprites and placing them on a white background |
| `scikit-learn` | k-means color extraction, GroupShuffleSplit, logistic regression baseline, accuracy |
| `torch` | Training ResNet-18 |
| `torchvision` | ResNet-18 pretrained weights and image transforms |
| `matplotlib` | Plotting |
| `seaborn` | Plot styling and the color-to-type heatmap |
| `scipy` | Imported by the notebook |

Install them with:

```bash
pip install requests pandas numpy pillow scikit-learn torch torchvision matplotlib seaborn scipy jupyter
```

## Section 2: Map of Documentation

```
project3/
├── README.md                                  # This file: orientation and reproduction steps
├── LICENSE.md                                 # MIT License, plus PokéAPI's BSD 3-Clause notice
├── DATA/
│   ├── datareadme.md                          # Metadata: summary, provenance, license, ethics,
│   │                                          #   data dictionary, and exploratory plots
│   ├── pokemon_forms_normal.csv               # 1,513 forms with types, flags, normal render URL,
│   │                                          #   and dominant colors
│   ├── pokemon_forms_shiny.csv                # The same 1,513 forms, linked to their shiny renders
│   ├── sprite_cache/                          # NOT in the repo: created when the notebook downloads
│   │                                          #   the sprite images
│   └── resnet18_pokemon_type.pth              # NOT in the repo: trained ResNet-18 weights, written
│                                              #   when the notebook trains the model
├── SCRIPTS/
│   └── collection.ipynb                       # Collects the data, makes the exploratory plots,
│                                              #   trains and evaluates both models, runs the bootstrap
└── OUTPUT/
    ├── plot1_type_distribution.png            # Forms per primary type, with the majority-class line
    ├── pokemonTypeCounts.png                  # Forms per type, split by primary and secondary slot
    ├── plot2_color_type_alignment_heatmap.png # Percent of each type's forms in each color family
    └── model_comparison_benchmark.png         # Accuracy of every model and test set against the
                                               #   30% target
```

## Section 3: Instructions for Reproducing Our Results

All steps run in one notebook, `SCRIPTS/collection.ipynb`. Run the cells from top to bottom except where noted.

### Step 1: Get the code

1. Clone this repository and open the `project3` folder:
   ```bash
   git clone https://github.com/Thieron/DS-4002-group-01.git
   cd DS-4002-group-01/project3
   ```
2. Install the software and packages listed in Section 1.
3. Start Jupyter from the `SCRIPTS/` folder and open the notebook. The notebook finds `DATA/` and `OUTPUT/` relative to the folder Jupyter starts in, so it must be started from `SCRIPTS/`.
   ```bash
   cd SCRIPTS
   jupyter notebook collection.ipynb
   ```

### Step 2: Set up the notebook

Run the first four code cells. They import the packages, set the random seed to 42, choose the GPU or CPU, set the `DATA/` and `OUTPUT/` paths, and define the k-means color extraction function.

### Step 3: Load the data

1. **Skip the data collection cell** (the one under the heading "The block below can be skipped as we have the data loaded in DATA"). The two CSV files it produces are already in `DATA/`. Run it only if you want to rebuild them from PokéAPI, which needs an internet connection and makes one request per form.
2. Run the next cells to load both CSVs, remove the `arceus-unknown` form, and run the data checks. You should see 1 Unown entry, 97 Mega Evolutions, regional counts of 20 Alolan, 20 Galarian, 16 Hisuian, and 4 Paldean, and 10 added female records.

### Step 4: Make the exploratory plots

Run the two plotting cells. They save `pokemonTypeCounts.png` and `plot2_color_type_alignment_heatmap.png` to `OUTPUT/`.

### Step 5: Preprocess and split the data

1. Run the split cell. It keeps the 18 standard types, keeps only forms whose normal and shiny images are both HOME renders (1,490 forms), and splits them 80/20 by species with GroupShuffleSplit so every form of a species stays on one side. It should print:
   - Training: 1,219 images (820 species)
   - Held-out test, normal: 271 images (205 species)
   - Held-out test, shiny: 271 images (205 species)
   - Arceus: in the training set
2. Run the next cell to set up image loading. The first time an image is needed, it is downloaded from PokéAPI's sprites repository and saved to `DATA/sprite_cache/`. Each image is placed on a white background, resized to 224 × 224, and normalized with ImageNet's means and standard deviations. Training images are also randomly flipped and rotated up to 10°.

### Step 6: Fit the color-only baseline

Run the baseline cell. It downloads every sprite, builds an 8 × 8 × 8 RGB color histogram for each, and fits a multinomial logistic regression. **This takes about 15 minutes** on the first run because of the downloads, and needs an internet connection.

### Step 7: Train ResNet-18

Run the training cell. It fine-tunes an ImageNet-pretrained ResNet-18 with an 18-class output layer for 12 epochs and saves the weights to `DATA/resnet18_pokemon_type.pth`. **This takes about 30 minutes on a CPU** and much less on a GPU. The first run also downloads the pretrained weights from torchvision.

### Step 8: Evaluate and bootstrap

1. Run the evaluation cell to score ResNet-18 on the held-out normal and shiny test sets. Arceus is not scored because its forms landed in the training set.
2. Run the bootstrap cell. It resamples the 205 held-out species with replacement 2,000 times to get 95% confidence intervals for normal accuracy and for the normal minus shiny accuracy drop.
3. Run the last cell to save `model_comparison_benchmark.png` to `OUTPUT/`.

### Step 9: Check the results

Compare your printed results and `OUTPUT/model_comparison_benchmark.png` with ours. Because training on a GPU is not fully deterministic, ResNet-18's numbers may differ slightly from ours even with the same seed.

**Our results:**

| Model | Held-out normal accuracy | Held-out shiny accuracy | Drop (normal minus shiny) |
|---|---|---|---|
| Color histogram logistic regression | 18.08% | 13.28% | 4.80% |
| ResNet-18 | 34.32% (95% CI: 28.24% to 40.60%) | 27.31% | 7.01% (95% CI: 1.86% to 12.12%) |

## References

[1] PokéAPI, "PokéAPI: The RESTful Pokémon API." [Online]. Available: https://pokeapi.co. [Accessed: Nov. 9, 2026].

[2] PokéAPI Contributors, "PokeAPI/sprites," GitHub repository. [Online]. Available: https://github.com/PokeAPI/sprites. [Accessed: Nov. 9, 2026].

[3] K. He, X. Zhang, S. Ren, and J. Sun, "Deep residual learning for image recognition," in Proc. IEEE Conf. Computer Vision and Pattern Recognition (CVPR), 2016, pp. 770–778.

[4] A. Paszke et al., "PyTorch: An imperative style, high-performance deep learning library," in Advances in Neural Information Processing Systems 32, 2019, pp. 8024–8035.

[5] F. Pedregosa et al., "Scikit-learn: Machine learning in Python," Journal of Machine Learning Research, vol. 12, pp. 2825–2830, 2011.

[6] B. Efron and R. J. Tibshirani, An Introduction to the Bootstrap. New York, NY, USA: Chapman & Hall, 1993.
