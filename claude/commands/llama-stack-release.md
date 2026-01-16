# Llama Stack Midstream Release

Automate the complete Llama Stack release workflow from upstream tag to downstream.

## Usage
```
/llama-stack-release <upstream-version> [jira-ticket]
```

Example:
```
/llama-stack-release 0.4.3 RHAIENG-2772
```

## Arguments
- `upstream-version`: The upstream version to sync (e.g., `0.4.3`)
- `jira-ticket`: Optional JIRA ticket for pipeline MR (e.g., `RHAIENG-2772`)

---

## Instructions

You are automating the Llama Stack midstream release workflow. Follow these steps EXACTLY.

### Repository Paths
- **Core Repo**: `/home/skamenan/midstream/midstream-llama-stack`
- **Pipeline Repo**: `/home/skamenan/gitlab/pipeline`
- **RHDS Repo**: `/home/skamenan/midstream/red-hat-data-services/llama-stack-distribution`

### Variables
Set these based on the argument `$ARGUMENTS`:
```
UPSTREAM_VERSION=<first-argument>  # e.g., 0.4.3
DOWNSTREAM_VERSION=${UPSTREAM_VERSION}+rhai0  # e.g., 0.4.3+rhai0
DOWNSTREAM_TAG=v${DOWNSTREAM_VERSION}  # e.g., v0.4.3+rhai0
JIRA_TICKET=<second-argument-or-RHAIENG-XXXX>
```

---

## Step 1: Core Repo - Resync and Tag

### 1.1 Fetch and Create Branch
```bash
cd /home/skamenan/midstream/midstream-llama-stack
git fetch --all --tags
git checkout release-v3.3
git pull midstream release-v3.3
git checkout -b resync-v${UPSTREAM_VERSION}
```

### 1.2 Merge Upstream Tag
```bash
git merge v${UPSTREAM_VERSION}
```

### 1.3 Resolve Conflicts
If conflicts occur:
1. For `uv.lock`: Take theirs, then regenerate:
   ```bash
   git checkout --theirs uv.lock
   git add uv.lock
   ```
2. For `pyproject.toml`: Resolve keeping upstream changes but set version to upstream value (not +rhai0 yet)
3. Check for remaining conflicts:
   ```bash
   grep -rn "<<<<<<< HEAD" . --include="*.toml" --include="*.py"
   ```

### 1.4 Commit Merge
```bash
git add .
git commit -m "merge: resync with upstream v${UPSTREAM_VERSION}"
```

### 1.5 Bump Version (SEPARATE COMMIT)
Edit `pyproject.toml` line 10:
```
version = "${DOWNSTREAM_VERSION}"
```

Then regenerate lock and commit:
```bash
uv lock
git add pyproject.toml uv.lock
git commit -m "bump: use ${DOWNSTREAM_VERSION}"
```

### 1.6 Verify Pre-commit
```bash
uv run pre-commit run --all-files
```
If it fails, fix issues and amend the commit.

### 1.7 Push and Create PR
```bash
git push -u midstream resync-v${UPSTREAM_VERSION}
gh pr create --repo opendatahub-io/llama-stack --base release-v3.3 --head resync-v${UPSTREAM_VERSION} \
  --title "chore: sync with upstream v${UPSTREAM_VERSION}" \
  --body "## Summary
- Resync with upstream release v${UPSTREAM_VERSION}
- Bump version to ${DOWNSTREAM_VERSION}

## Changes from upstream
See: https://github.com/meta-llama/llama-stack/releases/tag/v${UPSTREAM_VERSION}

## After merge
Tag the version bump commit with:
\`\`\`bash
git tag -a ${DOWNSTREAM_TAG} -m \"Downstream release based on upstream v${UPSTREAM_VERSION}\" <commit-hash>
git push midstream ${DOWNSTREAM_TAG}
\`\`\`"
```

### 1.8 After PR Merges - Create Tag
**IMPORTANT**: Wait for PR to merge, then:
```bash
git checkout release-v3.3
git pull midstream release-v3.3
git log --oneline -5  # Find the "bump: use ${DOWNSTREAM_VERSION}" commit
# Tag the version bump commit (NOT the merge commit!)
git tag -a ${DOWNSTREAM_TAG} -m "Downstream release based on upstream v${UPSTREAM_VERSION}" <commit-hash>
git push midstream ${DOWNSTREAM_TAG}
```

Verify: https://github.com/opendatahub-io/llama-stack/releases/tag/${DOWNSTREAM_TAG}

---

## Step 2: Pipeline Repo - Wheel Build

### 2.1 Create Branch
```bash
cd /home/skamenan/gitlab/pipeline
git fetch origin
git checkout -B update-llama-stack-v${UPSTREAM_VERSION} origin/main
```

### 2.2 Update Files
1. Edit `.pre-commit-config.yaml` - find llama-stack dependency:
   ```
   git+https://github.com/opendatahub-io/llama-stack.git@${DOWNSTREAM_TAG}
   ```

2. Edit `collections/llama-stack/cpu-ubi9/constraints.txt`:
   ```
   llama-stack==${DOWNSTREAM_VERSION}
   ```

### 2.3 Generate and Verify
```bash
pre-commit run pkg-gen --all-files
pre-commit run --all-files
```

### 2.4 Commit and Push
```bash
git add .
git commit -s -m "${JIRA_TICKET}: Bump to ${DOWNSTREAM_TAG}

Update llama-stack dependency to ${DOWNSTREAM_TAG}"
git push origin update-llama-stack-v${UPSTREAM_VERSION}
```

### 2.5 Create GitLab MR
```bash
glab mr create --target-branch main \
  --title "${JIRA_TICKET}: Bump to ${DOWNSTREAM_TAG}" \
  --description "## Summary
Bump llama-stack dependency to ${DOWNSTREAM_TAG}

## Changes
- Updated \`.pre-commit-config.yaml\` to use \`@${DOWNSTREAM_TAG}\`
- Updated \`collections/llama-stack/cpu-ubi9/constraints.txt\`
- Regenerated \`requirements.txt\`

## Related
- GitHub tag: https://github.com/opendatahub-io/llama-stack/releases/tag/${DOWNSTREAM_TAG}
- JIRA: https://issues.redhat.com/browse/${JIRA_TICKET}"
```

---

## Step 3: RHDS Repo - Konflux Build

**WAIT**: This step requires the Pipeline MR to be merged first. The merge creates a wheel release on GitLab.

### 3.1 Get Wheel Release Tag
After pipeline MR merges, find the new wheel release:
```
https://gitlab.com/redhat/rhel-ai/llama-stack/pipeline/-/releases
```
Note the release tags (e.g., `3.3.XXX+llama-stack-cpu-ubi9-x86_64` and `aarch64`)

### 3.2 Create Branch
```bash
cd /home/skamenan/midstream/red-hat-data-services/llama-stack-distribution
git fetch upstream
git checkout -B bump-v${UPSTREAM_VERSION} upstream/rhoai-3.3
```

### 3.3 Update konflux/cpu-ubi9.conf
```
LLAMA_STACK_VERSION=${DOWNSTREAM_VERSION}
WHEEL_RELEASE_AARCH64=<new-aarch64-release-tag>
WHEEL_RELEASE_X86_64=<new-x86_64-release-tag>
```

### 3.4 Commit and Push
```bash
git add konflux/cpu-ubi9.conf
git commit -m "chore: bump wheel release to use ${UPSTREAM_VERSION}"
git push origin bump-v${UPSTREAM_VERSION}
```

### 3.5 Create PR
```bash
gh pr create --repo red-hat-data-services/llama-stack-distribution \
  --base rhoai-3.3 --head skamenan7:bump-v${UPSTREAM_VERSION} \
  --title "chore: bump wheel release to use ${UPSTREAM_VERSION}" \
  --body "## Summary
Update to llama-stack ${DOWNSTREAM_VERSION}

## Changes
- Updated wheel release tags in \`konflux/cpu-ubi9.conf\`

## Related
- Wheel release: <gitlab-release-url>
- GitHub tag: https://github.com/opendatahub-io/llama-stack/releases/tag/${DOWNSTREAM_TAG}"
```

---

## Verification Checklist
- [ ] Core repo tag exists: `https://github.com/opendatahub-io/llama-stack/releases/tag/${DOWNSTREAM_TAG}`
- [ ] Pipeline MR merged and wheel release created
- [ ] RHDS PR created/merged
- [ ] Konflux build triggered

---

## Quick Reference

| Repo | Branch | Target |
|------|--------|--------|
| Core | `resync-v${UPSTREAM_VERSION}` | `release-v3.3` |
| Pipeline | `update-llama-stack-v${UPSTREAM_VERSION}` | `main` |
| RHDS | `bump-v${UPSTREAM_VERSION}` | `rhoai-3.3` |
