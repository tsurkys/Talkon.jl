function newmb(d::DataBase, msg)
    @unpack mbs = d
    from_id = msg["message"]["from"]["id"]
    mbs[from_id] = Dict("first_name" => msg["message"]["from"]["first_name"],
                      "token" => 4, "step" => "00", "id" => from_id, "msgtodelete"=>[],
                      "ln" => "", "spoken_lns" => [])
    mb = mbs[from_id]
    if haskey(msg["message"]["from"],"last_name")
        mb["last_name"] = msg["message"]["from"]["last_name"]
    end
    if any(msg["message"]["from"]["language_code"] .== ["lt","en","ua"])
        ln = msg["message"]["from"]["language_code"]
    else
        ln = ""
    end
    talkon_language(d, mb, ln) # next step
end

function talkon_language(d::DataBase, mb, ln)
    if ln == ""
        msg = "Choose language | Pasirinkti kalbą | Виберіть мову"
        keyboard = [["English", "talkon_language,en", "Lietuvių", "talkon_language,lt",
                    "Українці", "talkon_language,ua"]]
        sendms(msg, mb, keyboard = keyboard)
        return
    else
        mb["ln"]=ln
        if mb["step"] == "00"
            push!(mb["spoken_lns"],ln)
        else
            tbegin(mb)
            return
        end
    end
    disclaimer(d, mb, "") # next step
end

function disclaimer(d::DataBase, mb, input)
    @unpack tree = d
    if input==""
        sendms(string(dc("hello1", mb), kas2nkas(mb["first_name"]), dc("hello2", mb)), mb)
        sendms("disclaimer1", mb)
        sendms("disclaimer2", mb)
    else
        if  any(["/accept",	"/priimti", "/прийняти"] .== mb["txt"])
            for pathkey in keys(tree)
                push!(tree[pathkey]["dav_id"], mb["id"])
            end
            println(string("Registered new member: ", mb["first_name"]))
            sendMessage(chat_id = -729825915, text = string("Registered new member: ", mb["first_name"])) 
            spoken_languages(mb, "")
        else
        end
    end
end

function spoken_languages(mb, input)
    lns=Dict("en" => "English", "lt" => "Lietuvių", "ua" => "Українці", "ru" => "Русский")
    if any(input .== keys(lns))
        if any(input .== mb["spoken_lns"])
            deleteat!(mb["spoken_lns"],mb["spoken_lns"] .== input)
        else
            push!(mb["spoken_lns"], input)
        end
    end 
    keyboard=[[]]
    for ln in lns
        if any(ln.first .== mb["spoken_lns"])
            lns[ln.first] = "✓ " * lns[ln.first]
        end
        push!(keyboard[1], lns[ln.first], "spoken_languages" * "," * ln.first)
    end
    if mb["step"] == "00"
        push!(keyboard,[dc("spoken_languages_chosen", mb), "registerinvitecode(),_"])
    else
        push!(keyboard,[dc("spoken_languages_chosen", mb), "tbegin()"])
    end
    sendms("spoken_languages_choose_ln", mb, keyboard = keyboard)
end

function registerinvitecode(d::DataBase, mb, input)
    if input == "_"
        keyboard = [[dc("yes", mb), "registerinvitecode(),yes", dc("no", mb), "registerinvitecode(),no"]]
        sendms("ask_code", mb, keyboard = keyboard)
        return
    elseif input == "no"
    elseif input == "yes"
        sendms("registerinvitecode_enter_code", mb)
        mb["step"]="wait_for_invite_code"
        return
    elseif mb["step"] == "wait_for_invite_code"
        @unpack mbs = d
        id = tryparse(Int, mb["txt"])
        if id !== nothing && any(keys(mbs) .== id)
            mbs[id]["token"] += 2
            msg = string(dc("registerinvitecode_invited_registered", mbs[id]), mbs[id]["token"])
            sendMessage(chat_id = id,text = msg)
            mb["token"] += 2
            sendms("registerinvitecode_code_accepted", mb)
        else
            sendms("registerinvitecode_incorrect_code", mb)
            return
        end
    end
    tbegin(mb) # next step
end

function tbegin(mb) # go home (/start)
    if any(mb["step"] .== ["wait_for_invite_code", "00"])
        sendms("welcome_text", mb)
    end
    mb["step"] = "0"
    mb["path"] = ["0"]
    keyboard = [[dc("begin_keyb_ask", mb), "trequest()",
                    dc("begin_keyb_mark", mb), "tenter(),enter"]]
    sm=sendms("begin_text", mb, keyboard = keyboard)
    push!(mb["msgtodelete"], sm["message_id"])
end

function invite(mb) # /invite, invitation text and code
    sendms("invite_1", mb)
    sendms("invite_2", mb)
    sendms("$(mb["id"])", mb)
end

