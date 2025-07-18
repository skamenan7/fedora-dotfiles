# Git Worktrees Workflow Guide

A comprehensive guide to using the custom git worktree functions for efficient branch management.

## 🌟 Overview

Git worktrees allow you to have multiple working directories for the same repository, each checked out to different branches. This workflow eliminates the need to stash/unstash changes when switching between features.

## 📁 Directory Structure

```
your-repo/
├── .git/                 # Main git directory
├── main-files...         # Main worktree (original checkout)
└── .worktrees/           # All additional worktrees
    ├── feature-branch-1/
    ├── hotfix-urgent/
    └── experimental/
```

## 🚀 Available Commands

### Core Commands

#### `gwt <branch-name> [--no-sync]`
Creates a new worktree and opens it in Cursor editor.

**Features:**
- ✅ Auto-syncs main with upstream before creating branch
- ✅ Handles existing local branches
- ✅ Handles remote branches (`origin/branch-name`)
- ✅ Creates new branches from latest main
- ✅ Stashes/restores local changes during sync
- ✅ Opens existing worktree if already exists

**Examples:**
```bash
# Standard usage (syncs main first)
gwt feature/user-authentication

# Skip main sync for quick work
gwt hotfix/critical-bug --no-sync

# Open existing worktree
gwt feature/user-authentication  # Just opens if exists

# Work with remote branch
gwt origin/feature-from-teammate
```

#### `gwt-sync [--force-with-lease|-f]`
Syncs current worktree branch with upstream/main.

**Features:**
- ✅ Rebases current branch on latest main
- ✅ Stashes/restores uncommitted changes
- ✅ Handles both upstream and origin remotes
- ✅ Smart push logic with force-with-lease option
- ✅ Prevents syncing main/master branches

**Examples:**
```bash
# Basic sync (safest approach)
gwt-sync

# Sync and immediately force-push with lease
gwt-sync --force-with-lease
gwt-sync -f

# After resolving rebase conflicts
git rebase --continue
gwt-sync --force-with-lease
```

### Management Commands

#### `gwt-list`
Lists all active worktrees with their paths and branches.

```bash
gwt-list
# Output:
# /path/to/repo              (bare)
# /path/to/repo/.worktrees/feature-auth    feature-auth
# /path/to/repo/.worktrees/hotfix-bug      hotfix-bug
```

#### `gwt-rm <branch-name>`
Removes a worktree by branch name.

```bash
# Remove feature branch worktree
gwt-rm feature/user-authentication

# Remove hotfix worktree
gwt-rm hotfix/critical-bug
```

#### `gwt-clean`
Cleans up deleted/stale worktrees.

```bash
gwt-clean
```

### GitHub Integration Commands

#### `gwt-push`
Smart push for current branch.

**Features:**
- ✅ Auto-detects if branch exists on remote
- ✅ Sets upstream for new branches
- ✅ Regular push for existing branches

```bash
gwt-push
```

#### `gwt-pr`
Creates a draft pull request for current branch.

```bash
gwt-pr
# Opens browser with pre-filled PR form
```

## 🔄 Complete Workflows

### 1. Starting a New Feature

```bash
# Create worktree for new feature (syncs main automatically)
gwt feature/user-dashboard

# Work on your feature...
# (Cursor opens automatically)

# Later, sync with latest main if needed
gwt-sync

# Push when ready
gwt-push

# Create pull request
gwt-pr
```

### 2. Working on Existing Remote Branch

```bash
# Check out teammate's branch
gwt feature/api-integration

# Make changes...

# Sync with latest main
gwt-sync

# Push your changes
gwt-push
```

### 3. Quick Hotfix

```bash
# Quick hotfix without syncing main
gwt hotfix/urgent-security-fix --no-sync

# Make the fix...

# Push directly
gwt-push

# Create PR
gwt-pr
```

### 4. Experimental Work

```bash
# Create experimental branch
gwt experiment/new-architecture

# Try things out...

# If it works, sync and push
gwt-sync --force-with-lease

# If it doesn't work, just remove
gwt-rm experiment/new-architecture
```

### 5. Handling Merge Conflicts During Sync

```bash
# Start sync
gwt-sync

# If conflicts occur:
# 1. Resolve conflicts in your editor
# 2. Stage resolved files: git add .
# 3. Continue rebase: git rebase --continue
# 4. Force push: gwt-sync --force-with-lease
```

## 🎯 Best Practices

### ✅ Do's

- **Always sync before starting work**: `gwt feature/new-thing`
- **Sync regularly**: Use `gwt-sync` to stay current with main
- **Use descriptive branch names**: `feature/user-auth`, `fix/login-bug`
- **Clean up finished work**: `gwt-rm old-feature`
- **Use draft PRs**: Start with `gwt-pr` for early feedback

### ❌ Don'ts

- **Don't sync main/master with gwt-sync**: Use regular `git pull` instead
- **Don't ignore rebase conflicts**: Always resolve them properly
- **Don't force-push without understanding**: Use `--force-with-lease`
- **Don't accumulate old worktrees**: Clean up with `gwt-rm`

## 🔧 Advanced Tips

### Multiple Remotes Setup

```bash
# Add upstream remote (for forks)
git remote add upstream https://github.com/original/repo.git

# Your workflow will automatically use upstream for syncing
gwt feature/contribution  # Syncs from upstream/main
```

### Working with Different Base Branches

```bash
# Sometimes you need to branch from develop instead of main
gwt feature/new-thing --no-sync
cd .worktrees/feature/new-thing
git rebase develop  # Manual rebase from develop
```

### Parallel Development

```bash
# Work on multiple features simultaneously
gwt feature/frontend-ui     # Terminal 1
gwt feature/backend-api     # Terminal 2  
gwt hotfix/urgent-bug       # Terminal 3

# Each has its own directory and git state
```

## 🐛 Troubleshooting

### Issue: "worktree already exists"
```bash
# Check existing worktrees
gwt-list

# Remove if needed
gwt-rm problematic-branch
```

### Issue: Rebase conflicts during sync
```bash
# Resolve conflicts manually, then:
git rebase --continue
gwt-sync --force-with-lease
```

### Issue: Stash conflicts after sync
```bash
# Check stash list
git stash list

# Apply specific stash manually
git stash apply stash@{0}
```

### Issue: Force push warnings
```bash
# Always use force-with-lease for safety
git push --force-with-lease origin branch-name

# Or use the built-in command
gwt-sync --force-with-lease
```

## 📊 Command Quick Reference

| Command | Purpose | Example |
|---------|---------|---------|
| `gwt <branch>` | Create/open worktree | `gwt feature/auth` |
| `gwt-sync` | Sync with main | `gwt-sync` |
| `gwt-sync -f` | Sync + force push | `gwt-sync --force-with-lease` |
| `gwt-list` | List worktrees | `gwt-list` |
| `gwt-rm <branch>` | Remove worktree | `gwt-rm old-feature` |
| `gwt-clean` | Clean stale worktrees | `gwt-clean` |
| `gwt-push` | Smart push | `gwt-push` |
| `gwt-pr` | Create PR | `gwt-pr` |

## 🎉 Benefits

- **No more stash/unstash**: Each feature has its own directory
- **Parallel development**: Work on multiple features simultaneously  
- **Always up-to-date**: Auto-sync with main before creating branches
- **IDE-friendly**: Each worktree opens in separate Cursor window
- **Safe rebasing**: Built-in conflict handling and recovery
- **GitHub integration**: Easy PR creation and management

Happy coding! 🚀
