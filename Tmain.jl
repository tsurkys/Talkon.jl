using Telegram, Telegram.API, Serialization, Dates, Revise
include("Tbegin.jl");include("Trequest.jl");include("Tenter.jl");include("Tquality.jl");include("Tsuportive.jl");
# T tree of problem areas
# K Request case registry
# Av registry of members
# States of member:
# wait_for_invite_code
# 00
# 0
# enter
# request
# requested
# accepted
datafile="varTEST.jl"
#datafile="ss1.jl"
(T,Av,updateId,K,groups)=deserialize(datafile)
#delete!(Av,5001426828) Tadas
#delete!(Av,5090964479)# Vecmaminia
updateId=1
function talka(updateId)
token="5228841059:AAHWYzBFbqM4TFYgURvmNRqc25dDywOlLJA" #talkon
tg=TelegramClient(token)
function dothing(updateId)
global av
mst=try
    getUpdates(tg,offset=updateId+1,allowed_updates=["message","callback_query"])
catch
    @warn "getUpdates neveikia, gal nėra interneto?!"
    sleep(2)
    return
end
if length(mst)>1
    print("ilgis žinutės $(length(mst))")
elseif length(mst) == 0
    sleep(1)
    return updateId
end
updateId=mst[end]["update_id"]
for ms in mst
    if haskey(ms,"callback_query")
        id=ms["callback_query"]["from"]["id"]
        av=Av[id]
        av["txt"]="niekaliauskas"
        switcher(ms[:callback_query][:data])
        #eval(Meta.parse(ms[:callback_query][:data]))
        chat_id=ms["callback_query"]["message"]["chat"]["id"]
        try
            deleteMessage(chat_id=chat_id,message_id=ms["callback_query"]["message"]["message_id"])
        catch
        end
        continue
    elseif haskey(ms["message"],"new_chat_member")
        if ms["message"]["chat"]["id"]==-1001547960563 #new main group member
            if !haskey(Av,ms["message"]["new_chat_member"]["id"])
                newav(ms)
            end
            continue
        end
        promoteChatMember(chat_id=ms["message"]["chat"]["id"], #new member in temporary group
            user_id=ms["message"]["new_chat_member"]["id"],can_manage_voice_chats=true)
            continue
    elseif !haskey(ms["message"],"text")
        println("nestandartinė žinutė")
        continue
    end
    if !haskey(Av,ms["message"]["from"]["id"])
        newav(ms)
        continue
    end
    av=Av[ms["message"]["from"]["id"]]
    ReplyKeyboardRemove=Dict(:remove_keyboard=>true)
    sentms=sendMessage(chat_id = av["id"], text = "įvesta", reply_markup = ReplyKeyboardRemove)   
    deleteMessage(chat_id=av["id"],message_id=sentms["message_id"])
    if ms["message"]["text"][end] == '✓'
        av["txt"] = ms["message"]["text"][1:end-1]
    else
        av["txt"] = ms["message"]["text"]
    end
    if lowercase(av["txt"]) == "namo" || av["txt"] == "/start" || av["txt"] == "/namo"
        tbegin()
    elseif av["txt"]=="/pakviesti"
        invite()
    elseif av["txt"]=="/taskai"
        taskai()
    elseif av["step"]=="wait_for_invite_code"
        registerinvitecode()
    elseif av["step"] == "request"
        trequest()
    elseif av["step"] == "enter"
        tenter()
    elseif av["step"] == "requested" || av["step"] == "accepted"
        dealkeis(Av,av,K)
    end
end # end of for ms
serialize(datafile,[T,Av,updateId,K,groups])
return updateId
end # end of dothing function
for i in 1:250
    updateId=dothing(updateId)
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
talka(updateId)