"""
    test for PCC apis
"""

import pdb
import requests

URL = "http://localhost:4000/api/"
headers = {"Content-Type": "application/json"}


def create_user(email, password):
    """
    curl -H "Content-Type: application/json" -X POST \
    -d '{"user":{"email":"some@email.com","password":"some password"}}' \
     http://localhost:4000/api/users
    """

    data = {"user": {"email": email, "password": password}}
    create_user_url = URL + "/users/create"
    response = requests.post(create_user_url, headers=headers, json=data)
    return response


def sign_in(email, password):
    """ Sign in user
    Arguments:
        email -- account name
        password` - password
    Return:
       Session cookie
    """
    data = {"email": email, "password": password}
    sign_in_url = URL + "users/sign_in"
    try:
        response = requests.post(sign_in_url, headers=headers, json=data)
    except:
        return {"Error": "error"}
    cookiejar = response.cookies
    return cookiejar


def spawn_proc(cookie_jar, proc_type, name, extra_channels, visible):
    """Spawn a process
    Arguments:
       cookiejar  - user session id
       proc_type - type of process to start
       name - name of the process
       extra_channels - additional channels to route process data
       visible - nothing
       cookiejar  - session id
    """
    url_spawn = URL + "spawn"
    spawn_data = {
        "proc_type": proc_type,
        "name": name,
        "extra_channels": extra_channels,
        "visible": visible
    }
    try:
        response = requests.post(url_spawn,
                                 headers=headers,
                                 json=spawn_data,
                                 cookies=cookie_jar)
        return response
    except requests.exceptions.RequestException as e_e:
        return {"Error": e_e}


def graph_info(cookiejar):
    """ Get the user graph
       cookiejar  - session id
    """
    url_graph = URL + "graph"
    info_data = {"info": "graph"}
    try:
        response = requests.post(url_graph,
                                 headers=headers,
                                 json=info_data,
                                 cookie=cookiejar)
        return response
    except:
        return {"Error": "info"}


user_cookie = sign_in("nehal.desaix@aero.org", "foobar")
print(user_cookie)
spawn_handle = spawn_proc(user_cookie, "generic", "generic3", [], 0)
#r = graph_info(user_cookie)
# spawn(cookie)
#
# print(cookie)
# missile_spawn()
# sat_spawn()
