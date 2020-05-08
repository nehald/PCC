"""
   Hello
"""

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


def spawn(proc_type, name, extra_channels, visible, cookiejar):
    """Spawn a process
    Arguments:
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
                                 cookies=cookiejar)
        return response
    except requests.exceptions.RequestException as e_e:
        return {"Error": e_e}


def connect_procs(proc_a, proc_b):
    """ Connect two procs"""
    return "Foo"


#cookie = auth("nehal.desaix@aero.org", "foobar")
# spawn(cookie)
#
# print(cookie)
# missile_spawn()
# sat_spawn()
