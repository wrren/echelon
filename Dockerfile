FROM ubuntu:latest

LABEL maintainer "Warren Kenny github.com/wrren"

# Generate locale in order to avoid warnings during build
RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8 

# Install wget so that we can retrieve the erlang-solutions deb
RUN apt-get -y update && DEBIAN_FRONTEND=noninteractive apt-get install -y wget
RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb

# Install erlang and elixir
RUN dpkg -i erlang-solutions_1.0_all.deb && rm -f erlang-solutions_1.0_all.deb
RUN apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y esl-erlang elixir

# Set up hex for dependencies
RUN mix local.hex --force

# Add the repository's code to the container
ADD . /echelon
WORKDIR /echelon

# Install rebar and depdendencies
RUN mix local.rebar --force
RUN mix deps.get

# Run tests
CMD ["mix", "test"]