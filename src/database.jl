mutable struct DataBase
    tree::Dict{String, Dict{String, Any}}
    mbs::Dict{Int, Dict{String, Any}}
    update_id::Int
    keises::Dict{DateTime, Dict{String, Any}}
    groups::Dict{Int, Dict{String, String}}
end
