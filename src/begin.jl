function newav(ms)
    global av
    fromId=ms["message"]["from"]["id"]
    Av[fromId]=Dict("first_name"=>ms["message"]["from"]["first_name"],
                    "token"=>4,"step"=>"00","id"=>fromId)
    if haskey(ms["message"]["from"],"last_name")
        Av[fromId]["last_name"]=ms["message"]["from"]["last_name"]
    end
    av=Av[fromId]
    for pathkey in keys(T)
        push!(T[pathkey]["dav_id"],av["id"])
    end
    println(string("Užsiregistravo avėjas: ", av["first_name"]))
    msg=string("Sveiki, ",kas2nkas(av["first_name"]),"! Aš esu robotukas Talka. Mano esmė - kaip taksi išsikviesti (arba suteikti) pagalbą.")
    sendMessage(chat_id = fromId,text = msg)
    sendMessage(chat_id = fromId,text = welcometext())
    keyboard=[["Taip","invitecodeyesno(1)","Ne","invitecodeyesno(0)"]]
    sendMessage(chat_id = fromId,text = "Ar turite pakvietimo kodą?",reply_markup = tik(keyboard))
end

function tbegin()
    av["step"]="0"
    av["path"]=["0"]
    keyboard=[["Klausti","trequest()","Žymėti","tenter()"]]
    msg="Galite klausti bendruomenės klausimą arba žymėti sritis kuriose turite išmanymą."
    sendMessage(chat_id = av["id"], text = msg, reply_markup = tik(keyboard))
end

function invite()
    msg="Nusiūskite žmogui nuorodą bei kodą (jei reikia, pirmiausia pakviestkite į Telegram platformą)."
    sendMessage(chat_id = av["id"],text = msg)
    msg="Prisijunkite į Talką @talkon_bot, pakvietimo kodas:."
    sendMessage(chat_id = av["id"],text = msg)
    sendMessage(chat_id = av["id"],text = "$(av["id"])")
end

function welcometext()
    txt="""Kol dirbtinis intelektas mokosi žmogiškai kalbėti, geriausias būdas surasti atsakymus - pokalbis su gyvu žmogumi. Ši priemonė skirta padėti suvesti klausiantįjį su žinančiu. Svarbus aspektas šios priemonės surinkti ir suskirstyti mūsų žinias ir gebėjimus, todėl kai suformuluosite klausimą, tą klausimą reiks priskirti sričiai iš sričių medžio tam, kad klausimas nukeliautų pas išmanantį žmogų. Kai norėsite prisidėti sprendžiant kitų klausimus, taip pat reikės pasirinkti sritis, kur jūs turite išmanymą. Jei vaikščiojimas po sričių medį pasirodys nepatrauklus, yra alternatyva - išsikviesti nedidelę paslaugėlę ir paprašyti parinkt tinkamą sritį. Galite nuo to ir pradėti.
    Kai prisijungsite prie Talkos jūsų piniginėje bus keturi taškai. Kiekvieną kartą kai kviesite pagalbą  jūs talkininkams sumokėsite tašką. O kai jūs dalyvausite kito talkoje, jūs irgi gausite dalį to taško. Beje, visose talkose dalyvaus "Talkininkas" kurio užduotis kurti ir prižiūrėti šią priemonę, jis irgi gaus dalį taško. 
    Jei netyčia nežinojote, tai robotukas Talka, dar labai labai jaunas, todėl prašom būt atlaidiems. Nuo mūsų visų priklausys ar jis gyvuos ir koks jis užaugs!"""
end

function invitecodeyesno(t)
    if t==0
        tbegin()
        return
    end
    sendMessage(chat_id = av["id"], text = "Įveskite kodą")
    av["step"]="wait_for_invite_code"
end

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
