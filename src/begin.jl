function newav(d::DataBase, tg, av, ms)
    @unpack T, Av, K, groups = d
    from_id = ms["message"]["from"]["id"]
    Av[from_id] = Dict("first_name" => ms["message"]["from"]["first_name"],
                      "token" => 4, "step" => "00", "id" => from_id)
    if haskey(ms["message"]["from"],"last_name")
        Av[from_id]["last_name"] = ms["message"]["from"]["last_name"]
    end
    av = Av[from_id]
    for pathkey in keys(T)
        push!(T[pathkey]["dav_id"],av["id"])
    end
    println(string("Užsiregistravo avėjas: ", av["first_name"]))
    msg = string("Sveiki/Здравствуйте, ", kas2nkas(av["first_name"]), "! Esu robotas Talkon. Aš padedu kaip taksi išsikviesti (arba suteikti) pagalbą./Я робот Talkon. Я допомагаю як таксі викликати (або надати) допомогу./Я робот Талкон. Помогаю как такси вызвать (или оказать) помощь.")
    sendMessage(tg, chat_id = from_id, text = msg)
    sendMessage(tg, chat_id = from_id, text = welcometext())
    tbegin(tg, av)
    #keyboard = [["Taip","invitecodeyesno(1)","Ne","invitecodeyesno(0)"]]
    #sendMessage(chat_id = from_id,text = "Ar turite pakvietimo kodą?",reply_markup = tik(keyboard))
    return av
end

function tbegin(tg, av)
    av["step"] = "0"
    av["path"] = ["0"]
    msg = "Galite klausti ir prašyti pagalbos arba jei galite suteikti pagalbą žymėti sritis kuriose galite pagelbėti./Ви можете попросити і попросити про допомогу або, якщо ви можете надати допомогу, позначити місця, де ви можете допомогти."
    keyboard = [["Klausti/Спитати/Спросить", "trequest()", "Žymėti/Позначте/Отметить", "tenter()"]]
    sendMessage(tg, chat_id = av["id"], text = msg, reply_markup = tik(keyboard))

    return
end

function welcometext()
    txt="""Ši priemonė skirta padėti suvesti klausiantįjį su žinančiu. Svarbus aspektas šios priemonės surinkti ir suskirstyti mūsų žinias ir gebėjimus, todėl kai suformuluosite klausimą, tą klausimą reiks priskirti sričiai iš sričių medžio tam, kad klausimas nukeliautų pas išmanantį žmogų. Kai norėsite prisidėti sprendžiant kitų klausimus, taip pat reikės pasirinkti sritis, kur jūs turite išmanymą./
            Цей інструмент покликаний допомогти об’єднати запитувача та обізнаних. Важливим аспектом цього інструменту є збір і обмін нашими знаннями та навичками, тому, як тільки ви сформулюєте питання, це питання потрібно буде призначити до області з дерева областей, щоб питання було передано обізнаній людині. Якщо ви хочете внести свій внесок у вирішення проблем інших людей, вам також потрібно буде вибрати сфери, де ви маєте досвід./
            Этот инструмент предназначен для того, чтобы помочь исследователю объединиться со знающим. Важным аспектом этого инструмента является сбор и обмен нашими знаниями и навыками, поэтому, как только вы сформулируете вопрос, этот вопрос необходимо будет назначить области из дерева областей, чтобы вопрос попал к знающему человеку. Если вы хотите помоч решить проблемы других людей, вам также нужно будет выбрать области, в которых у вас есть опыт."""
end

# functions below will not be used for a now
function registerinvitecode()
    id=tryparse(Int, av["txt"])
    if id !== nothing && any(keys(Av).==id)
        Av[id]["token"]+=2
        msg="Jūsų pakviestas dalyvis sėkmingai užsiregistravo! O jums prisidėjo du taškai. Bendras taškų skaičius $(Av[id]["token"])"
        sendMessage(chat_id = id,text = msg)
        #av["tonken"]+=2
        msg="Pakvietimo kodas priimtas"
        sendMessage(chat_id = av["id"],text = msg)
        tbegin()
    else
        msg="Kažkas negerai su kodu, bandykite dar kartą arba tęskite paspaudę komandą /namo."
        sendMessage(chat_id = av["id"],text = msg)
    end
end

function invite() # this is not used now
    msg="Nusiūskite žmogui nuorodą bei kodą (jei reikia, pirmiausia pakviestkite į Telegram platformą)."
    sendMessage(chat_id = av["id"],text = msg)
    msg="Prisijunkite į Talką @talkon_bot, pakvietimo kodas:."
    sendMessage(chat_id = av["id"],text = msg)
    sendMessage(chat_id = av["id"],text = "$(av["id"])")
end

function invitecodeyesno(t) # this is not needed now
    if t==0
        tbegin()
        return
    end
    sendMessage(chat_id = av["id"], text = "Įveskite kodą")
    av["step"]="wait_for_invite_code"
end
