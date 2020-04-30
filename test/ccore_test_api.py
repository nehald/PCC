import requests 
import pdb
import random
import string 
import sys
url = "http://zonkatronic.com:4000/api/"
url = "http://localhost:4000/api/"
headers = {"Content-Type":"application/json"}


def create_user(email,password):
   
    """
    curl -H "Content-Type: application/json" -X POST \
    -d '{"user":{"email":"some@email.com","password":"some password"}}' \
     http://localhost:4000/api/users
    """
   
    data={"user":{"email":email,"password":password}} 
    create_user_url = url+"/users/create"
    response = requests.post(create_user_url,headers=headers,json=data)
    return response

def auth(email,password):
    data = {"email":email,"password":password}
    sign_in_url=url+"users/sign_in"
    response = requests.post(sign_in_url,headers=headers,json=data)
    cookiejar = response.cookies
    return cookiejar

def sat_spawn(name,cookiejar):
    url_spawn = url + "spawn"
    spawn_data = {"name": name,"extra_channels":["topic:missileroom"],"visible":0}
    response = requests.post(url_spawn, headers=headers,json=spawn_data,cookies=cookiejar)
    print(response)

def get_graph(name,cookiejar):
    url_spawn = url + "spawn"
   


def missile_spawn():
    url = "http://localhost:4000/api/"
    missile_spawn = url + "missile"
    url_data = {"missile_name": "m1", "cmd": "launch"}
    response = r.post(missile_spawn, data=url_data)
    print(response.content)
    for i in range(0, 100):
        pdb.set_trace()
        url_data = {"missile_name": "m1",
                    "cmd": "add_position", "position": str(i)}
        response = r.post(missile_spawn, data=url_data)
        print(response.content)

#letter = random.choice(string.ascii_lowercase)
#letter2 = random.choice(string.ascii_lowercase)
#user = "xx"+letter+letter2
#user = "nehal.desaix@gmail.com"
#response = create_user("nehal.desaix@aero.org","foobar") 
pdb.set_trace()
#cookie = auth(user,"foobar") 
#print(response) 
cookie = auth("nehal.desaix@aero.org","foobar")
pdb.set_trace()
name="GOES 15"
#for name in ['GOES 15', 'GOES 13', 'ASIASAT 9','41937','39120']:
sat_spawn(name,cookie)
#
#print(cookie)
#missile_spawn()
#sat_spawn()
