function traversetree(d::DataBase, mb, pathkey)
    local keyboard
    @unpack tree = d
    mb["path"] = deepcopy(tree[pathkey]["path"])
    if mb["step"] == "enter" && isempty(tree[pathkey]["children"]) # if final branch then action of selection comes in
        if !any(tree[pathkey]["dav_id"] .== mb["id"])
            tenter(d, mb, "select")
        else
            tenter(d, mb, "unselect")
        end
        return
    end
    i=1
    keyboard=[[]]
    for child in tree[pathkey]["children"] # formation of keyboard out of the children
        chpathkey = string(pathkey,child)
        txt = tree[chpathkey]["field"][mb["ln"]]
        !isempty(tree[chpathkey]["children"]) ? txt = txt * ".." : nothing
        if any(tree[chpathkey]["dav_id"] .== mb["id"]) && mb["step"] == "enter"
            txt = txt * " ✓"
        end
        if !iseven(i) || length(txt)>20 
            push!(keyboard,[txt,"traversetree(),$chpathkey"])
        else
            push!(keyboard[end],txt,"traversetree(),$chpathkey")
        end
        i+=1
    end
    popfirst!(keyboard)
    # next additional keyboar keys
    if pathkey != "0"
        backpathkey = join(tree[pathkey]["path"][1:end-1])
    else
        backpathkey = pathkey
    end
    if mb["step"] == "enter"
        if any(tree[pathkey]["dav_id"] .== mb["id"])
           kbl=[dc("tree_unselect", mb),"tenter(),unselect"]
        else
           kbl=[dc("tree_select", mb),"tenter(),select"]
        end
    else
        kbl=[dc("tree_send", mb),"propagate()"]
    end
    push!(keyboard,[dc("tree_back", mb),"traversetree(),$backpathkey",
                    kbl[1],kbl[2],
                    dc("tree_home", mb),"tbegin()"])
    if pathkey == "0"
        deleteat!(keyboard[end],[1,2])
    end                    
    if !isempty(tree[pathkey]["children"])
        msg = string(tree[pathkey]["descript"][mb["ln"]],dc("tree_choose_area", mb))
    else
        msg = string(tree[pathkey]["descript"][mb["ln"]],
                     dc("tree_go_back_or _choose_this_1", mb),
                     tree[pathkey]["field"][mb["ln"]],
                     dc("tree_go_back_or _choose_this_2", mb))
    end
    sendMessage(chat_id = mb["id"], text = msg, reply_markup = tik(keyboard))
end

# Changes endings of Lithuanian names
function kas2nkas(name)
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

function getgroup(groups)
    for group in groups
        if group.second["state"]=="free"
            return group
        end
    end

    print("not enough free rooms")
end

function get_tokens(mb) 
    sendms(string(dc("get_tokens_your_ammount", mb), (round(10*mb["token"])/10)), mb)
end

function sendms(frase = "enter", mb = nothing; ln = nothing, chat_id = nothing, keyboard = nothing)
    global DLN
    if mb === nothing
        ln = "en"
    end
    if ln === nothing
        ln = mb["ln"]
    end
    if chat_id === nothing
        chat_id = mb["id"]
    end 
    if haskey(DLN, frase)
        text = DLN[frase][ln]
    else
        text = frase
    end       
    if keyboard === nothing
        ms = sendMessage(chat_id = chat_id, text = text)
    else
        ms = sendMessage(chat_id = chat_id, text = text, reply_markup = tik(keyboard))
    end
    ms
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
    Dict(:inline_keyboard => kb)
end

function dc(frase, mb)
    global DLN
    DLN[frase][mb["ln"]]
end