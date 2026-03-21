#!/usr/bin/bash

GREEN="\e[0;32m"
BLACK="\e[0;30m"
RED="\e[0;31m"
CLEAN_LINE="\033[2K"
RESET_CURSOR="\r"

function notify_cleanup () {
  if [[ "$*" =~ -S ]]; then
    printf "$%bSafe mode is ON.\n" ${RED};
    printf "%bENV setup failed will begin deleting created file\n" ${RED}; 
    printf "%bIf you dont want to accidentaly lose shit, you have 10 second to stop this\n" $RED;
    i=10;
    while [[ $i -ge 0 ]]; do
      (( i-- ));
      sleep 1
      printf "%b%b" $CLEAN_LINE $RESET_CURSOR
    done;
  fi;
};


function fail_cleanup () {
	rm -r src include CMakeLists.txt
}

# env prep
if [[ $# < 1 ]]; then
  echo "Provide a project name"
  exit 0
fi;

touch CMakeLists.txt;
mkdir -p include;
mkdir -p src;

if [[ ! -d "src" ]] || [[ ! -d "include" ]]; then
  echo "could not create src/ and include/"
	notify_cleanup $*
	fail_cleanup
fi;


# create files
debug_mode=false
main_name="main" 

if [[ "$@" =~ "-d" ]]; then
  debug_mode=true
fi;



touch src/main.cpp;

echo "cmake_minimum_required(VERSION 4.0)
project($1)

set(CMAKE_EXPORT_COMPILE_COMMANDS on)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED on)
set(CMAKE_BUILD_TYPE Debug)

target_include_directories(main PRIVATE \${CMAKE_SOURCE_DIR}/lib/include)
" >> CMakeLists.txt;


echo "using namespace std;
using ll =  long long;
using ull =  unsigned long long;

namespace srv = ranges::views;
namespace sr = ranges;
namespace sv = views;
" >> src/main.cpp;

printf "%bDone\n" ${GREEN}
exit 0
