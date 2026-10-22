# CIS-3901 Projects template

## 1. What this is

The template for your **CIS-3901 Data Visualization and Presentation** Challenge Projects (Fall 2026, Catawba College): R scripts, Quarto reports and Quarto slides for the Fairness Data and Sports Data projects, published as one website with GitHub Pages. See the finished example at <https://acintron-cc.github.io/cis-3901-202710/>.

## 2. Get your own copy

On GitHub, click **Use this template → Create a new repository**. Choose **public**, or **private** if you prefer not to publish (then submit through Posit Cloud).

## 3. Open it in Posit Cloud

**New Project → New Project from Git Repository**, then paste the URL of **your** repository (not this template).

To push your changes from Posit Cloud to GitHub you need a GitHub personal access token: see GitHub's guide, [Managing your personal access tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens). Never put a token in a file.

## 4. Folders

| Folder | What goes there |
|---|---|
| `data/` | The data: `fairness/` (messy Fairness Data packages), `sports/` (your SCORE download), `tidy/` (your tidy CSVs), `example/` (penguins) |
| `scripts/` | Your R tidying scripts (`01_tidy_fairness.R`, `02_tidy_sports.R`) |
| `reports/` | Your Quarto reports (`fairness_report.qmd`, `sports_report.qmd`) |
| `presentations/` | Your Quarto slides (`fairness_slides.qmd`, `sports_slides.qmd`) |
| `example/` | The worked penguin example: one report and three slides |
| `docs/` | The rendered website (created by `quarto render`; GitHub Pages serves it) |

## 5. Data

- **Fairness Data (datasets from Fairlearn):** five messy packages in `data/fairness/`. To choose one, read [`data/fairness/README.md`](data/fairness/README.md); each package folder has its own dataset card.
- **Raw URLs:** you can also read any file straight from GitHub with `read_csv()`:
  ```
  https://raw.githubusercontent.com/acintron-cc/cis-3901-202710/main/data/fairness/<dataset>/<file>.csv
  ```
- **Sports Data:** download your dataset from the SCORE Sports Data Repository (<https://data.scorenetwork.org/>) and save it in `data/sports/`.

## 6. Render and publish

1. Run `quarto render` in the Terminal (or use **Render Website** in the Build pane). The site is written to `docs/`.
2. Commit and push, including `docs/`.
3. On GitHub: **Settings → Pages → Deploy from a branch → `main` → `/docs` → Save**. Your site appears at `https://<your-user-name>.github.io/<your-repository>/` within a few minutes.

## 7. The example

`example/` holds a short finished report and slide deck about Palmer Penguins. Keep it as a model, or delete `example/` and its **Example** menu in `_quarto.yml`.

## 8. Data sources and licenses

- **Fairness Data (from Fairlearn):** Adult, Bank Marketing, Credit Card and Diabetes Hospital come from the UCI Machine Learning Repository (CC BY 4.0, attribution required); ACS Income is US Census Bureau public data. Each dataset card in `data/fairness/` gives the full citation.
- **Palmer Penguins:** Horst, A. M., Hill, A. P., & Gorman, K. B. (2020). *palmerpenguins: Palmer Archipelago (Antarctica) penguin data* (R package). <https://allisonhorst.github.io/palmerpenguins/> License: CC0.
- **Sports Data:** from the SCORE Sports Data Repository; cite each dataset's page.

## 9. License

Code, templates and text in this repository are dedicated to the public domain under CC0 1.0. **Exception:** files in `data/` keep the license of their original source, stated in each dataset's README (UCI datasets: CC BY 4.0, attribution required; US Census ACS: public data; Palmer Penguins: CC0).

The full CC0 1.0 Universal legal text is in [`LICENSE`](LICENSE).

**License of your copy:** the template's code, skeletons and text are CC0 1.0 (public domain), so you can use and change them freely with no attribution. Your own work in your copy is yours: keep CC0, or replace `LICENSE` with a license of your choice. Files in `data/` keep their original licenses; cite the sources in your reports.
