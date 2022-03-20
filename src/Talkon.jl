module Talkon

using Telegram
using Telegram.API
using Serialization
using UnPack
using Dates

include("database.jl")
include("begin.jl")
include("request.jl")
include("enter.jl")
include("quality.jl")
include("suportive.jl")

export talka, initialize

const DATAFILE = Ref("")

function initialize(datafile = "varTEST.data")
    DATAFILE[] = datafile
    (T, Av, updateId, K, groups) = deserialize(datafile)

    return DataBase(T, Av, updateId, K, groups)
end

function talka(d::DataBase)
    update_id = d.update_id
    tg = TelegramClient()
    av = nothing
    for i in 1:250
        update_id, av = dothing(d, tg, update_id, av)
        d.update_id = update_id
        if round(i/20)-i/20 == 0
            av = chekeis(d, tg, av)
        end
    end
end # end of talka function

function switcher(d, tg, av, inp)
    if inp == "tenter()"
        tenter(d, tg, av)
    elseif inp == "trequest()"
        trequest(d, tg, av)
    elseif inp == "valuableyesno(0)"
        valuableyesno(d, tg, av, 0)
    elseif inp == "valuableyesno(1)"
        valuableyesno(d, tg, av, 1)
    elseif inp == "invitecodeyesno(0)"
        invitecodeyesno(0)
    elseif inp == "invitecodeyesno(1)"  
        invitecodeyesno(1)   
    elseif inp == "closekeis()"
        av = closekeis(d, tg, av, av["requestid"])
    elseif inp == ""
    else
        println("netinkama komanda!")
    end

    return av
end

function dothing(d::DataBase, tg, update_id, av)
    @unpack T, Av, K, groups = d
    mst = try
        getUpdates(tg, offset = update_id + 1, allowed_updates = ["message", "callback_query"])
    catch
        @warn "getUpdates doesnt work may be no connection?!"
        sleep(2)
        return update_id, av
    end
    if length(mst) > 1
        print("length of the message $(length(mst))")
    elseif length(mst) == 0
        sleep(1)
        return update_id, av
    end
    update_id = mst[end]["update_id"]
    for ms in mst
        if haskey(ms, "callback_query") #messages that have callback string
            id = ms["callback_query"]["from"]["id"]
            av = Av[id]
            av["txt"] = "nothingness"
            av = switcher(d, tg, av, ms[:callback_query][:data])
            #eval(Meta.parse(ms[:callback_query][:data]))
            chat_id = ms["callback_query"]["message"]["chat"]["id"]
            try
                deleteMessage(chat_id = chat_id, message_id = ms["callback_query"]["message"]["message_id"])
            catch
            end
            continue
        elseif haskey(ms["message"], "new_chat_member")
            if ms["message"]["chat"]["id"] == -1001547960563 #message from main group
                if !haskey(Av, ms["message"]["new_chat_member"]["id"])#new member entered main group 
                    av = newav(d, tg, av, ms) # register and wellcome message for a new member
                end
                continue
            end
            promoteChatMember(chat_id = ms["message"]["chat"]["id"], #new member entered the temporary group
                                user_id = ms["message"]["new_chat_member"]["id"], can_manage_voice_chats = true)
            continue
        elseif !haskey(ms["message"],"text")
            println("unknown type of message")
            continue
        end
        if !haskey(Av, ms["message"]["from"]["id"]) #new member called bot 
            av = newav(d, tg, av, ms)
            continue
        end
        av = Av[ms["message"]["from"]["id"]]
        ReplyKeyboardRemove = Dict(:remove_keyboard => true)
        sentms = sendMessage(chat_id = av["id"], text = "entered", reply_markup = ReplyKeyboardRemove)  # sendMessage always require text message,
        deleteMessage(chat_id = av["id"],message_id = sentms["message_id"]) # in this case it has to be deleted
        if ms["message"]["text"][end] == '✓' # curently tree is represented not with inline keyboard, thus the text message arrives
            av["txt"] = ms["message"]["text"][1:end-1]
        else
            av["txt"] = ms["message"]["text"]
        end
        if lowercase(av["txt"]) == "home" || av["txt"] == "/start" || av["txt"] == "/namo"
            tbegin(tg, av)
        #elseif av["txt"] == "/pakviesti" #invite new member, perhaps to help refugees it is not very usefull
        #    invite()
        #elseif av["txt"] == "/taskai"
        #    taskai()
        #elseif av["step"] == "wait_for_invite_code"
        #    registerinvitecode()
        elseif av["step"] == "request"
            trequest(d, tg, av)
        elseif av["step"] == "enter"
            tenter(d, tg, av)
        elseif av["step"] == "requested" || av["step"] == "accepted"
            dealkeis(d, tg, av)
        end
    end # end of for ms
    serialize(DATAFILE[], [T,Av,update_id,K,groups])
    return update_id, av
end # end of dothing function

end # module
