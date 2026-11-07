# Submission

Fork URL: <!-- paste the URL of your fork here -->

## Evidence checklist

- [ ] `evidence/before.txt`: the output of your recon commands (what you found)
- [ ] `evidence/verify.txt`: the output of `sudo ./verify.sh` showing **ALL CHECKS PASSED**
- [ ] `evidence/panic.txt`: the output of `sudo ./verify.sh` right after `sudo ./panic.sh`
- [ ] `fix.sh`: your fix as a script, committed to the repo

## Questions

### Q1. List at least six problems you found. For each: the path, what was wrong, and the risk.

**Your answer:**

<!-- replace this line with your answer -->

### Q2. `deploy` got `Permission denied` even though the script's own permissions looked fine. Which tool showed you the real cause, and what was it?

**Your answer:**

<!-- replace this line with your answer -->

### Q3. Explain the SGID bit on a directory in your own words. What happened to a file created in `logs/` before and after you set it?

**Your answer:**

<!-- replace this line with your answer -->

### Q4. Why is `chmod -R 777` never the fix? Name two concrete problems that `verify.sh` reported after `panic.sh`.

**Your answer:**

<!-- replace this line with your answer -->
