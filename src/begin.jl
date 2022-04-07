function newav(d::DataBase, tg, ms)
    @unpack tree, mbs = d
    from_id = ms["message"]["from"]["id"]
    mbs[from_id] = Dict("first_name" => ms["message"]["from"]["first_name"],
                      "token" => 4, "step" => "00", "id" => from_id)
    if haskey(ms["message"]["from"],"last_name")
        mbs[from_id]["last_name"] = ms["message"]["from"]["last_name"]
    end
    mb = mbs[from_id]
    for pathkey in keys(tree)
        push!(tree[pathkey]["dav_id"],mb["id"])
    end
    println(string("Registered new member: ", mb["first_name"]))
    msg = string("Sveiki/Здравствуйте, ", kas2nkas(mb["first_name"]), "! Esu robotas Talkon. Aš padedu kaip taksi išsikviesti (arba suteikti) bendruomenės pagalbą./Я робот Talkon. Я допомагаю як таксі викликати (або надати) допомогу./Я робот Талкон. Помогаю как такси вызвать (или оказать) помощь.")
    sendMessage(tg, chat_id = from_id, text = msg)
    sendMessage(tg, chat_id = from_id, text = welcometext())
    tbegin(tg, mb)
    #keyboard = [["Taip","invitecodeyesno(1)","Ne","invitecodeyesno(0)"]]
    #sendMessage(chat_id = from_id,text = "Ar turite pakvietimo kodą?",reply_markup = tik(keyboard))
    return mb
end

function tbegin(tg, mb)
    mb["step"] = "0"
    mb["path"] = ["0"]
    msg = "Galite klausti klausimą ir prašyti pagalbos, arba jei galite suteikti pagalbą, žymėti sritis kuriose galite pagelbėti./Ви можете попросити і попросити про допомогу або, якщо ви можете надати допомогу, позначити місця, де ви можете допомогти."
    keyboard = [["Klausti/Спитати/Спросить", "trequest()", "Žymėti/Позначте/Отметить", "tenter()"]]
    sendMessage(tg, chat_id = mb["id"], text = msg, reply_markup = tik(keyboard))

    return
end

function welcometext()
    txt="""Ši priemonė skirta padėti Ukrainos pabėgėliams. Kai suformuluosite klausimą, tą klausimą reiks priskirti sričiai iš sričių medžio tam, kad klausimas nukeliautų pas išmanantį žmogų. Kai norėsite prisidėti sprendžiant kitų klausimus, taip pat reikės pasirinkti sritis, kur jūs turite išmanymą. | 
            Цей інструмент покликаний допомогти об’єднати запитувача та обізнаних. Як тільки ви сформулюєте питання, це питання потрібно буде призначити до області з дерева областей, щоб питання було передано обізнаній людині. Якщо ви хочете внести свій внесок у вирішення проблем інших людей, вам також потрібно буде вибрати сфери, де ви маєте досвід.
            """
end

# ***** below functions that are not used for a now *****
function registerinvitecode()
    id=tryparse(Int, mb["txt"])
    if id !== nothing && any(keys(mbs).==id)
        mbs[id]["token"]+=2
        msg="Jūsų pakviestas dalyvis sėkmingai užsiregistravo! O jums prisidėjo du taškai. Bendras taškų skaičius $(mbs[id]["token"])"
        sendMessage(chat_id = id,text = msg)
        #mb["tonken"]+=2
        msg="Pakvietimo kodas priimtas"
        sendMessage(chat_id = mb["id"],text = msg)
        tbegin(tg, mb)
    else
        msg="Kažkas negerai su kodu, bandykite dar kartą arba tęskite paspaudę komandą /namo."
        sendMessage(chat_id = mb["id"],text = msg)
    end
end

function invite() # this is not used now
    msg="Nusiūskite žmogui nuorodą bei kodą (jei reikia, pirmiausia pakviestkite į Telegram platformą)."
    sendMessage(chat_id = mb["id"],text = msg)
    msg="Prisijunkite į Talką @talkon_bot, pakvietimo kodas:."
    sendMessage(chat_id = mb["id"],text = msg)
    sendMessage(chat_id = mb["id"],text = "$(mb["id"])")
end

function invitecodeyesno(t) # this is not needed now
    if t==0
        tbegin(tg, mb)
        return
    end
    sendMessage(chat_id = mb["id"], text = "Įveskite kodą")
    mb["step"]="wait_for_invite_code"
end
