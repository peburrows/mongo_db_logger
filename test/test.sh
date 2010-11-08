#!/bin/bash
#  This script uses rvm and gemsets to test the gem against all versions of ruby
#  (RUBY_VERSIONS) and all rails versions in the test/rails directories
#  (RAILS_VERSIONS).

# If these aren't unset, bundler always uses them to find itself and the
# root project gemfile
unset BUNDLE_BIN_PATH
unset BUNDLE_GEMFILE

RAILS_VERSIONS='2 3'
RUBY_VERSIONS='1.8.7 1.9.2'
PROJECT_GEMSET='central_logger'
RAILS_DIR=rails
RAILS_RAKE_TASK_MODIFIER=':functionals'
RAKE_UNIT_TASK_MODIFIER=':unit'
CLEAN=0
VALID_OPT='--clean'

function usage() {
   echo 'Usage:  ' $0 "[${VALID_OPT}]"
   echo 'Options:' $VALID_OPT 'Delete and recreate all gemsets before running tests'
   exit 1
}

ARG=$1
if [ $# -gt 1 ] || [ ${ARG:-$VALID_OPT} != $VALID_OPT ]; then
  usage
elif [ -n "$1" ]; then
  CLEAN=1
fi

# Load RVM into a shell session *as a function*
if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
  # First try to load from a user install
  source "$HOME/.rvm/scripts/rvm"
elif [[ -s "/usr/local/rvm/scripts/rvm" ]]; then
  # Then try to load from a root install
  source "/usr/local/rvm/scripts/rvm"
else
  printf "ERROR: An RVM installation was not found.\n"
  exit 1
fi

# deletes and recreates a gemset
function clean_gemset() {
  RUBY=$1; GEMSET=$2
  # easier than checking and emptying/creating
  rvm --force gemset delete ${RUBY}@${GEMSET}
  rvm gemset create $GEMSET
}

# runs rake test, optionally cleaning the gemset
function rake_test() {
  RUBY=$1; GEMSET=$2; SUBTASK=$3
  echo
  echo "-----------Running tests for '${RUBY}@${GEMSET}'------------"
  rvm $RUBY

  if [ $CLEAN -eq 1 ]; then
    clean_gemset $RUBY $GEMSET
    rvm gemset use $GEMSET
    bundle install
  else
    rvm gemset use $GEMSET
  fi

  # 'rvm $RUBY_VER rake' doesn't work with bundle install
  rake test${SUBTASK}
  if [ $? -ne 0 ]; then exit 1; fi
}

# Loop through all perms of rubies and rails
cd test
for RBV in $RUBY_VERSIONS; do
  rake_test $RBV $PROJECT_GEMSET $RAKE_UNIT_TASK_MODIFIER

  NEXT_DIR=$RAILS_DIR
  for RV in $RAILS_VERSIONS; do
    if [ "$NEXT_DIR" == "$RAILS_DIR" ]; then
      NEXT_DIR=${NEXT_DIR}/${RV}
    else
      NEXT_DIR=../${RV}
    fi
    cd $NEXT_DIR

    rake_test $RBV ${PROJECT_GEMSET}_${RV} $RAILS_RAKE_TASK_MODIFIER
  done

  cd ../..
done
