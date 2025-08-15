---
title: "How we automated code review"
date: 2025-06-10
categories: devops
---

- TDD
- git subcommands
- using local code syntax check

the code was written in C++
we used latex open source tool,

we had a team of senior C developers, who didn't work with git at all,
we were migrating from subversion to gitlab,
and we just held a complete course for them on "how to use git tools",
then we decided to make it easier for them and provide them with local tooling,
so that they can install it locally and check before push changes upstream,

git check-all
git fix-all

there was a silos between Devs and Ops
and we broke that wall by levereging modern toolkit.

we added the same check to the CI, so that everytime they push changes, we catch all typos and mismatch in the code and provide them with an instant feedback;

that increased delivery time at least twice;

we also did use standart issue templates for all teams for the PRs;
everytime there is a new PR, we provide Devs with checklist;
we also added scripts to automate these check;