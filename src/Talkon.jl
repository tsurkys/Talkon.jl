module Talkon

using Telegram
using Telegram.API
using Serialization
using Dates

include("begin.jl")
include("request.jl")
include("enter.jl")
include("quality.jl")
include("suportive.jl")

export talka, initialize

const DATAFILE = Ref("")

function initialize(datafile = "varTEST.data")
    DATAFILE[] = datafile
    global T, Av, updateId, K, groups
    #datafile="ss1.jl"
    (T,Av,updateId,K,groups)=deserialize(datafile)
    #delete!(Av,5001426828) Tadas
    #delete!(Av,5090964479)# Vecmaminia
end

function talka(updateId)
    tg=TelegramClient()
    for i in 1:250
        updateId=dothing(tg, updateId)
        if round(i/20)-i/20==0
            chekeis() 
        end
    end
end # end of talka function

function switcher(inp)
    if inp=="tenter()"
        tenter()
    elseif inp=="trequest()"
        trequest()
    elseif inp=="valuableyesno(0)"
        valuableyesno(0)
    elseif inp=="valuableyesno(1)"
        valuableyesno(1)
    elseif inp=="invitecodeyesno(0)"
        invitecodeyesno(0)
    elseif inp=="invitecodeyesno(1)"  
        invitecodeyesno(1)   
    elseif inp=="closekeis()"
        closekeis(av["requestid"])
    elseif inp==""
    else
        println("netinkama komanda!")
    end
end

function dothing(tg, updateId)
    global av
    mst=try
        getUpdates(tg,offset=updateId+1,allowed_updates=["message","callback_query"])
    catch
        @warn "getUpdates doesnt work may be no connection?!"
        sleep(2)
        return
    end
    if length(mst)>1
        print("length of the message $(length(mst))")
    elseif length(mst) == 0
        sleep(1)
        return updateId
    end
    updateId=mst[end]["update_id"]
    for ms in mst
        if haskey(ms,"callback_query") #messages that have callback string
            id=ms["callback_query"]["from"]["id"]
            av=Av[id]
            av["txt"]="nothingness"
            switcher(ms[:callback_query][:data])
            #eval(Meta.parse(ms[:callback_query][:data]))
            chat_id=ms["callback_query"]["message"]["chat"]["id"]
            try
                deleteMessage(chat_id=chat_id,message_id=ms["callback_query"]["message"]["message_id"])
            catch
            end
            continue
        elseif haskey(ms["message"],"new_chat_member")
            if ms["message"]["chat"]["id"]==-1001547960563 #message from main group
                if !haskey(Av,ms["message"]["new_chat_member"]["id"])#new member entered main group 
                    newav(ms) # register and wellcome message for a new member
                end
                continue
            end
            promoteChatMember(chat_id=ms["message"]["chat"]["id"], #new member entered the temporary group
                              user_id=ms["message"]["new_chat_member"]["id"],can_manage_voice_chats=true)
            continue
        elseif !haskey(ms["message"],"text")
            println("unknown type of message")
            continue
        end
        if !haskey(Av,ms["message"]["from"]["id"]) #new member called bot 
            newav(ms)
            continue
        end
        av=Av[ms["message"]["from"]["id"]]
        ReplyKeyboardRemove=Dict(:remove_keyboard=>true)
        sentms=sendMessage(chat_id = av["id"], text = "entered", reply_markup = ReplyKeyboardRemove)  # sendMessage always require text message,
        deleteMessage(chat_id=av["id"],message_id=sentms["message_id"]) # in this case it has to be deleted
        if ms["message"]["text"][end] == '✓' # curently tree is represented not with inline keyboard, thus the text message arrives
            av["txt"] = ms["message"]["text"][1:end-1]
        else
            av["txt"] = ms["message"]["text"]
        end
        if lowercase(av["txt"]) == "home" || av["txt"] == "/start" || av["txt"] == "/namo"
            tbegin()
        #elseif av["txt"]=="/pakviesti" #invite new member, perhaps to help refugees it is not very usefull
        #    invite()
        #elseif av["txt"]=="/taskai"
        #    taskai()
        #elseif av["step"]=="wait_for_invite_code"
        #    registerinvitecode()
        elseif av["step"] == "request"
            trequest()
        elseif av["step"] == "enter"
            tenter()
        elseif av["step"] == "requested" || av["step"] == "accepted"
            dealkeis(Av,av,K)
        end
    end # end of for ms
    serialize(DATAFILE[], [T,Av,updateId,K,groups])
    return updateId
end # end of dothing function

end # module
