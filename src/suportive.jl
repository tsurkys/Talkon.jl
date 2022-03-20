function tree(av,T)
    if av["txt"]=="Atgal" 
        if av["path"][end]=="0" 
            tbegin()
            return
        else
            av["path"]=av["path"][1:end-1]
        end
    end
    pathkey=join(av["path"])
    ch=T[pathkey]["children"]
    children=[]
    ktree=[[]]
    for i in 1:length(ch)
        if any(T[string(pathkey,ch[i])]["dav_id"].==av["id"])
            push!(children,string(ch[i],"✓"))# būtų gerai leisti užsidėti ir kelias žvaigždutes?
        else
            push!(children,ch[i])
        end
    end
    for i in 1:2:length(children)
        if (length(children)-i)>0
            push!(ktree,children[i:i+1])
        else
            push!(ktree,[children[i]])
        end
    end
    if any(T[pathkey]["dav_id"].==av["id"]) && av["step"]=="enter"
        push!(ktree,["Atgal","Nuimti žymę","Namo"])
    else
        push!(ktree,["Atgal","Pasirinkti","Namo"])
    end
    popfirst!(ktree)
    if length(ktree)>1
        msg=string(T[pathkey]["descript"]," Išsirinkite sritį.")
    else
        field=av["path"][end]
        msg="Eikite atgal arba pasirinkite šią $field sritį."
    end
    d=Dict(:keyboard => ktree, :one_time_keyboard => true, :resize_keyboard=>true)
    sendMessage(chat_id = av["id"], text = msg, reply_markup = d)
end

function maketree()
    mtxt=readlines("medis.txt",keep=false)
    steps=["0"]
    E=Dict("field"=>"0","children"=>[],"steps"=>deepcopy(steps),"dav_id"=>[])
    T=Dict("0"=>Dict("field"=>"0","children"=>[],"steps"=>deepcopy(steps),"dav_id"=>[],"descript"=>""))
    lv=0
    for i in 1:length(mtxt)
        it=findall("\t", mtxt[i])
        eile=mtxt[i][length(it)+1:end]
        if '/' in eile
            (eil,descript)=split(eile,'/')
        else
            eil=eile
            descript=""
        end
        y=length(it)+1
        if y>lv
            step=join(steps)
            T[step]["children"]=eil
            append!(steps,[eil])
        elseif y<= lv
            steps=steps[1:end+y-lv]
            steps[end]=eil
            T[join(steps[1:end-1])]["children"]=vcat(T[join(steps[1:end-1])]["children"],eil)
        end
        step=join(steps)
        T[step]=deepcopy(E)
        T[step]["field"]=eil
        T[step]["steps"]=deepcopy(steps)
        T[step]["descript"]=descript
        lv=y
    end
    return T
end

function kas2nkas(name)
    d=Dict("as"=>"ai",'ė'=>"e","us"=>"au","ys"=>"y","is"=>"i","inkas"=>"inke")
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

function tik(k) #talka inline keyboard
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

function taskai()
    sendMessage(chat_id = av["id"], text = "Jūsų taškų skaičius $(round(10*av["token"])/10)")
end

function cleanK()
    #datafile="ss1.jl"
    (T, Av, updateId, K, groups) = deserialize(DATAFILE[])
    collect(keys(K))
    K = Dict(now() => Dict("getter" => Av[5090964479], "txt"=>"refresh", 
                           "giver"=>[1], "state"=>"nothing"))
    serialize(DATAFILE[], [T, Av, updateId, K, groups])
end

function cleanT()
    #datafile="ss1.jl"
    (T,Av,updateId,K,groups) = deserialize(DATAFILE[])
    ak=keys(Av)
    for t in T
        v=[]
        for i in 1:length(t.second["dav_id"])
            if !any(ak.==t.second["dav_id"][i])
                push!(v,i)
            end
        end
        deleteat!(t.second["dav_id"],v)
        t.second["dav_id"]=union(t.second["dav_id"])
    end
    serialize(DATAFILE[], [T,Av,updateId,K,groups])
    print("T išvalytas2")
end
