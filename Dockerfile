FROM ubuntu:latest

LABEL "com.github.actions.name"="mcmap project benchmak"
LABEL "com.github.actions.description"="Run a sample execution to compare execution time accross commits"
LABEL "com.github.actions.icon"="check-circle"
LABEL "com.github.actions.color"="orange"

LABEL "repository"="https://github.com/spoutn1k/mcmap-benchmark.git"
LABEL "homepage"="https://github.com/spoutn1k/mcmap-benchmark"
LABEL "maintainer"="spoutn1k <jb.skutnik@gmail.com>"

RUN apt update
RUN apt install g++ make libpng-dev --yes

COPY entrypoint.sh /entrypoint.sh
COPY benchmark /benchmark

ENTRYPOINT ["/entrypoint.sh"]
