# git related functions, sourced in ~/.bashrc

# Get the common functions loaded
. ~/.bash/.bash_functions

# Global git branches we don't want to touch, blacklisted.
# (not sure if origin is needed actually)
export __GIT_YOUR_HANDS_OFF=("HEAD" "staging" "master" "development" "origin" "SEURAT_*")

# You can also have the prompt show the 'dirty' status of your repo, i.e. if you
# have uncommited changes, and whether your branch differs from upstream HEAD:
#
# * = unstaged changes
# + = staged changes
# $ = stashed changes
# % = untracked files
# u-1 = behind upstream by 1 commit
# u+2 = ahead of upstream by 2 commits
# u= = same as upstream
gitprompt () {
  echo -e "\n$(tput smul)Normal Settings$(tput rmul)\n"
  echo " $(tput setaf 5)*$(tput setaf 9)      unstaged changes"
  echo " $(tput setaf 5)+$(tput setaf 9)      staged changes"
  echo " $(tput setaf 5)\$$(tput setaf 9)      stashed changes"
  echo " $(tput setaf 5)%$(tput setaf 9)      untracked files"
  echo " $(tput setaf 5)u-1$(tput setaf 9)    behind upstream by 1 commit"
  echo " $(tput setaf 5)u+2$(tput setaf 9)    ahead of upstream by 2 commits"
  echo " $(tput setaf 5)u+1-2$(tput setaf 9)  diverged from upstream"
  echo " $(tput setaf 5)u=$(tput setaf 9)     equal to upstream"
  echo -e "\n$(tput smul)Verbose Settings$(tput rmul)\n"
  echo " $(tput setaf 5)=$(tput setaf 9)      equal to upstream"
  echo " $(tput setaf 5)>$(tput setaf 9)      ahead of upstream"
  echo " $(tput setaf 5)<$(tput setaf 9)      behind upstream"
  echo " $(tput setaf 5)<>$(tput setaf 9)     diverged form upstream"
}

git_branch_is_blacklisted() {
  contains_element "$1" "${__GIT_YOUR_HANDS_OFF[@]}"
}

# Prints out all your remote branches
git_my_branches() {
  local blue=$(tput setaf 6; tput bold)
  local nc=$(tput sgr0)
  # Check the "owner" name for the remote branch. This may not always be correct
  # since users might change their commit name in the config.
  local GIT_UNAME=`git config user.name`
  local BRANCHES=(`git for-each-ref --format='%(authorname) %09 %(refname)' | grep "$GIT_UNAME" | awk -F "refs/remotes/origin/" 'NF > 1 {print $2}'`)
  echo -e "\nRemote branches for $GIT_UNAME:\n"
  printf "  $blue%s$nc\n" "${BRANCHES[@]}"
}

# Show the branches not merged in to the current branch you are on
git_show_missing() {
  local branch=${1:?"A branch is required"}
  local current=${2:-`git rev-parse --abbrev-ref HEAD`}
  git log ${branch} ^${current} --first-parent --pretty=format:"%h - %an %s"
}

# Deletes a list git branches locally, and then it will attempt deleting it on
# the remote repo. If you do not own the remote branch it will not delete it.
delete_branches() {
  for branch in "$@"; do
    __delete_branch $branch
  done
}

git_intersection() {
  # Check the "owner" name for the remote branch. This may not always be correct
  # since users might change their commit name in the config.
  local GIT_UNAME=`git config user.name`
  local list1=(`git for-each-ref --format='%(authorname) %09 %(refname)' | grep "$GIT_UNAME" | awk -F "refs/remotes/origin/" 'NF > 1 {print $2}'`)
  local list2=()

  # Get the local branches, exluding the asterisk
  for branch in $(git branch | tr -d " *"); do
    git_branch_is_blacklisted "$branch"
    if [[ "$?" == 1 ]]; then
      list2+=($branch)
    fi
  done

  # 1. Intersection
   C=($(comm -12 <(printf '%s\n' "${list1[@]}" | LC_ALL=C sort) <(printf '%s\n' "${list2[@]}" | LC_ALL=C sort)))

  # # 2. B - A
   D=($(comm -13 <(printf '%s\n' "${list1[@]}" | LC_ALL=C sort) <(printf '%s\n' "${list2[@]}" | LC_ALL=C sort)))

  local blue=$(tput setaf 6; tput bold)
  local nc=$(tput sgr0)

  printf "  $blue%s$nc\n" "${C[@]}"
  echo
  echo
  printf "  $blue%s$nc\n" "${D[@]}"
}

git_history_merged() {
  local branches=()
  # Get the local branches, exluding the asterisk
  for branch in $(git branch | tr -d " *"); do
    git_branch_is_blacklisted "$branch"
    if [[ "$?" == 1 ]]; then
      history | grep 'git merge' | grep -q $branch
      if [[ "$?" == 0 ]]; then
        branches+=($branch)
      fi
    fi
  done

  local blue=$(tput setaf 6; tput bold)
  local nc=$(tput sgr0)
  printf "  $blue%s$nc\n" "${branches[@]}"
}


# Deletes a git branch locally, and then it will attempt deleting it on the
# remote repo. If you do not own the remote branch it will not delete it.
__delete_branch() {
  local BRANCH=${1:?"A branch is required"}

  git_branch_is_blacklisted "$BRANCH"
  if [[ "$?" == 0 ]]; then
    echo -e "\nInvalid branch: $(tput setaf 6; tput bold)$BRANCH$(tput sgr0)"
    echo -e "\nYou cannot delete any of these branches:"
    echo
    printf '  %s\n' "${__GIT_YOUR_HANDS_OFF[@]}"
    echo
    return 1
  fi

  # Delete it locally if it exists
  if [[ `git branch | grep "$BRANCH"` ]]; then
    git branch -D "$BRANCH"
  else
    echo "Branch does not exist locally, looking for remote to delete..."
  fi

  # Check the "owner" name for the remote branch and make sure it's the same as
  # the one that is trying to delete it. This may not always be correct since
  # users might change their commit name in the config.
  local GIT_UNAME=`git config user.name`
  local BRANCH_OWNER=`git for-each-ref --format='%(authorname) %09 %(refname)' | grep "origin/${BRANCH}" | awk '{print $1, $2}'`
  if [[ "$GIT_UNAME" == "$BRANCH_OWNER" ]]; then
    git push origin --delete "$BRANCH"
  else
    echo "Skipping remote delete since you do not own it"
  fi
}

# Attaches git tab completion to a function
__git_completer() {
  local track=1
  __gitcomp_nl "$(__git_refs '' $track)"
}
__git_complete delete_branches __git_completer
__git_complete git_show_missing __git_completer
