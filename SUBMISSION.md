# Submission

Fork URL: <!-- paste the URL of your fork here -->

## Files to commit

- [ ] `fix.sh`: your fix as a script, committed to the repo

## Questions

Answer in your own words. Where a question asks for output, paste it in a code block.

### Q1. List at least six problems you found. For each: the path, what was wrong, and the risk.

**Your answer:**

<!-- replace this line with your answer -->

### Q2. `deploy` got `Permission denied` even though the script's own permissions looked fine. Which tool showed you the real cause, and what was it? Paste the output that proves it.

**Your answer:**

<!-- replace this line with your answer -->

### Q3. Explain the SGID bit on a directory in your own words. What happened to a file created in `logs/` before and after you set it?

**Your answer:**

<!-- replace this line with your answer -->

### Q4. Paste the output of `sudo ./verify.sh` after running your `fix.sh`. It must end with **ALL CHECKS PASSED**.

**Your answer:**

<!-- replace this line with your answer -->

### Q5. Now run `sudo ./panic.sh` and then `sudo ./verify.sh` again. Paste the output, then explain why `chmod -R 777` is never the fix: name two concrete problems `verify.sh` reported.

**Your answer:**

<!-- replace this line with your answer -->
