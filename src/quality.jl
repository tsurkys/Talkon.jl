function valuableyesno(d, tg, av, yn)
    @unpack K = d
    K[av["requestid"]]["valuableyesno"] = yn
    if yn == 1
        # sendInvoice(chat_id = av["id"],
        #             title = "Talka",
        #             description = "Prisidėk prie platformos kūrimo!",
        #             payload = "payloadas",
        #             provider_token = ENV["TALKON_PROVIDER_TOKEN"],
        #             currency = "EUR",
        #             prices = [Dict("label"=>"kaina","amount"=>100)],
        #     suggested_tip_amounts = [100,200,300], max_tip_amount=500)
        msg = "Ми раді! | Džiaugiamės!"
        sendMessage(tg, chat_id = av["id"], text = msg)
    end
    tbegin(tg, av)
end
