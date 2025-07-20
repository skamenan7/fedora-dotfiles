# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc
alias c="clear"
alias wp="warp-terminal"
alias cursor="/usr/local/sbin/cur"  # Use actual Cursor app
export PATH="/home/skamenan/.npm-global/bin:$PATH"

# Custom prompt configuration
# Function to get git branch
get_git_branch() {
    local branch=$(git branch 2>/dev/null | grep '^*' | cut -d' ' -f2-)
    if [ -n "$branch" ]; then
        echo " ($branch)"
    fi
}

# Function to get shortened path (last 2 directories)
get_short_path() {
    local dir=$(pwd | sed "s|$HOME|~|")
    local IFS='/'
    local path_array=($dir)
    local len=${#path_array[@]}
    
    if [ $len -gt 3 ]; then
        echo ".../${path_array[$((len-2))]}/${path_array[$((len-1))]}"
    else
        echo "$dir"
    fi
}


ghi() {
  URL=$(gh issue view "$1" --json url -q ".url")
  echo "🔗 Issue URL: $URL"
  echo "$URL" | xargs xdg-open
}

ghpr() {
  URL=$(gh pr view "$1" --json url -q ".url")
  echo "🔗 PR URL: $URL"
  echo "$URL" | xargs xdg-open
}


ghprt() {
  URL=$(gh pr view "$1" --json url -q ".url")
  echo "🔗 PR URL: $URL"
#   echo "$URL" | xargs xdg-open
  gh pr view "$1" --web=false
    echo "Press Enter to open in browser..."
    read -r
    xdg-open "$URL"
}

# Virtual environment and git-aware prompt: venv:short-path (git-branch) 
# $
PS1='\[\e[36m\]${VIRTUAL_ENV:+$(basename $VIRTUAL_ENV):}\[\e[0m\]\[\e[32m\]$(get_short_path)\[\e[0m\]\[\e[33m\]$(get_git_branch)\[\e[0m\] \n\[\e[37m\]$\[\e[0m\] '
# pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - bash)"
eval "$(pyenv virtualenv-init -)"


# For Git worktrees 
# Create and open a new worktree under .worktrees/
gwt() {
  if [ -z "$1" ]; then
    echo "❗ Usage: gwt <branch-name> [--no-sync]"
    echo "  Creates worktree and syncs with upstream/main first (unless --no-sync)"
    return 1
  fi

  branch="$1"
  no_sync="$2"
  repo_root=$(git rev-parse --show-toplevel)
  worktree_dir="$repo_root/.worktrees/$branch"

  # Check if worktree already exists
  if [ -d "$worktree_dir" ]; then
    echo "✅ Worktree already exists, opening..."
    cursor "$worktree_dir" &
    return 0
  fi

  mkdir -p "$repo_root/.worktrees"

  # Sync with upstream/main first (unless --no-sync)
  if [ "$no_sync" != "--no-sync" ]; then
    echo "🔄 Syncing main with upstream..."
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    
    # Stash changes if any
    if ! git diff-index --quiet HEAD --; then
      echo "💾 Stashing local changes..."
      git stash push -m "gwt: auto-stash before sync"
      stashed=true
    fi
    
    # Switch to main and reset to clean state
    git checkout main 2>/dev/null || git checkout master 2>/dev/null
    
    echo "🧹 Resetting main to clean state..."
    git reset --hard HEAD
    git clean -fd
    
    # Sync with upstream
    if git remote | grep -q upstream; then
      git pull upstream main --rebase 2>/dev/null || git pull upstream master --rebase 2>/dev/null
      git push origin HEAD 2>/dev/null || true
    else
      git pull origin --rebase
    fi
    
    # Return to original branch
    git checkout "$current_branch" 2>/dev/null || true
    
    # Restore stash if we stashed
    if [ "$stashed" = true ]; then
      echo "🔄 Restoring stashed changes..."
      git stash pop
    fi
  fi

  echo "🌿 Creating worktree for branch '$branch'..."
  
  # Try to add existing branch first, fallback to creating new from main
  if git show-ref --verify --quiet "refs/heads/$branch"; then
    echo "📌 Using existing branch '$branch'"
    git worktree add "$worktree_dir" "$branch"
  elif git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
    echo "📥 Checking out remote branch 'origin/$branch'"
    git worktree add "$worktree_dir" -b "$branch" "origin/$branch"
  else
    echo "✨ Creating new branch '$branch' from main"
    main_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
    git worktree add "$worktree_dir" -b "$branch" "$main_branch"
  fi

  # Copy .cursor/rules.md into the new worktree so Cursor rules are always present
  if [ -f "$repo_root/.cursor/rules.md" ]; then
    echo "📜 Copying .cursor/rules.md into new worktree"
    mkdir -p "$worktree_dir/.cursor"
    cp "$repo_root/.cursor/rules.md" "$worktree_dir/.cursor/rules.md"
  fi

  # Copy Super_Claude_Docs.md into new worktree so Cursor has extended docs
  if [ -f "$HOME/.cursor/Super_Claude_Docs.md" ]; then
    echo "📜 Copying Super_Claude_Docs.md into new worktree"
    mkdir -p "$worktree_dir/.cursor"
    cp "$HOME/.cursor/Super_Claude_Docs.md" "$worktree_dir/.cursor/Super_Claude_Docs.md"
  fi

  echo "🚀 Opening worktree in Cursor..."
  cursor "$worktree_dir" &
}

# List all worktrees
gwt-list() {
  git worktree list
}

# Remove a worktree by branch name (auto path from .worktrees)
gwt-rm() {
  if [ -z "$1" ]; then
    echo "❗ Usage: gwt-rm <branch-name>"
    return 1
  fi
  repo_root=$(git rev-parse --show-toplevel)
  git worktree remove "$repo_root/.worktrees/$1"
}

# Clean up deleted/stale worktrees
gwt-clean() {
  git worktree prune
}

# Sync current worktree branch with upstream/main
gwt-sync() {
  local force_push="$1"
  local current_branch=$(git rev-parse --abbrev-ref HEAD)
  
  # Don't sync if we're on main/master
  if [[ "$current_branch" == "main" || "$current_branch" == "master" ]]; then
    echo "❌ Cannot sync main/master branch. Use regular git pull instead."
    return 1
  fi
  
  echo "🔄 Syncing branch '$current_branch' with upstream..."
  
  # Stash uncommitted changes
  local stashed=false
  if ! git diff-index --quiet HEAD --; then
    echo "💾 Stashing uncommitted changes..."
    git stash push -m "gwt-sync: auto-stash $(date)"
    stashed=true
  fi
  
  # Get the main branch name
  local main_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
  
  # Fetch latest changes
  echo "📥 Fetching latest changes..."
  git fetch --all --prune
  
  # Check if upstream remote exists
  if git remote | grep -q upstream; then
    echo "🔄 Rebasing on upstream/$main_branch..."
    if ! git rebase "upstream/$main_branch"; then
      echo "⚠️  Rebase conflicts detected. Resolve conflicts and run:"
      echo "   git rebase --continue"
      echo "   Then optionally: gwt-sync --force-with-lease"
      return 1
    fi
  else
    echo "🔄 Rebasing on origin/$main_branch..."
    if ! git rebase "origin/$main_branch"; then
      echo "⚠️  Rebase conflicts detected. Resolve conflicts and run:"
      echo "   git rebase --continue"
      echo "   Then optionally: gwt-sync --force-with-lease"
      return 1
    fi
  fi
  
  # Restore stashed changes
  if [ "$stashed" = true ]; then
    echo "🔄 Restoring stashed changes..."
    if ! git stash pop; then
      echo "⚠️  Stash pop conflicts. Resolve manually with: git stash list"
    fi
  fi
  
  # Check if remote branch exists and push
  local remote_exists=$(git ls-remote --heads origin "$current_branch")
  if [ -n "$remote_exists" ]; then
    if [ "$force_push" = "--force-with-lease" ] || [ "$force_push" = "-f" ]; then
      echo "🚀 Force pushing rebased branch to origin..."
      git push --force-with-lease origin "$current_branch"
    else
      echo "📤 Checking if push is needed..."
      local local_commit=$(git rev-parse HEAD)
      local remote_commit=$(git rev-parse "origin/$current_branch" 2>/dev/null || echo "")
      
      if [ "$local_commit" != "$remote_commit" ]; then
        echo "⚠️  Branch history has changed due to rebase."
        echo "💡 Use 'gwt-sync --force-with-lease' to update remote branch"
        echo "   Or manually: git push --force-with-lease origin $current_branch"
      else
        echo "✅ Remote branch is already up to date"
      fi
    fi
  else
    echo "📤 Pushing new branch to origin..."
    git push --set-upstream origin "$current_branch"
  fi
  
  echo "✅ Sync completed for branch '$current_branch'"
}

gwt-push() {
  branch=$(git rev-parse --abbrev-ref HEAD)
  remote_branch_exists=$(git ls-remote --heads origin "$branch")

  if [ -z "$remote_branch_exists" ]; then
    echo "🚀 Pushing new branch '$branch' to origin..."
    git push --set-upstream origin "$branch"
  else
    echo "📤 Pushing changes to existing branch '$branch'..."
    git push
  fi
}

gwt-pr() {
  branch=$(git rev-parse --abbrev-ref HEAD)

  echo "📝 Creating draft PR for branch '$branch'..."

  gh pr create \
    --fill \
    --draft \
    --head "$branch" \
    --web
}

export CLIPBOARD_SELECTION=clipboard

# Test: symbolic link sync working!
