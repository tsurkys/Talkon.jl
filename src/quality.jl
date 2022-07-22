function valuableyesno(d, mb, yn)
    @unpack keises = d
    keises[mb["requestid"]]["valuableyesno"] = yn
    if yn == "yes"
        # sendInvoice(chat_id = mb["id"],
        #             title = "Talka",
        #             description = "Prisidėk prie platformos kūrimo!",
        #             payload = "payloadas",
        #             provider_token = "350862534:LIVE:OGYyOWZlM2Q1Y2Zi"
        #             #provider_token = ENV["TALKON_PROVIDE R_TOKEN"],
        #             currency = "EUR",
        #             prices = [Dict("label"=>"kaina","amount"=>100)],
        #     suggested_tip_amounts = [100,200,300], max_tip_amount=500)
        #sendMessage(tg, chat_id = mb["id"], text = dln["quality_yes"][mb["ln"]])
    end
    tbegin(mb)
end
