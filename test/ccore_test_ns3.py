"""
    test for PCC apis
"""
import pdb
import requests
URL = "http://localhost:4000/api/"
headers = {"Content-Type": "application/json"}


def response_to_str(val):
    rdict = json.loads(val.decode('utf-8'))
    rdict = val.decode('utf-8')
    return rdict


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

        response = response_to_str(response)
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

        response = response_to_str(response)
        return response
    except:
        return {"Error": "info"}


def spawn_groundstation(cookie_jar, name, loc=[0, 0]):
    """
      start a groundstation
    """
    url_spawn = URL + "spawn"
    spawn_data = {"name": name, "loc": loc, "proc_type": "groundstation"}
    try:
        response = requests.post(url_spawn,
                                 headers=headers,
                                 json=spawn_data,
                                 cookies=cookie_jar)

        response = response_to_str(response)
        return response
    except requests.exceptions.RequestException as e_e:
        return {"Error": e_e}


def gs_connect(cookie_jar, groundstation=None, sat=None):
    """
     connect a ground station to a satellite
    """

    url_connect = URL + "gs/connect"
    if groundstation is None or sat is None:
        return {"Error": "groundstation or sat not specified"}

    # connection
    connect_data = {"gs": groundstation, "sat": sat}
    try:
        response = requests.post(url_connect,
                                 headers=headers,
                                 json=connect_data,
                                 cookies=cookie_jar)

        response = response_to_str(response)
        return response
    except requests.exceptions.RequestException as e_e:
        return {"Error": e_e}


def gs_connection_info(cookie_jar, groundstation=None):
    """ What connection does this gs have"""
    url_gs = URL + "gs/info"
    if groundstation is None:
        return {"Error": "groundstation or sat not specified"}

    info = {"gs": groundstation}
    try:
        response = requests.post(url_gs,
                                 headers=headers,
                                 json=info,
                                 cookies=cookie_jar,
                                 timeout=None)

        response = response_to_str(response)
        return response
    except requests.exceptions.RequestException as e_e:
        return {"Error": e_e}


def gs_sat_info(cookie_jar, groundstation=None):
    url_gs = URL + "gs/info/sat"
    if groundstation is None:
        return {"Error": "groundstation or sat not specified"}

    info = {"gs": groundstation}
    try:
        response = requests.post(url_gs,
                                 headers=headers,
                                 json=info,
                                 cookies=cookie_jar,
                                 timeout=None)

        response = response_to_str(response)
        return response
    except requests.exceptions.RequestException as e_e:
        return {"Error": e_e}


def sat_info(cookie_jar, sat_handle):
    url_sat = URL + "sat"
    info = {"sat": sat_handle}
    try:
        response = requests.post(url_sat,
                                 headers=headers,
                                 json=info,
                                 cookies=cookie_jar,
                                 timeout=None)

        response = response_to_str(response)
        return response
    except requests.exceptions.RequestException as e_e:
        return {"Error": e_e}


if __name__ == '__main__':
    user_cookie = sign_in("nehal.desaix@aero.org", "foobar")
    spawn_handle_45555 = spawn_proc(user_cookie, "generic", "45555", [], 0)
    spawn_handle_45394 = spawn_proc(user_cookie, "generic", "45394", [], 0)


    gs_handle = spawn_groundstation(user_cookie, "gs2", loc=[1, 1])
    gs_connect(user_cookie, "gs2", "45555")
    gs_connect(user_cookie, "gs2", "45394")
    gs_connect_response = gs_connection_info(user_cookie, "gs2")
    #response = gs_sat_info(user_cookie, "gs2")
