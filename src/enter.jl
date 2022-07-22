function tenter(d, mb, action)
    @unpack tree = d
    mb["step"] = "enter"
    pathkey = join(mb["path"])
    if action == "select"
        for k in keys(tree)
            if contains(k, pathkey)
                if !any(mb["id"] .== tree[k]["dav_id"])
                    push!(tree[k]["dav_id"], mb["id"])
                end
            end
        end
    elseif action == "unselect"
        for k in keys(tree)
            if contains(k,pathkey)
                i = findlast(mb["id"] .== tree[k]["dav_id"])
                if i !== nothing
                    popat!(tree[k]["dav_id"], i)
                end
            end
        end
    else
    end
    if isempty(tree[pathkey]["children"])
        mb["path"] = mb["path"][1:end-1]
        pathkey = join(mb["path"])
    end
    traversetree(d, mb, pathkey)
end