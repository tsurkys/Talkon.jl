#!/bin/bash

julia --compile=min -O 0 --startup-file=no --project=. bot.jl
