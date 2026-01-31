#!/bin/bash

# Script: Git Repository Manager
# Purpose: Automate common Git operations and repository management
# Usage: ./17-git-manager.sh [command] [options]

echo "=== Git Repository Manager ==="

# Check if git is installed
if ! command -v git >/dev/null 2>&1; then
    echo "Error: Git is not installed"
    echo "Please install Git first"
    exit 1
fi

# Function to display usage
usage() {
    echo "Usage: $0 [command] [options]"
    echo "Commands:"
    echo "  status                    - Show repository status"
    echo "  init <name>               - Initialize new repository"
    echo "  clone <url> [dir]         - Clone repository"
    echo "  add [files]               - Add files to staging"
    echo "  commit <message>          - Commit changes"
    echo "  push [remote] [branch]    - Push to remote"
    echo "  pull [remote] [branch]    - Pull from remote"
    echo "  branch [name]             - List or create branches"
    echo "  checkout <branch>         - Switch to branch"
    echo "  merge <branch>            - Merge branch"
    echo "  log [count]               - Show commit history"
    echo "  diff [file]               - Show differences"
    echo "  backup                    - Create repository backup"
    echo "  cleanup                   - Clean repository"
    exit 1
}

# Function to check if in git repository
check_git_repo() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "Error: Not in a Git repository"
        echo "Use 'git init' or navigate to a Git repository"
        return 1
    fi
    return 0
}

# Function to show repository status
show_status() {
    if ! check_git_repo; then
        return 1
    fi
    
    echo "Repository Status:"
    echo "=================="
    
    # Basic status
    git status --porcelain | while read status file; do
        case $status in
            "M ") echo "Modified: $file" ;;
            " M") echo "Modified (unstaged): $file" ;;
            "A ") echo "Added: $file" ;;
            "D ") echo "Deleted: $file" ;;
            "??") echo "Untracked: $file" ;;
            "R ") echo "Renamed: $file" ;;
        esac
    done
    
    echo
    echo "Branch Information:"
    echo "Current branch: $(git branch --show-current)"
    echo "Remote branches:"
    git branch -r 2>/dev/null | head -5
    
    echo
    echo "Recent commits:"
    git log --oneline -5
    
    echo
    echo "Repository info:"
    echo "Remote URL: $(git remote get-url origin 2>/dev/null || echo 'No remote configured')"
    echo "Total commits: $(git rev-list --count HEAD 2>/dev/null || echo '0')"
    echo "Contributors: $(git shortlog -sn | wc -l)"
}

# Function to initialize repository
init_repo() {
    local name=$1
    if [ -z "$name" ]; then
        echo "Error: Repository name required"
        return 1
    fi
    
    if [ -d "$name" ]; then
        echo "Error: Directory '$name' already exists"
        return 1
    fi
    
    echo "Initializing repository: $name"
    mkdir "$name"
    cd "$name"
    
    git init
    
    # Create initial files
    cat > README.md << EOF
# $name

This repository was created with the Git Manager script.

## Getting Started

Add your project description here.

## Usage

Add usage instructions here.

## Contributing

Add contribution guidelines here.
EOF
    
    cat > .gitignore << EOF
# Common ignore patterns
*.log
*.tmp
.DS_Store
node_modules/
.env
*.swp
*.swo
*~
EOF
    
    git add README.md .gitignore
    git commit -m "Initial commit: Add README and .gitignore"
    
    echo "Repository '$name' initialized successfully!"
    echo "Location: $(pwd)"
}

# Function to clone repository
clone_repo() {
    local url=$1
    local dir=$2
    
    if [ -z "$url" ]; then
        echo "Error: Repository URL required"
        return 1
    fi
    
    echo "Cloning repository: $url"
    
    if [ -n "$dir" ]; then
        git clone "$url" "$dir"
        echo "Repository cloned to: $dir"
    else
        git clone "$url"
        local repo_name=$(basename "$url" .git)
        echo "Repository cloned to: $repo_name"
    fi
}

# Function to add files
add_files() {
    if ! check_git_repo; then
        return 1
    fi
    
    if [ $# -eq 0 ]; then
        echo "Adding all changes..."
        git add .
    else
        echo "Adding files: $@"
        git add "$@"
    fi
    
    echo "Files staged for commit:"
    git diff --cached --name-only
}

# Function to commit changes
commit_changes() {
    local message="$1"
    
    if ! check_git_repo; then
        return 1
    fi
    
    if [ -z "$message" ]; then
        echo "Error: Commit message required"
        return 1
    fi
    
    # Check if there are staged changes
    if git diff --cached --quiet; then
        echo "No staged changes to commit"
        echo "Staged files first with: $0 add [files]"
        return 1
    fi
    
    echo "Committing changes with message: $message"
    git commit -m "$message"
    
    echo "Commit successful!"
    echo "Latest commit: $(git log --oneline -1)"
}

# Function to push changes
push_changes() {
    local remote=${1:-origin}
    local branch=${2:-$(git branch --show-current)}
    
    if ! check_git_repo; then
        return 1
    fi
    
    echo "Pushing to $remote/$branch..."
    
    if git push "$remote" "$branch"; then
        echo "Push successful!"
    else
        echo "Push failed. You may need to:"
        echo "1. Set up remote: git remote add origin <url>"
        echo "2. Set upstream: git push -u origin $branch"
    fi
}

# Function to pull changes
pull_changes() {
    local remote=${1:-origin}
    local branch=${2:-$(git branch --show-current)}
    
    if ! check_git_repo; then
        return 1
    fi
    
    echo "Pulling from $remote/$branch..."
    
    if git pull "$remote" "$branch"; then
        echo "Pull successful!"
    else
        echo "Pull failed. Check remote configuration."
    fi
}

# Function to manage branches
manage_branches() {
    local branch_name=$1
    
    if ! check_git_repo; then
        return 1
    fi
    
    if [ -z "$branch_name" ]; then
        echo "Current branches:"
        git branch -a
        return 0
    fi
    
    echo "Creating branch: $branch_name"
    if git checkout -b "$branch_name"; then
        echo "Branch '$branch_name' created and checked out"
    else
        echo "Failed to create branch"
    fi
}

# Function to checkout branch
checkout_branch() {
    local branch=$1
    
    if ! check_git_repo; then
        return 1
    fi
    
    if [ -z "$branch" ]; then
        echo "Error: Branch name required"
        return 1
    fi
    
    echo "Switching to branch: $branch"
    if git checkout "$branch"; then
        echo "Switched to branch: $branch"
    else
        echo "Failed to switch branch"
    fi
}

# Function to merge branch
merge_branch() {
    local branch=$1
    
    if ! check_git_repo; then
        return 1
    fi
    
    if [ -z "$branch" ]; then
        echo "Error: Branch name required"
        return 1
    fi
    
    local current_branch=$(git branch --show-current)
    echo "Merging '$branch' into '$current_branch'"
    
    if git merge "$branch"; then
        echo "Merge successful!"
    else
        echo "Merge failed. Resolve conflicts and commit."
    fi
}

# Function to show commit log
show_log() {
    local count=${1:-10}
    
    if ! check_git_repo; then
        return 1
    fi
    
    echo "Commit History (last $count commits):"
    echo "===================================="
    git log --oneline --graph --decorate -n "$count"
    
    echo
    echo "Detailed view of latest commit:"
    git show --stat HEAD
}

# Function to show differences
show_diff() {
    local file=$1
    
    if ! check_git_repo; then
        return 1
    fi
    
    if [ -n "$file" ]; then
        echo "Differences in file: $file"
        git diff "$file"
    else
        echo "All differences:"
        git diff
        
        echo
        echo "Staged differences:"
        git diff --cached
    fi
}

# Function to backup repository
backup_repo() {
    if ! check_git_repo; then
        return 1
    fi
    
    local repo_name=$(basename "$(git rev-parse --show-toplevel)")
    local backup_name="${repo_name}_backup_$(date +%Y%m%d_%H%M%S)"
    local backup_path="../$backup_name.tar.gz"
    
    echo "Creating repository backup..."
    
    # Create archive excluding .git directory for smaller size
    tar -czf "$backup_path" --exclude='.git' -C .. "$repo_name"
    
    # Also create a bundle with full git history
    git bundle create "../${backup_name}.bundle" --all
    
    echo "Backup created:"
    echo "Files: $backup_path"
    echo "Git bundle: ../${backup_name}.bundle"
}

# Function to cleanup repository
cleanup_repo() {
    if ! check_git_repo; then
        return 1
    fi
    
    echo "Cleaning up repository..."
    
    # Remove untracked files
    echo "Removing untracked files..."
    git clean -fd
    
    # Garbage collection
    echo "Running garbage collection..."
    git gc --prune=now
    
    # Remove merged branches (except main/master)
    echo "Removing merged branches..."
    git branch --merged | grep -v -E "(main|master|\*)" | xargs -n 1 git branch -d 2>/dev/null || true
    
    echo "Cleanup completed!"
}

# Main script logic
case "${1:-}" in
    "status")
        show_status
        ;;
    "init")
        if [ -z "$2" ]; then
            echo "Error: Repository name required"
            usage
        fi
        init_repo "$2"
        ;;
    "clone")
        if [ -z "$2" ]; then
            echo "Error: Repository URL required"
            usage
        fi
        clone_repo "$2" "$3"
        ;;
    "add")
        shift
        add_files "$@"
        ;;
    "commit")
        if [ -z "$2" ]; then
            echo "Error: Commit message required"
            usage
        fi
        commit_changes "$2"
        ;;
    "push")
        push_changes "$2" "$3"
        ;;
    "pull")
        pull_changes "$2" "$3"
        ;;
    "branch")
        manage_branches "$2"
        ;;
    "checkout")
        if [ -z "$2" ]; then
            echo "Error: Branch name required"
            usage
        fi
        checkout_branch "$2"
        ;;
    "merge")
        if [ -z "$2" ]; then
            echo "Error: Branch name required"
            usage
        fi
        merge_branch "$2"
        ;;
    "log")
        show_log "$2"
        ;;
    "diff")
        show_diff "$2"
        ;;
    "backup")
        backup_repo
        ;;
    "cleanup")
        cleanup_repo
        ;;
    *)
        usage
        ;;
esac
