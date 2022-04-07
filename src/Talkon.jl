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
    (tree, mbs, update_id, keises, groups) = deserialize(datafile)
    return DataBase(tree, mbs, update_id, keises, groups)
end
#=
tree - problem area tree
mbs - members
    mb - member
update_id - telegram update_id
keises - requests cases
    keis - request case
groups - temporary groups
=#

function talka(d::DataBase)
    update_id = d.update_id
    mb = nothing
    tg = TelegramClient()
    cnt = 0
    @info "Talkon bot started"
    while true
        cnt += 1
        update_id, mb = dothing(d, tg, update_id, mb)
        d.update_id = update_id
        if cnt == 20
            mb = chekeis(d, tg, mb)
            cnt = 0
        end
    end
end # end of talka function

function dothing(d::DataBase, tg, update_id, mb)
    @unpack tree, mbs, keises, groups = d
    mst = try
        mst=getUpdates(tg, offset = update_id + 1, allowed_updates = ["message", "callback_query"])
    catch
        @warn "getUpdates doesnt work may be no connection?!"
        sleep(2)
        return update_id, mb
    end
    if length(mst) > 1
        print("length of the message $(length(mst))")
    elseif length(mst) == 0
        sleep(1)
        return update_id, mb
    end
    update_id = mst[end]["update_id"]
    for ms in mst
        if haskey(ms, "callback_query") #messages that have callback string
            id = ms["callback_query"]["from"]["id"]
            mb = mbs[id]
            mb["txt"] = "nothingness"
            mb = switcher(d, tg, mb, ms[:callback_query][:data])
            chat_id = ms["callback_query"]["message"]["chat"]["id"]
            try
                deleteMessage(chat_id = chat_id, message_id = ms["callback_query"]["message"]["message_id"])
            catch
            end
            continue
        elseif haskey(ms["message"], "new_chat_member") # new member entered the temporary group, additional check for if it our group needed
            promoteChatMember(chat_id = ms["message"]["chat"]["id"], 
                                user_id = ms["message"]["new_chat_member"]["id"], can_manage_voice_chats = true)
                continue
        elseif !haskey(ms["message"],"text")
            println("unknown type of message")
            continue
        end
        if !haskey(mbs, ms["message"]["from"]["id"]) #new member addresed bot 
            mb = newav(d, tg, ms)
            continue
        end
        mb = mbs[ms["message"]["from"]["id"]]
        ReplyKeyboardRemove = Dict(:remove_keyboard => true)
        sentms = sendMessage(chat_id = mb["id"], text = "entered", reply_markup = ReplyKeyboardRemove)  # sendMessage always require text message,
        deleteMessage(chat_id = mb["id"],message_id = sentms["message_id"]) # in this case it has to be deleted
        mb["txt"]=replace(ms["message"]["text"],"✓"=>"") # curently tree is represented not with inline keyboard, thus the text message arrives
        if lowercase(mb["txt"]) == "namo | додому" || mb["txt"] == "/start" || mb["txt"] == "/namo"
            tbegin(tg, mb)
        #elseif mb["txt"] == "/pakviesti" #invite new member, perhaps to help refugees it is not very usefull
        #    invite()
        #elseif mb["txt"] == "/taskai"
        #    taskai()
        #elseif mb["step"] == "wait_for_invite_code"
        #    registerinvitecode()
        elseif mb["step"] == "request"
            trequest(d, tg, mb)
        elseif mb["step"] == "enter"
            tenter(d, tg, mb)
        elseif mb["step"] == "requested" || mb["step"] == "accepted"
            dealkeis(d, tg, mb)
        end
    end # end of for ms
    serialize(DATAFILE[], [tree,mbs,update_id,keises,groups])
    return update_id, mb
end # end of dothing function

function switcher(d, tg, mb, inp)
    if inp == "tenter()"
        tenter(d, tg, mb)
    elseif inp == "trequest()"
        trequest(d, tg, mb)
    elseif inp == "valuableyesno(0)"
        valuableyesno(d, tg, mb, 0)
    elseif inp == "valuableyesno(1)"
        valuableyesno(d, tg, mb, 1)
    elseif inp == "invitecodeyesno(0)"
        invitecodeyesno(0)
    elseif inp == "invitecodeyesno(1)"  
        invitecodeyesno(1)   
    elseif inp == "closekeis()"
        mb = closekeis(d, tg, mb, mb["requestid"])
    elseif inp == ""
    else
        println("bad command!")
    end

    return mb
end

end # module
