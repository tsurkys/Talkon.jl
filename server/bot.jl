using Talkon
using ConfigEnv

dotenv()

db = initialize("data/varTEST.data")

talka(db)