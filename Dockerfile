FROM julia:1.7

COPY Project.toml /usr/src/Talkon.jl/
COPY src /usr/src/Talkon.jl/src

COPY server/Project.toml server/bot.jl server/bot.sh server/.env /talkon/

WORKDIR /talkon
RUN julia --project=. -e 'using Pkg; Pkg.develop(path = "/usr/src/Talkon.jl"); Pkg.instantiate(); using Talkon'

RUN mkdir /var/log/talkon && mkdir /data
CMD ./bot.sh 2>> /var/log/talkon/error.log 1>> /var/log/talkon/main.log
