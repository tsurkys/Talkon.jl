mutable struct DataBase
    tree::Dict{String, Dict{String, Any}}
    mbs::Dict{Int64, Dict{String, Any}}
    update_id::Int
    keises::Dict{DateTime, Dict{String, Any}}
    groups::Dict{Int, Dict{String, String}}
    dln::Dict{String, Dict{String, String}} # at present not used
end
