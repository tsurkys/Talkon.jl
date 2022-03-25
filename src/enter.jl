function tenter(d, tg, av)
    @unpack T = d
    av["step"] = "enter"
    pathkey = join(av["path"])
    if av["txt"] == "Pasirinkti"
        for k in keys(T)
            if contains(k, pathkey)
                if !any(av["id"] .== T[k]["dav_id"])
                    push!(T[k]["dav_id"], av["id"])
                end
            end
        end
        if !(av["path"][end]=="0")
            av["path"] = av["path"][1:end-1]
        end
    elseif av["txt"] == "Nuimti žymę"
        for k in keys(T)
            if contains(k,pathkey)
                i = findlast(av["id"] .== T[k]["dav_id"])
                if i !== nothing
                    popat!(T[k]["dav_id"], i)
                end
            end
        end
        if !(av["path"][end]=="0")
            av["path"] = av["path"][1:end-1]
        end
    elseif any(T[pathkey]["children"] .== av["txt"])
        av["path"] = vcat(av["path"], av["txt"])
    elseif !(av["txt"] == "Atgal | Повернутися")
        #@warn "Netinkama įvestis"
    end
    tree(tg, av, T)

    return
end
