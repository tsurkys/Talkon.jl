using Telegram, Telegram.API
k=[1,2]
function kvaku(mm)
    m=Meta.parse(mm)
    eval(m)
    print(nd*10)
    #print(k)

end

function kita()
    
token="5228841059:AAHWYzBFbqM4TFYgURvmNRqc25dDywOlLJA" #talkon
tg=TelegramClient(token)
id=5001426828 #tadas, 5090964479 talkinininkas
chat_id=-1001736465998 #talkos grupė 3
# msg="_"
#ms=sendMessage(chat_id = chat_id, text = "msg") 
ms=getUpdates(tg)
#banChatMember(chat_id=chat_id,user_id=id,revoke_messages=true)
# groups=Dict(-1001736465998 => Dict("link"=>"https://t.me/+w9Rv7qTX9jw3N2E8", "state"=>"free")) # grupė 3
# groups[-1001751032068]=Dict("link"=>"https://t.me/+TW6nKtFlNmUzYWZk", "state"=>"free") # grupė 2
# groups[-1001592963230]=Dict("link"=>"https://t.me/+AB2HqKYZPhM4MTY0", "state"=>"free") # grupė 1
# promoteChatMember(chat_id=chat_id,user_id=id,can_manage_voice_chats=true)
ms
end
jldsave("example.jld2"; T,Av,updateId,K,groups)