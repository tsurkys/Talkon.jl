# states of request case K
# opened
# closed
function trequest(d, tg, av) # participant iniciates a request
    @unpack T, Av, K, groups = d
    if av["step"]=="0"
        if av["token"]<0
            msg="Jūsų taškų skaičiaus nepakanka, prašom sudalyvauti talkoje arba /pakviesti naują dalyvį."
            sendMessage(tg, chat_id = av["id"], text = msg)
            tbegin(tg, av)
        else #if !haskey(av,"requestid") ||
            av["path"] = "0"
            av["step"] = "request"
            msg = "Įrašykite klausimą"
            sendMessage(tg, chat_id = av["id"], text = msg)
        end
        return
    end
    keypath = join(av["path"])
    if av["txt"] == "Parinkti sritį" || av["txt"] == "Atgal"
        tree(tg, av, T)
    elseif av["txt"] == "Pasirinkti" || av["txt"] == "Siųsti"
        if av["txt"] == "Siųsti"
            keypath = "0PaslaugėlėsKita"
        else
            while isempty(T[keypath]["dav_id"])
                if length(T[keypath]["steps"])<2
                    keypath = "0PaslaugėlėsKita"
                    break
                else
                    keypath = join(T[keypath]["steps"][1:end-1])
                end
            end
        end
        msg = "Lukterėkite, tuoj surasiu talkininką."
        sendMessage(tg, chat_id = av["id"], text = msg)
        # TODO: redundant keis?
        keis = K[av["requestid"]]
        subject = join(av["path"][2:end], "/")
        if isempty(subject)
            subject = "bendros"
        end
        keis["subject"] = subject
        keis["dav_id"] = T[keypath]["dav_id"]
        keis["requested_id"] = []
        sendrequest(d, tg, av)
    elseif any(T[keypath]["children"] .== av["txt"])
        av["path"] = vcat(av["path"], av["txt"])
        tree(tg, av, T)
    else #įvedamas užklausimo tekstas
        av["requestid"] = now()
        K[av["requestid"]] = Dict("getter"=>av,"txt"=>deepcopy(av["txt"]),"giver"=>[],"state"=>"opened")
        msg = "Siūskite užklausimą iškart (kainuos papildomą tašką:) arba pasirinkite iš kurios srities klausimas"
        k = [["Siųsti","Parinkti sritį"]]
        d = Dict(:keyboard => k, :one_time_keyboard => true, :resize_keyboard=>true)
        sendMessage(tg, chat_id = av["id"], text = msg, reply_markup = d)
    end
end

function sendrequest(d::DataBase, tg, av) # the request is broadcasted
    @unpack Av, K = d

    keis = K[av["requestid"]]
    if length(keis["requested_id"]) == length(keis["dav_id"])
        msg = """Pakartotinas užklausimas "$(keis["txt"])" iš $(keis["subject"]) temos. Gal pažįstat kas gali atsakyti į šį klausimą?"""
        keis["requested_id"] = []
    else
        msg = """Užklausimas "$(keis["txt"])" iš $(keis["subject"]) temos"""
    end
    k = [["Priimti","Atmesti"]]
    kb = Dict(:keyboard => k, :one_time_keyboard => true, :resize_keyboard=>true)
    i = 1
    for id in keis["dav_id"]
        id == av["id"] && continue
        sendMessage(tg, chat_id = id, text = msg, reply_markup = kb)
        Av[id]["step"] = "requested"
        Av[id]["getterid"] = av["id"]
        push!(keis["requested_id"], id)

        # TODO: ??? what is this condition?
        if length(i) > 4
            break
        end
    end
end

function dealkeis(d, tg, av)
    @unpack Av, K, groups = d
    if av["txt"] == "Priimti"
        avg = Av[av["getterid"]]
        keis = K[avg["requestid"]]
        if avg["step"] == "request"
            keis["group"] = getgroup(groups)
            keis["group"].second["state"] = "notfree"
            msg = "Aptarkit klausimą prisijungus prie grupės: $(keis["group"].second["link"])"
            sendMessage(chat_id = av["getterid"], text = msg)
            avg["step"] = "accepted"
            msg = "Atėjus laikui uždarykite klausimą."
            keyboard = [["Uždaryti klausimą","closekeis()"]]
            #sendMessage(chat_id = keis["group"].first, text = msg, reply_markup = tik(keyboard))
            sendMessage(tg, chat_id = avg["id"], text = msg, reply_markup = tik(keyboard))
            # TODO: Magic number??
            if avg["id"] !== 5090964479
                unbanChatMember(tg, chat_id = keis["group"].first, user_id = avg["id"])
            end
        end
        msg = "Aptarkit klausimą prisijungus prie grupės: $(keis["group"].second["link"])"
        sendMessage(chat_id = av["id"], text = msg)
        push!(keis["giver"], av["id"])
        keis["state"] = "accepted"
        if av["id"] !== 5090964479
            unbanChatMember(chat_id = keis["group"].first,user_id = av["id"])
        end
    elseif av["txt"] == "Atmesti"
        av["getterid"] = nothing
        tbegin(tg, av)
    end
end

function chekeis(d, tg, av)
    @unpack K, Av = d
    n = now()
    for k in keys(K)
        if (k+Minute(30))<n
            if K[k]["state"]=="closed"
                continue
            else
                closekeis(k)
            end
        end
        if K[k]["state"] == "opened" && (k+Minute(1)) < n
            av = Av[K[k]["getter"]["id"]]
            if (k+Minute(7))<n
                av = closekeis(d, tg, av, k)
            else
                sendrequest(d, tg, av)
            end
        end
    end

    return av
end

function closekeis(d, tg, av, k)
    keis = K[k]
    if keis["state"] == "closed"
        return av
    end
    av = Av[keis["getter"]["id"]]
    av["step"]="0"
    if keis["state"] !== "accepted"
        keis["state"] = "closed"
        sendMessage(tg, chat_id = av["id"], text = "Nepavyko rasti talkininko, galite bandyti dar kartą.")
        tbegin(tg, av)
        return av
    end
    keis["state"] = "closed"
    keis["group"].second["state"] = "free"
    chm = getChatMember(tg, chat_id = keis["group"].first, user_id = av["id"])
    if !(chm["status"] == "left") && !(chm["status"] == "creator")
        banChatMember(tg, chat_id = keis["group"].first, user_id = av["id"])
    end
    av["token"] = av["token"]-1
    tfg = 1/(length(keis["giver"])+0.2)
    sendMessage(tg, chat_id = av["id"], text = "Susitikimas uždarytas (jūsų taškų skaičius $(round(10*av["token"])/10)")
    msg = "Ar talka buvo naudinga?"
    k = [["Taip", "valuableyesno(1)", "Ne", "valuableyesno(0)"]]
    sendMessage(tg, chat_id = av["id"], text = msg, reply_markup = tik(k))
    for gid in keis["giver"]
        av = Av[gid]
        chm = getChatMember(tg, chat_id = keis["group"].first, user_id = gid)
        if !(chm["status"] == "left") && !(chm["status"] == "creator")
            banChatMember(tg, chat_id = keis["group"].first, user_id = gid)
        end
        Av[gid]["token"] += tfg
        sendMessage(tg, chat_id = gid, text = "Susitikimas uždarytas (jūsų taškų skaičius $(round(10*Av[gid]["token"])/10))")
        tbegin(tg, av)
        # msg="Galima eiti į pradžią"
        # k=[["Į pradžią", "tbegin()"]]
        # sendMessage(chat_id = gid, text = msg, reply_markup = tik(k))
    end

    return av
end
