# Practice

We use this repo to learn how to work on code together using Git and GitHub.

## What is this about?

When you code alone, you just save files and you're done. When two people work on the same project, you need a system so you don't overwrite each other's work. That system is **Git** (tracks changes) + **GitHub** (stores the code online and lets you review each other's work).

## First time setup

Open your terminal, go to the folder where you want to keep this project, and run:

```bash
cd ~/your-folder        # go to wherever you want to put it
git clone https://github.com/N-Shinomura/practice.git
cd practice             # now you're inside the project
```

This creates a folder called `practice` with all the files in it.

## How to make changes (step by step)

You never edit the main code directly. Instead, you make a copy (called a **branch**), work on that, and then ask your teammate to check it before it gets added.

```bash
# 1. Get the latest code first
git pull origin main

# 2. Make your own branch (replace "your-feature" with what you're doing)
git checkout -b feature/your-feature

# 3. Do your work — edit files, add files, etc.

# 4. Save your changes (called a "commit")
git add .
git commit -m "a short note about what you changed and why"

# 5. Upload your branch to GitHub
git push origin feature/your-feature
```

Then go to GitHub, and you'll see a button to open a **Pull Request (PR)**. A PR is basically saying "hey, I made some changes — can you look at them before we add them to the main code?"

Your teammate looks at it, and if it's good, they merge it (adds it to the main code).

## Rules

1. **Don't change `main` directly.** Always make a branch first.
2. **Write commit messages that say why.** "fix login bug" is better than "update file".
3. **One change per PR.** Don't bundle 5 different things in one PR — it's hard to review.
4. **Let your teammate merge your PR.** A second pair of eyes catches problems.

## Name your branches like this

So it's clear what the branch is for:

- `feature/login-page` — you're adding something new
- `fix/broken-button` — you're fixing something
- `docs/update-readme` — you're updating documentation

## Working together vs working alone

When you code alone, none of this matters. With a teammate, these habits prevent problems:

- **Always `git pull` before you start working.** Your teammate may have changed things since you last looked.
- **Never run `git push --force`.** This can delete your teammate's work from GitHub. Just don't do it.
- **Tell each other what you're working on.** If you both edit the same file at the same time, Git won't know whose version to keep. That's called a merge conflict and it's annoying. A quick message like "I'm editing app.js" prevents it.
- **Push your code often.** If you wait days to push, your code and your teammate's code will be very different, and merging gets messy.

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
