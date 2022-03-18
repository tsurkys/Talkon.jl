function valuableyesno(yn)
    K[av["requestid"]]["valuableyesno"]=yn
    if yn==1
        sendInvoice(chat_id = av["id"],title="Talka",description="Prisidėk prie platformos kūrimo!",payload="payloadas",
            provider_token="350862534:LIVE:OGYyOWZlM2Q1Y2Zi",currency="EUR",prices=[Dict("label"=>"kaina","amount"=>100)],
            suggested_tip_amounts=[100,200,300],max_tip_amount=500)
    end
    tbegin()
end