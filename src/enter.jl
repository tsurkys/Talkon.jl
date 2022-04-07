function tenter(d, tg, mb)
    @unpack tree = d
    mb["step"] = "enter"
    pathkey = join(mb["path"])
    if mb["txt"] == "Pasirinkti"
        for k in keys(tree)
            if contains(k, pathkey)
                if !any(mb["id"] .== tree[k]["dav_id"])
                    push!(tree[k]["dav_id"], mb["id"])
                end
            end
        end
        if !(mb["path"][end]=="0")
            mb["path"] = mb["path"][1:end-1]
        end
    elseif mb["txt"] == "Nuimti žymę"
        for k in keys(tree)
            if contains(k,pathkey)
                i = findlast(mb["id"] .== tree[k]["dav_id"])
                if i !== nothing
                    popat!(tree[k]["dav_id"], i)
                end
            end
        end
        if !(mb["path"][end]=="0")
            mb["path"] = mb["path"][1:end-1]
        end
    elseif any(tree[pathkey]["children"] .== mb["txt"])
        mb["path"] = vcat(mb["path"], mb["txt"])
    elseif !(mb["txt"] == "Atgal | Повернутися")
        #@warn "Netinkama įvestis"
    end
    tree(tg, mb, tree)

    return
end
