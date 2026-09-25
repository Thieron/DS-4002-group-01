# Constructing a Pokémon World: Analyzing Language Across Types and Generations

**Group:** Lanturns (DS 4002-002, Group 1)  
**Members:** Caroline Clippinger (Leader), Ethan Wang, Thieron Cook

## Repository Contents

This folder contains the data, code, and outputs for Project 1. We collected Pokédex entries for all 1,025 Pokémon species from PokéAPI, cleaned and lemmatized the text, computed TF-IDF word profiles for each elemental type and generation, and ran hierarchical clustering to see which types and generations share descriptive language. Our main analysis uses the top 150 words; we repeat it with 50, 100, and 200 words as a sensitivity check.

**Goal:** We will analyze Pokémon descriptions to identify patterns in descriptive vocabulary across Pokémon types and generations to determine which types and generations cluster together and which words characterize these clusters; success will be contingent on the production of well-separated clusters (high silhouette scores) with semantically cohesive and interpretable word patterns.

**Research Question:** How do the descriptive characteristics of Pokémon differ across types and generations, and which types or generations exhibit similar descriptive language?

## Section 1: Software and Platform

- **Platform:** Windows
- **Python 3** (Jupyter Notebook) with `requests`, `pandas`, `numpy`, `matplotlib`, `scipy`, `scikit-learn`
- **R** (RStudio) with `here`, `tidyverse`, `tidytext`, `textdata`, `udpipe`

**TO ADD: Remove `textdata` from this list (and from Setup step 3) if Caroline removes `library(textdata)` from the R script, since it is not used.**

## Section 2: Documentation Map

```
project1/
├── README.md                                   # This file
├── LICENSE.md                                  # MIT license + PokéAPI BSD 3-Clause notice
├── requirements.txt                            # Python dependencies
├── DS4002_Group1_Project1_MI1.pdf              # Project goal and motivation
├── DS4002_Group1_Project1_MI2.pdf              # Data establishment and analysis plan
├── DATA/
│   ├── README.md                               # Data summary, provenance, license, ethics, dictionary
│   ├── pokedex.csv                             # Raw data pulled from PokéAPI (1,025 rows)
│   ├── pokemon_type-word_matrix.csv            # 18 types x 150 words (TF-IDF), main analysis
│   ├── pokemon_gen-word_matrix.csv             # 9 generations x 150 words (TF-IDF), main analysis
│   ├── pokemon_type-word_matrix{50,100,200}.csv  # Sensitivity check: types at 50, 100, 200 words
│   └── pokemon_gen-word_matrix{50,100,200}.csv   # Sensitivity check: generations at 50, 100, 200 words
├── SCRIPTS/
│   ├── Analysis.ipynb                          # Data collection, EDA plots, HCA, and sensitivity comparison
│   ├── Analysis_with_AI_Comments.ipynb         # Annotated copy of the 150-word analysis
│   ├── pokemon_data_cleaning_for_hca.Rmd       # Text cleaning, lemmatization, TF-IDF, matrices
│   └── pokemon_data_cleaning_for_hca.md        # Knitted output of the .Rmd
└── OUTPUT/
    ├── pokemonTypeCounts.png                   # Pokémon per type, primary vs. secondary slot
    ├── pokemonEntryLength.png                  # Entry length by generation
    ├── tf-idf_informativeness_decay_curve.png  # Justification for the 150-word cutoff
    ├── pokémon_type_average.png                # Type dendrograms at each vocabulary size
    ├── pokémon_generation_average.png          # Generation dendrograms at each vocabulary size
    ├── silhouette_analysis.png                 # Per-member silhouette scores at the chosen k
    └── pokemon_ARI.png                         # Cluster agreement (ARI) across vocabulary sizes
```

**TO ADD: Rename `LICENSE` to `LICENSE.md` to match the MI3 rubric.**

**TO ADD: Create `DATA/README.md` (port the data establishment section from MI2 and add entries for the matrix CSVs).**

**TO ADD: Decide whether to keep both notebooks. `Analysis_with_AI_Comments.ipynb` only covers the 150-word runs and has no ARI comparison, so it is out of date. Either move its comments into `Analysis.ipynb` and delete it, or update this map to explain the difference.**

## Section 3: Instructions for Reproducing Results

There are three steps: Python (EDA), then R (cleaning and TF-IDF), then Python again (clustering).

**Setup**

1. Clone the repository: `git clone https://github.com/Thieron/DS-4002-group-01.git`
2. Install the Python packages from the `project1` folder: `pip install -r requirements.txt`
3. In R, install the packages: `install.packages(c("here", "tidyverse", "tidytext", "textdata", "udpipe"))`

**Step 1: Exploratory analysis (Python)**

4. Open `SCRIPTS/Analysis.ipynb` in Jupyter. Run the cells from the top through the **Exploratory plots** section. This loads `DATA/pokedex.csv` and saves the two exploratory plots to `OUTPUT/`.
   - The data collection cell is commented out because `pokedex.csv` is already provided. Uncomment it only to pull fresh data from PokéAPI (about 5 minutes). Entries may differ slightly if the API has been updated since September 10, 2026.

**Step 2: Text cleaning and TF-IDF (R)**

5. Open `SCRIPTS/pokemon_data_cleaning_for_hca.Rmd` in RStudio and click **Knit**. Open it from inside the cloned repository so `here()` can locate the project root.
   - On first run, the script downloads the English udpipe model (about 16 MB) into `SCRIPTS/`.
   - This fills in typing for the 37 form-varying Pokémon, writes all eight word matrices to `DATA/` (overwriting the provided copies), and saves the informativeness decay curve to `OUTPUT/`.

**Step 3: Hierarchical clustering (Python)**

6. Return to `Analysis.ipynb` and run the **Cleaned Data** and **Analysis** sections. This loads all eight matrices, runs average-linkage HCA on cosine distance, selects the number of clusters by mean silhouette score, and prints each cluster's members and top words. It saves the dendrograms, silhouette plot, and ARI comparison to `OUTPUT/`.

## References

[1] PokéAPI, "PokéAPI: The RESTful Pokémon API." [Online]. Available: https://pokeapi.co. [Accessed: Sep. 17, 2026].

[2] PokéAPI Contributors, "LICENSE.md," PokeAPI/pokeapi GitHub repository. [Online]. Available: https://github.com/PokeAPI/pokeapi/blob/master/LICENSE.md. [Accessed: Sep. 17, 2026].

[3] J. Wijffels, BNOSAC, M. Straka, and J. Straková, "udpipe: Tokenization, Parts of Speech Tagging, Lemmatization and Dependency Parsing with the 'UDPipe' 'NLP' Toolkit," CRAN, ver. 0.8.16, 2026. [Online]. Available: https://cran.r-project.org/web/packages/udpipe/index.html. [Accessed: Sep. 16, 2026].

[4] J. Silge et al., "tidytext: Text Mining using 'dplyr', 'ggplot2', and Other Tidy Tools," CRAN, ver. 0.4.3, 2025. [Online]. Available: https://cran.r-project.org/web/packages/tidytext/index.html. [Accessed: Sep. 16, 2026].

[5] H. Wickham and RStudio, "tidyverse: Easily Install and Load the 'Tidyverse'," CRAN, ver. 2.0.0, 2023. [Online]. Available: https://cran.r-project.org/web/packages/tidyverse/index.html. [Accessed: Sep. 16, 2026].

[6] SciPy Developers, "Hierarchical clustering (scipy.cluster.hierarchy)," SciPy Documentation, SciPy v1.18.0. [Online]. Available: https://docs.scipy.org/doc/scipy/reference/cluster.hierarchy.html. [Accessed: Sep. 16, 2026].

[7] F. Pedregosa et al., "Scikit-learn: Machine Learning in Python," *Journal of Machine Learning Research*, vol. 12, pp. 2825–2830, 2011.
