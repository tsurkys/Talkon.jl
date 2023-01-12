# Talkon.jl
|                                                                                                    **Documentation**                                                                                                    |                                                                                                                              **Build Status**                                                                                                                              |                                                                                                              **JuliaHub**                                                                                                              |
|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
|       [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://tsurkys.github.io/Talkon.jl/stable)[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://tsurkys.github.io/Talkon.jl/dev)       |             [![Build](https://github.com/tsurkys/Talkon.jl/workflows/CI/badge.svg)](https://github.com/tsurkys/Talkon.jl/actions)[![Coverage](https://codecov.io/gh/tsurkys/Talkon.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/tsurkys/Talkon.jl)             |          [![pkgeval](https://juliahub.com/docs/tsurkys/pkgeval.svg)](https://juliahub.com/ui/Packages/Talkon/XXXXX)[![version](https://juliahub.com/docs/Talkon/version.svg)](https://juliahub.com/ui/Packages/Talkon/XXXXX)           |

Bot for mutual help

We will create a Telegram bot dedicated to helping refugees from Ukraine. Volunteers will register and enter the type of help they can provide, the spoken languages, their location or any other relevant information. The refugee, or their assistant, will formulate and assign the type of problem, and the bot would send the requests to the relevant people. After accepting the request, volunteers and the refugee using the bot would be connected to a temporary group for a chat or audio/video call to discuss the problem.

In order to run bot, start `server/bot.jl`.

Curently syncing with gihub is paused, please contact PM.

# Docker version

It is possible to build minimal docker image.

1. Create `.env` file in `server/` directory. Use `server/env_template` as an example.
2. run `docker build -t talkon .` in order to build image
3. run `docker run talkon:latest` to start bot

# Working example

Test verssion is available at https://t.me/Talkon_bot
