module Talkon

using Telegram, Telegram.API
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
const DLN = deserialize("dictionary.data")
const tg = TelegramClient()

#=
tree - question area tree
mbs - members
    mb - member
update_id - telegram update_id
keises - requests cases
    keis - request case
groups - temporary groups
dln - dictionary of languages texts
=#

function initialize(datafile = "data/varTEST.data")
    DATAFILE[] = datafile
    (tree, mbs, update_id, keises, groups, dln) = deserialize(datafile)
    return DataBase(tree, mbs, update_id, keises, groups, dln)
end

# let mb = nothing
#     global  getmb(xmb = mb) = (mb = xmb)
# end

function talka(d::DataBase)
    update_id = d.update_id
    cnt = 0
   # try
        while true
            cnt += 1
            update_id = dothing(d, update_id)
            d.update_id = update_id
            if cnt == 5
                chekeis(d)
                cnt = 0
            end
        end
   # catch e
   #     sendMessage(chat_id = -729825915, text = "Talkon stoped") # message to Talkon news group
    #    return e
    #end
end

function dothing(d::DataBase, update_id)
    @unpack tree, mbs, keises, groups, dln = d
    msgs = try
        msgs=getUpdates(offset = update_id + 1, allowed_updates = ["message", "callback_query"])
    catch
        @warn "getUpdates doesn't work, may be no connection?!"
        sleep(2)
        return update_id
    end
    if length(msgs) > 1
        print("length of the message $(length(msgs))")
    elseif length(msgs) == 0
        sleep(0.7)
        return update_id
    end
    update_id = msgs[end]["update_id"]
    for msg in msgs
        if haskey(msg, "callback_query") # messages that have callback string
            mb = mbs[msg["callback_query"]["from"]["id"]]
            mb["txt"] = "nothingness"
            chat_id = msg["callback_query"]["message"]["chat"]["id"] # chat_id is different for groups
            push!(mb["msgtodelete"], msg["callback_query"]["message"]["message_id"])
            for msgtodelete in mb["msgtodelete"]
                try
                    deleteMessage(chat_id = chat_id, message_id = msgtodelete)
                catch
                end
            end
            mb["msgtodelete"]=[]
            switcher(d, mb, msg[:callback_query][:data])
            continue
        elseif haskey(msg["message"], "new_chat_member") # new member entered the temporary group, additional check for if it our group needed
            promoteChatMember(chat_id = msg["message"]["chat"]["id"], 
                                user_id = msg["message"]["new_chat_member"]["id"], can_manage_voice_chats = true)
                continue
        elseif !haskey(msg["message"],"text")
            println("unknown type of message")
            continue
        end
        id = msg["message"]["from"]["id"]
        if !haskey(mbs, id) #new member addresed bot 
            newmb(d, msg)
            continue
        end
        mb = mbs[id]
        ReplyKeyboardRemove = Dict(:remove_keyboard => true)
        sentms = sendMessage(chat_id = mb["id"], text = "entered", reply_markup = ReplyKeyboardRemove)  # sendMessage always require text message,
        deleteMessage(chat_id = mb["id"],message_id = sentms["message_id"]) # in this case it has to be deleted
        mb["txt"]=msg["message"]["text"]
        if any(lowercase(mb["txt"]).==["/home", "/start", "/namo"])
            tbegin(mb)
        elseif mb["txt"] == "/invite" 
            invite(mb)
        elseif mb["txt"] == "/tokens"
            get_tokens(mb)
        elseif mb["txt"] == "/talkon_language"
            talkon_language(d, mb, "")
        elseif mb["txt"] == "/spoken_languages"
            spoken_languages(mb, "")
        elseif any(["/accept", "/decline",	"/priimti", "/atmesti", "/прийняти", "/відхилити"] .== mb["txt"])
            disclaimer(d, mb, mb["txt"])
        elseif mb["step"] == "wait_for_invite_code"
            registerinvitecode(d, mb, mb["txt"])
        elseif mb["step"] == "request"
            trequest(d, mb)
        #elseif mb["step"] == "enter"
        #    tenter(d, mb)
        elseif mb["step"] == "requested" || mb["step"] == "accepted"
            #dealkeis(d, mb)
        end
    end # end of for msg
    serialize(DATAFILE[], [tree, mbs, update_id, keises, groups, dln])
    return update_id
end # end of dothing function

function switcher(d, mb, input)
    input=split(input,",")
    fun=input[1]
    var=""
    if length(input)>1
        var=input[2]
    end
    if fun == "talkon_language"
        talkon_language(mb, var)
    elseif fun == "spoken_languages"
        spoken_languages(mb, var)
    elseif fun == "registerinvitecode()"
        registerinvitecode(d, mb, var)
    elseif fun == "tbegin()"
        tbegin(mb)
    elseif fun == "tenter()"
        tenter(d, mb, var)
    elseif fun == "trequest()"
        trequest(d, mb)
    elseif fun == "traversetree()"
        traversetree(d, mb, var)
    elseif fun == "dealkeis()"
        dealkeis(d, mb, var)
    elseif fun == "tree_uncheck()"    
        tree_uncheck(d, mb, pathkey)
    elseif fun == "propagate()"
        propagate(d, mb) 
    elseif fun == "valuableyesno()"
        valuableyesno(d, mb, var)
    elseif fun == "closekeis()"
        closekeis(d, mb["requestid"])
    elseif fun == ""
    else
        println("unrecognized callback " * fun)
    end
end

end # module