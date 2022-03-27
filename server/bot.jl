using Talkon
using ConfigEnv
using MiniLoggers

MiniLogger(minlevel = MiniLoggers.Debug,
           errlevel = MiniLoggers.AboveMaxLevel,
           message_mode = :squash,
           format = "[{timestamp:func}] {level:func} {basename}:{line:cyan}{::yellow} {message}") |> global_logger

dotenv()

db = initialize(get(ENV, "TALKON_DATA_FILE", "varTEST.data"))
talka(db)
