function tree(tg, mb, tree)
    if mb["txt"] == "Atgal | Повернутися"
        if mb["path"][end] == "0"
            tbegin(tg, mb)
            return
        else
            mb["path"] = mb["path"][1:end-1]
        end
    end
    pathkey = join(mb["path"])
    ch = tree[pathkey]["children"]
    children = []
    ktree = [[]]
    for i in 1:length(ch)
        if any(tree[string(pathkey,ch[i])]["dav_id"] .== mb["id"])
            push!(children,string(ch[i],"✓"))
        else
            push!(children,ch[i])
        end
    end
    for i in 1:2:length(children)
        if (length(children)-i) > 0
            push!(ktree,children[i:i+1])
        else
            push!(ktree,[children[i]])
        end
    end
    if any(tree[pathkey]["dav_id"] .== mb["id"]) && mb["step"] == "enter"
        push!(ktree,["Atgal | Повернутися","Nuimti žymę","Namo | Додому"])
    else
        push!(ktree,["Atgal | Повернутися","Pasirinkti","Namo | Додому"])
    end
    popfirst!(ktree)
    if length(ktree) > 1
        msg = string(tree[pathkey]["descript"]," Išsirinkite sritį.")
    else
        field = mb["path"][end]
        msg = """Eikite atgal arba pasirinkite šią "$field" sritį."""
    end
    kb = Dict(:keyboard => ktree, :one_time_keyboard => true, :resize_keyboard=>true)
    sendMessage(tg, chat_id = mb["id"], text = msg, reply_markup = kb)

    return
end

function maketree(filename = "tree.txt")
    mtxt = readlines(filename, keep = false)
    steps = ["0"]
    E = Dict("field"=>"0","children"=>[],"steps"=>deepcopy(steps),"dav_id"=>[])
    tree = Dict("0"=>Dict("field"=>"0","children"=>[],"steps"=>deepcopy(steps),"dav_id"=>[],"descript"=>""))
    lv = 0
    for i in 1:length(mtxt)
        it = findall("\t", mtxt[i])
        eile = mtxt[i][length(it)+1:end]
        if '/' in eile
            (eil,descript) = split(eile,'/')
        else
            eil = eile
            descript = ""
        end
        y = length(it)+1
        if y>lv
            step = join(steps)
            tree[step]["children"] = eil
            append!(steps,[eil])
        elseif y<= lv
            steps = steps[1:end+y-lv]
            steps[end] = eil
            tree[join(steps[1:end-1])]["children"] = vcat(tree[join(steps[1:end-1])]["children"],eil)
        end
        step = join(steps)
        tree[step] = deepcopy(E)
        tree[step]["field"] = eil
        tree[step]["steps"] = deepcopy(steps)
        tree[step]["descript"] = descript
        lv = y
    end
    return tree
end

function makedictionary()

function kas2nkas(name) # changes endings of Lithuanian names
    d = Dict("as"=>"ai",'ė'=>"e","us"=>"au","ys"=>"y","is"=>"i","inkas"=>"inke")
    if length(name)>5 && haskey(d,name[end-4:end])
        nname=name[1:end-5]*d[name[end-4:end]]
    elseif haskey(d,name[end-1:end])
        nname=name[1:end-2]*d[name[end-1:end]]
    elseif haskey(d,name[end])
        nname=name[1:end-1]*d[name[end]]
    else
        nname=name
    end
end

function tik(k) #talkon inline keyboard
    kb=[]
    for ki in k
        kl=[]
        for i in 1:2:length(ki)
            push!(kl,Dict(:text=>ki[i],:callback_data =>ki[i+1]))
        end
        push!(kb,kl)
    end
    d=Dict(:inline_keyboard => kb)
    return d
end

function getgroup(groups)
    for group in groups
        if group.second["state"]=="free"
            return group
        end
    end

    print("not enought free rooms")
end

function taskai(tg) # now not used
    sendMessage(tg, chat_id = mb["id"], text = "Jūsų taškų skaičius $(round(10*mb["token"])/10)")
end

function cleanK(d::DataBase)
    (tree, mbs, updateId, keises, groups) = deserialize(DATAFILE[])
    d.keises = Dict(now() => Dict("getter" => mbs[5090964479], "txt"=>"refresh",
                             "giver"=>[1], "state"=>"nothing","requested_id"=>[]))
    serialize(DATAFILE[], [tree, mbs, updateId, keises, groups])
end

function cleanT()
    (tree,mbs,updateId,keises,groups) = deserialize(DATAFILE[])
    ak=keys(mbs)
    for t in tree
        v=[]
        for i in 1:length(t.second["dav_id"])
            if !any(ak.==t.second["dav_id"][i])
                push!(v,i)
            end
        end
        deleteat!(t.second["dav_id"],v)
        t.second["dav_id"]=union(t.second["dav_id"])
    end
    serialize(DATAFILE[], [tree,mbs,updateId,keises,groups])
    print("tree išvalytas2")
end
