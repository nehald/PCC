# WS client example
import pdb
import asyncio
import websockets
import json
import pcc_api 



def get_topics():
    pdb.set_trace()
    user_cookie = pcc_api.sign_in("nehalnehal@aero.org", "foobar")
    topics = pcc_api.list_topics(user_cookie)
    return topics 


async def hello():
    uri = "ws://localhost:4000/socket/websocket"
    async with websockets.connect(uri) as websocket:
        join={"topic": "user:nehal.desaix@aero.org:topic", "ref": "ab", "payload": {"foo":"bar"}, "event": "phx_join"}
        #join={"topic": "topic:missileroom", "ref": "ab", "payload": {}, "event": "phx_join"}
        join_str = json.dumps(join) 
        await websocket.send(join_str)
        greeting = await websocket.recv()
        print(f"< {greeting}")
        async for message in websocket:
            print(message)

print(get_topics())
#asyncio.get_event_loop().run_until_complete(hello())
