function valuableyesno(d, tg, mb, yn)
    @unpack keises = d
    keises[mb["requestid"]]["valuableyesno"] = yn
    if yn == 1
        # sendInvoice(chat_id = mb["id"],
        #             title = "Talka",
        #             description = "Prisidėk prie platformos kūrimo!",
        #             payload = "payloadas",
        #             provider_token = ENV["TALKON_PROVIDER_TOKEN"],
        #             currency = "EUR",
        #             prices = [Dict("label"=>"kaina","amount"=>100)],
        #     suggested_tip_amounts = [100,200,300], max_tip_amount=500)
        msg = "Ми раді! | Džiaugiamės!"
        sendMessage(tg, chat_id = mb["id"], text = msg)
    end
    tbegin(tg, mb)
end
