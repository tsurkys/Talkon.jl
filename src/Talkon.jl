module Talkon

using Telegram
using Telegram.API
using Serialization
using UnPack
using Dates
using Random

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
    (T, Av, update_id, K, groups) = deserialize(datafile)
    #delete!(Av,5001426828) # Tadas
    #delete!(Av,1288201725) # Vidas
    #delete!(Av,105485706) # Andrey
    #delete!(Av,5090964479) # Talkininkas
    return DataBase(T, Av, update_id, K, groups)
end

function talka(d::DataBase)
    tg=TelegramClient("5228841059:AAHWYzBFbqM4TFYgURvmNRqc25dDywOlLJA")
    update_id = d.update_id
    av = nothing
    tg = TelegramClient()
    cnt = 0
    while true
        cnt += 1
        update_id, av = dothing(d, tg, update_id, av)
        d.update_id = update_id
        if cnt == 20
            av = chekeis(d, tg, av)
            cnt = 0
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
        println("bad command!")
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
            #if ms["message"]["chat"]["id"] ==-1001715161879# development group. https://t.me/talkon_development
            if ms["message"]["chat"]["id"] == -1001547960563 #message from main test group https://t.me/talka_ukrainai
                if !haskey(Av, ms["message"]["new_chat_member"]["id"]) # new member entered main group 
                    try
                    av = newav(d, tg, av, ms) # register and wellcome message for a new member
                    catch
                        println("unsuccesfull registration upon entering main group")
                    end
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
        av["txt"]=replace(ms["message"]["text"],"✓"=>"") # curently tree is represented not with inline keyboard, thus the text message arrives
        if lowercase(av["txt"]) == "namo | додому" || av["txt"] == "/start" || av["txt"] == "/namo"
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
