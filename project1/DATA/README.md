# Data Summary
The `pokedex.csv` dataset contains 1,025 rows, one per Pokémon species, covering Pokédex IDs 1 to 1025 (Generations I through IX) with eight columns. The central feature is pokedex_entry, an English text description for each Pokémon, averaging 20.8 words (median 20, range 10 to 41) across roughly 21,900 total words and 4,241 unique word forms. Supporting features include: introduction generation, primary and secondary elemental type, species classification (genus), and assigned body color. Because our analysis aggregates text to the type and generation level, two counts are structurally important: the data covers all 18 elemental types and all 9 generations, and of the 988 Pokémon with complete typing, 486 are single-typed, and 502 carry a secondary type. The data comes from PokéAPI [1], a free, open API that serves canonical Pokémon game data, where the descriptive text is returned in the flavor_text_entries field of the pokemon-species endpoint. The CSV used for this analysis is stored in our project GitHub repository at `/project1/DATA/pokedex.csv`.
# Provenance
The Pokédex entries come from in-game text written by GAME FREAK and published by Nintendo/The Pokémon Company across nine generations of Pokémon games (1996 to present). The PokéAPI project, an all-volunteer open-source effort, transcribed and structured that text into a database and serves it through a free public API. Our group retrieved the data on September 10, 2026 using a Python script, preserved in `/project1/SCRIPTS/Analysis.ipynb`, which requested all 1,025 species from the pokemon-species endpoint, pulled elemental typing from the pokemon endpoint, selected the first English-language flavor text and genus for each species, and wrote the results to `/project1/DATA/pokedex.csv` using the pandas package. 
# License 
PokéAPI is released under the BSD 3-Clause license [2], which permits use, modification, and redistribution of its data. The license requires that we reproduce the copyright notice and disclaimer in our repository, and prohibits using the PokéAPI name or the names of its contributors to endorse or promote our work without written permission. 
# Data Dictionary
## `pokedex.csv`
| Feature | Type | Description | Values / Range | Missing | Uncertainty |
|:---|:---|:---|:---|:---|:---|
| id | Integer | Pokédex number; unique row identifier | 1 to 1025 | 0 | None. No duplicates. |
| name | String | Species name, lowercase | 1,025 unique | 0 | None. |
| genus | String | Species classification shown on the Pokédex screen (e.g. Seed Pokémon) | 715 unique | 0 | Not unique. Evolutionary families often share a genus, so it is not an identifier. |
| type_1 | String | Primary elemental type (slot 1) | 18 categories | 37 | Blank for species with form-dependent typing. Slot order is a game convention rather than a ranking, so type_1 is not more the Pokémon’s type than type_2. |
| type_2 | String | Secondary elemental type (slot 2) | 18 categories | 523 | Of the 523 blanks, 486 are true single-type Pokémon and 37 are the unknown typing cases above. Blank is therefore meaningful for most rows and must not be imputed. |
| color | String | PokéAPI’s assigned primary body color | 10 categories; blue most common (170) | 0 | Assigned by PokéAPI rather than by the games. A single subjective label for multicolored designs. |
| generation | String | Game generation in which the species was introduced | generation-i to generation-ix; 72 to 156 per group | 0 | Reflects species debut, not necessarily the game the flavor text came from. |
| pokedex_entry | String | English text description of the species | 10 to 41 words, mean 20.8 | 0 | Source game version is not recorded in this file. |
## `pokemon_[type/gen]_word_matrix`
### Word feature (X) variations
Four files follow the `pokemon_type-word_matrix` naming convention and four files follow the `pokemon_gen-word_matrix` naming convention. The data structures within these conventions are identical except for the number of word features (X) included. The proper X values for each of these data sets and some of their feature values are indicated below.

| Data file | Word features (X) | Sample word features |
|:---|:---|:---|
| `pokemon_type-word_matrix.csv` | 150 | silk, honey, cloak, swarm, flower, …, depth, balloon, tear, flotation, tuft |
| `pokemon_type-word_matrix50.csv` | 50 | silk, honey, cloak, electricity, ultra, …, salt, restore, iron, magnetism, wormhole |
| `pokemon_type-word_matrix100.csv` | 100 | silk, honey, cloak, flower, bubble, …, wormhole, threaten, unit, balloon |
| `pokemon_type-word_matrix200.csv` | 200 | silk, honey, cloak, cocoon, swarm, …, swimm, tear, flotation, tuft, capture |
| `pokemon_gen-word_matrix.csv` | 150 | code, flap, host, hunt, quick, …, frigid, mine, particle, pound, save |
| `pokemon_gen-word_matrix50.csv` | 50 | toxic, gas, muscle, timid, storing, …, iron, overwhelm, source, coal, frigid |
| `pokemon_gen-word_matrix100.csv` | 100 | code, flap, quick, bone, toxic, …, coal, cream, frigid, particle, save |
| `pokemon_gen-word_matrix200.csv` | 200 | code, flap, host, hunt, prefer, …, particle, pound, reach, save, surroundings |

### `pokemon_type-word_matrix` convention
| **Feature** | **Type** | **Description** | **Values / Range** | **Missing** | **Uncertainty** |
|:---|:---|:---|:---|:---|:---|
| Pokémon type | String | Pokémon type associated with each row | 18 categories | 0 | None. No duplicates. |
| Word features (X columns) | Numeric | Type-generation averaged TF-IDF scores for the X selected words, with one column per word. Each value represents the type-generation averaged TF-IDF weight of that word in that Pokémon type. | Nonnegative numeric value | 0 | Feature selection based on average TF-IDF across types and generations. Words and scores depend on preprocessing and feature selection found in `/SCRIPTS/pokemon_data_cleaning_for_hca.Rmd`. |

### `pokemon_gen-word_matrix` convention
| **Feature** | **Type** | **Description** | **Values / Range** | **Missing** | **Uncertainty** |
|:---|:---|:---|:---|:---|:---|
| Pokémon generation | String | Pokémon generation associated with each row | 9 categories | 0 | None. No duplicates. |
| Word features (X columns) | Numeric | Type-generation averaged TF-IDF scores for the X selected words, with one column per word. Each value represents the type-generation averaged TF-IDF weight of that word in that Pokémon generation. | Nonnegative numeric value | 0 | Feature selection based on average TF-IDF across types and generations. Words and scores depend on preprocessing and feature selection found in `/SCRIPTS/pokemon_data_cleaning_for_hca.Rmd`. |


# Explanatory Plots
![Pokémon Count by Type (Primary vs. Secondary Slot)](/project1/OUTPUT/pokemonTypeCounts.png)
***Figure 1.** Number of Pokémon per elemental type, split by whether the type appears in the primary or secondary slot. Counting both slots, group sizes range from 47 (Ice) to 146 (Water). Flying is the extreme case, with 8 primary and 94 secondary assignments. Counts exclude the 37 Pokémon with no recorded typing.* 

![Pokédex Entry Length by Generation](/project1/OUTPUT/pokemonEntryLength.png)
***Figure 2.** Distribution of Pokédex entry length in words, by generation. Generation III is a clear outlier, with a median near 31 words against a 16 to 23 word median elsewhere, reflecting the longer entry format of the Ruby and Sapphire games from which those entries are drawn.* 
# References
[1] 	PokéAPI, "PokéAPI: The RESTful Pokémon API." [Online]. Available: https://pokeapi.co. [Accessed: Sep. 17, 2026].
[2] 	PokéAPI Contributors, "LICENSE.md," PokeAPI/pokeapi GitHub repository. [Online]. Available: https://github.com/PokeAPI/pokeapi/blob/master/LICENSE.md. [Accessed: Sep. 17, 2026].
