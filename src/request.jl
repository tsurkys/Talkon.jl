# states of request case keises
# opened
# closed
function trequest(d, tg, mb) # participant iniciates a request
    @unpack tree, mbs, keises, groups = d
    if mb["step"]=="0"
        if mb["token"]<-200 # suspiciously many requests generated by same person
            msg="Jūsų taškų skaičiaus nepakanka, prašom sudalyvauti talkoje arba pakviesti naują dalyvį."
            sendMessage(tg, chat_id = mb["id"], text = msg)
            tbegin(tg, mb)
            println("suspiciously many requests generated by same person $(mb["id"])")
        else #if !haskey(mb,"requestid") ||
            mb["path"] = "0"
            mb["step"] = "request"
            msg = "Įrašykite klausimą. | Введіть запитання. | Введите вопрос."
            sendMessage(tg, chat_id = mb["id"], text = msg)
        end
        return
    end
    keypath = join(mb["path"])
    if mb["txt"] == "Parinkti | Виберіть" || mb["txt"] == "Atgal | Повернутися"
        tree(tg, mb, tree)
    elseif mb["txt"] == "Pasirinkti" || mb["txt"] == "Siųsti | Відправити"
        if mb["txt"] == "Siųsti | Відправити"
            keypath = "0Paslaugos | Послуги"
        else
            while isempty(tree[keypath]["dav_id"])
                if length(tree[keypath]["steps"])<2
                    keypath = "0Paslaugos | Послуги"
                    break
                else
                    keypath = join(tree[keypath]["steps"][1:end-1])
                end
            end
        end
        msg = "Lukterėkite, tuoj surasiu talkininką. | Зачекайте, я скоро знайду помічника."
        sendMessage(tg, chat_id = mb["id"], text = msg)
        # TODO: redundant keis? Do not understand the question
        keis = keises[mb["requestid"]]
        subject = join(mb["path"][2:end], "/")
        if isempty(subject)
            subject = "bendros"
        end
        keis["subject"] = subject
        keis["dav_id"] = tree[keypath]["dav_id"]
        sendrequest(d, tg, mb)
    elseif any(tree[keypath]["children"] .== mb["txt"])
        mb["path"] = vcat(mb["path"], mb["txt"])
        tree(tg, mb, tree)
    else # The text of request was entered
        mb["requestid"] = now()
        keises[mb["requestid"]] = Dict("getter"=>mb,"txt"=>deepcopy(mb["txt"]),"giver"=>[],"state"=>"opened","requested_id"=>[])
        msg = "Siūskite užklausimą iškart arba pasirinkite iš kurios srities klausimas. | Надішліть запит негайно або виберіть, з якої області запитати."
        k = [["Siųsti | Відправити","Parinkti | Виберіть"]]
        d = Dict(:keyboard => k, :one_time_keyboard => true, :resize_keyboard=>true)
        sendMessage(tg, chat_id = mb["id"], text = msg, reply_markup = d)
    end
end

function sendrequest(d::DataBase, tg, mb) # the request is broadcasted
    @unpack mbs, keises = d

    keis = keises[mb["requestid"]]
    if length(keis["requested_id"]) == length(keis["dav_id"])
        msg = """Pakartotinas užklausimas "$(keis["txt"])" iš "$(keis["subject"])" temos. Gal pažįstat kas gali atsakyti į šį klausimą?"""
        keis["requested_id"] = []
    else
        msg = """Užklausimas "$(keis["txt"])" iš $(keis["subject"]) temos"""
    end
    k = [["Priimti","Atmesti"]]
    kb = Dict(:keyboard => k, :one_time_keyboard => true, :resize_keyboard=>true)
    i = 1
    for id in shuffle(keis["dav_id"])
        if id == mb["id"] || any(keis["requested_id"].==id)
            continue
        end
        try
            sendMessage(tg, chat_id = id, text = msg, reply_markup = kb)
        catch
            println("Didn't manage to send to $id, $(mbs[id]["first_name"])")
            continue
        end
        mbs[id]["step"] = "requested"
        mbs[id]["getterid"] = mb["id"]
        push!(keis["requested_id"], id)
        i=i+1
        if length(i) > 4 #this is one portion of sent requests
            break
        end
    end
end

function dealkeis(d, tg, mb)
    @unpack mbs, keises, groups = d
    if mb["txt"] == "Priimti"
        avg = mbs[mb["getterid"]]
        keis = keises[avg["requestid"]]
        if avg["step"] == "request"
            keis["group"] = getgroup(groups)
            keis["group"].second["state"] = "notfree"
            msg = "Aptarkit klausimą prisijungus prie grupės: | Обговоріть проблему, приєднавшись до групи:  $(keis["group"].second["link"])"
            sendMessage(chat_id = mb["getterid"], text = msg)
            avg["step"] = "accepted"
            msg = "Atėjus laikui uždarykite klausimą. | Закрийте питання, коли прийде час."
            keyboard = [["Uždaryti klausimą | Закрийте питання","closekeis()"]]
            #sendMessage(chat_id = keis["group"].first, text = msg, reply_markup = tik(keyboard)) # the bottum could be also in a group (at present is too complicated)
            sendMessage(tg, chat_id = avg["id"], text = msg, reply_markup = tik(keyboard))
            if avg["id"] !== 5090964479 # if not owner of the group
                unbanChatMember(tg, chat_id = keis["group"].first, user_id = avg["id"])
            end
        elseif avg["step"] !== "accepted"
            return
        end
        msg = "Aptarkit klausimą prisijungus prie grupės: | Обговоріть проблему, приєднавшись до групи: $(keis["group"].second["link"])"
        sendMessage(chat_id = mb["id"], text = msg)
        push!(keis["giver"], mb["id"])
        keis["state"] = "accepted"
        if mb["id"] !== 5090964479 # if not owner of the group
            unbanChatMember(chat_id = keis["group"].first,user_id = mb["id"])
        end
    elseif mb["txt"] == "Atmesti"
        mb["getterid"] = nothing
        tbegin(tg, mb)
    end
end

function chekeis(d, tg, mb)
    @unpack keises, mbs = d
    n = now()
    for k in keys(keises)
        if (k+Minute(30))<n
            if keises[k]["state"]=="closed"
                continue
            else
                closekeis(d, tg, mb, k)
            end
        end
        if keises[k]["state"] == "opened" && (k+Minute(1)) < n
            mb = mbs[keises[k]["getter"]["id"]]
            if (k+Minute(7))<n
                mb = closekeis(d, tg, mb, k)
            else
                sendrequest(d, tg, mb)
            end
        end
    end

    return mb
end

function closekeis(d, tg, mb, k)
    @unpack keises, mbs = d
    keis = keises[k]
    if keis["state"] == "closed"
        return mb
    end
    mb = mbs[keis["getter"]["id"]]
    mb["step"]="0"
    if keis["state"] !== "accepted"
        keis["state"] = "closed"
        sendMessage(tg, chat_id = mb["id"], text = "Nepavyko rasti talkininko, bandykite dar kartą. | Не вдалося знайти допомогу, спробуйте ще раз.")
        tbegin(tg, mb)
        return mb
    end
    keis["state"] = "closed"
    keis["group"].second["state"] = "free"
    chm = getChatMember(tg, chat_id = keis["group"].first, user_id = mb["id"])
    if !(chm["status"] == "left") && !(chm["status"] == "creator")
        banChatMember(tg, chat_id = keis["group"].first, user_id = mb["id"])
    end
    mb["token"] = mb["token"]-1
    tfg = 1/(length(keis["giver"])+0.2)
    sendMessage(tg, chat_id = mb["id"], text = "Susitikimas uždarytas. | Зустріч закрита.") #(jūsų taškų skaičius $(round(10*mb["token"])/10)")
    msg = "Ar talka buvo naudinga? | Чи була допомога корисною?"
    k = [["Taip | Так", "valuableyesno(1)", "Ne | Ні", "valuableyesno(0)"]]
    sendMessage(tg, chat_id = mb["id"], text = msg, reply_markup = tik(k))
    for gid in keis["giver"]
        mb = mbs[gid]
        chm = getChatMember(tg, chat_id = keis["group"].first, user_id = gid)
        if !(chm["status"] == "left") && !(chm["status"] == "creator")
            banChatMember(tg, chat_id = keis["group"].first, user_id = gid)
        end
        mbs[gid]["token"] += tfg
        sendMessage(tg, chat_id = gid, text = "Susitikimas uždarytas. | Зустріч закрита.") #(jūsų taškų skaičius $(round(10*mbs[gid]["token"])/10))")
        tbegin(tg, mb)
        # msg="Galima eiti į pradžią"
        # k=[["Į pradžią", "tbegin()"]]
        # sendMessage(chat_id = gid, text = msg, reply_markup = tik(k))
    end

    return mb
end
