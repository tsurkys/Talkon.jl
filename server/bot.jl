using Talkon
using ConfigEnv

dotenv()

db = initialize("varTEST.data")
talka(db)
