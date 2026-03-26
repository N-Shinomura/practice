# Practice

We use this repo to learn how to work on code together using Git and GitHub. Our practice project is replicating **Giroud et al. (2026)** "Innovation Spillovers across U.S. Tech Clusters" from the *Journal of Financial Economics*. The original replication package includes Stata/SAS code and datasets — we use those as our starting point.

## Here we practice

how to manage coding files with collaborators. We use **Git** (tracks changes on your computer) and **GitHub** (stores the code online so collaborators can access it, review changes, and merge work together).

## First time setup

Pick a folder to keep files for this project (e.g. `~/ghub` or `~/projects`). Keeping all repos in one place makes them easy to find. Open your terminal, go to that folder, and run these commands to download the repo:

```bash
cd ~/ghub                # choose the folder for this project
git clone https://github.com/N-Shinomura/practice.git
cd practice              # now you're inside the project
```

## How to make changes (step by step)

Once you get (pull) the remote files, you can make changes. But you never edit the main code directly. Instead, you make a copy of the entire project (called a **branch**). This branch has all the same files — you just work on it without affecting `main`. When you're done editing, you upload your branch to GitHub (called **pushing**), then create a request on GitHub asking your teammate to look at your changes (called a **Pull Request**). Your teammate reads through what you changed, and if it looks good, adds it into `main`.

```bash
# 1. Get the latest code first
git pull origin main

# 2. Make your own branch — name it after your task
#    e.g. if you're replicating Table 2: git checkout -b feature/table2
git checkout -b feature/your-task-name

# 3. Do your work — edit files, add files, etc.

# 4. Save your changes (called a "commit")
git add .
git commit -m "a short note about what you changed and why"

# 5. Upload your branch to GitHub
git push origin feature/your-feature
```

Then go to GitHub, and you'll see a button to open a **Pull Request**. A Pull Request is basically saying "hey, I made some changes — can you look at them before we add them to the main code?"

Your teammate looks at it, and if it's good, they merge it (adds it to the main code).

## Rules

1. **Don't change `main` directly.** Always make a branch first.
2. **Write commit messages that say why.** "fix login bug" is better than "update file".
3. **One change per Pull Request.** Don't bundle 5 different things — it's hard to review.
4. **Let your teammate merge your Pull Request.** A second pair of eyes catches problems.
5. **Always `git pull` before you start working.** Your teammate may have pushed changes since you last looked.
6. **Push your code often.** Don't sit on changes for days — small frequent pushes are easier to merge.
7. **Tell each other what you're working on.** Editing the same file at the same time causes merge conflicts.
8. **Name your branches clearly:** `feature/login-page` (new), `fix/broken-button` (fix), `docs/update-readme` (docs).

## What to do when you get a merge conflict

Sometimes Git says it can't merge because you and your teammate changed the same part of a file. Here's how to fix it:

```bash
# Get the latest main
git checkout main
git pull origin main

# Go back to your branch and bring in the new changes
git checkout your-branch
git merge main
```

Git will mark the conflicting parts in the file like this:

```
<<<<<<< your-branch
your version of the code
=======
their version of the code
>>>>>>> main
```

Pick the right version (or combine them), delete the `<<<` `===` `>>>` markers, save the file, then:

```bash
git add .
git commit -m "fix merge conflict"
```

## Let's begin

1. Clone this repo (see "First time setup" above)
2. Download the datasets from [Google Drive](https://drive.google.com/drive/folders/1HWwIJHh3kTHf6slrypHvG1DTxCP88F0O?usp=sharing) and place them in `Replication Package Spillovers JFE/Datasets/`
3. Open the `practice` folder in VS Code
4. Read `Replication Package Spillovers JFE/READ ME.pdf` to understand what the original code does
5. Look at the programs in `Programs/` — `simulate.sas`, `data_construction.sas`, and `regressions.do`
6. Pick a table from the paper to replicate together in R or Python

