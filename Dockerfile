FROM julia:1.7

COPY Project.toml /usr/src/Talkon.jl/
COPY src /usr/src/Talkon.jl/src
# RUN julia -e 'using Pkg; Pkg.develop(path = "/usr/src/Talkon.jl"); using Talkon'

COPY server/Project.toml server/bot.jl server/bot.sh server/varTEST.data server/.env /talkon/
WORKDIR /talkon
RUN julia --project=. -e 'using Pkg; Pkg.develop(path = "/usr/src/Talkon.jl"); Pkg.instantiate(); using Talkon'

CMD ./bot.sh
