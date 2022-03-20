mutable struct DataBase
    T::Dict{String, Dict{String, Any}}
    Av::Dict{Int, Dict{String, Any}}
    update_id::Int
    K::Dict{DateTime, Dict{String, Any}}
    groups::Dict{Int, Dict{String, String}}
end
