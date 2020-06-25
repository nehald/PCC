"""
    test for PCC apis
"""
import json
import pdb
import requests
import requests.exceptions as E
URL = "http://localhost:4000/api/"
headers = {"Content-Type": "application/json"}

response_ = {
    "join_group": lambda x: x,
    "spawn": lambda x: x,
    "gs_to_sat": lambda x: x,
    "gs_info": lambda x: x
}


def response_to_str(val):
    print(val)
    if isinstance(val, requests.Response):
        response_json = val.json()
        print(response_json)
        cmd = response_json['cmd']
        response_func = response_[cmd]
        response_return = response_func(response_json)
        return response_return
    else:
        rdict = val.decode('utf-8')
    return rdict


# create_user
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


# sign_in
def sign_in(email, password):
    """ Sign in user
      curl -H "Content-Type: application/json" -X POST \
       -d '{"user":{"email":"some@email.com","password":"some password"}}' \
        http://localhost:4000/api/users/sign_i

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


# spawn_proc
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
    except E.RequestException as e_e:
        return {"Error": e_e}


# graph_info
def graph_info(cookiejar):
    """ Get the user graph
       Arguments:
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
      Start a groundstation
      Arguments:
           cookie_jar  -- session id
           name  -- name of the groundstation (unique)
           loc  -- location of the groundstation (loc = [33.12,-118.23])
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
    except E.RequestException as e_e:
        return {"Error": e_e}


def gs_connect(cookie_jar, groundstation=None, sat=None):
    """
     Connect a groundstation to a satellite
      Arguments:
           cookie_jar     -- session id
           groundstation  -- groundstation
           satellite      -- satellite handle
    """

    # get the groundstation and sat info from the handle

    url_connect = URL + "gs/connect"
    if groundstation is None or sat is None:
        return {"Error": "groundstation or sat not specified"}

    # connection
    connect_data = {"gs": groundstation['name'], "sat": sat['name']}
    try:
        response = requests.post(url_connect,
                                 headers=headers,
                                 json=connect_data,
                                 cookies=cookie_jar)

        response = response_to_str(response)
        return response
    except E.RequestException as e_e:
        return {"Error": e_e}


def gs_connection_info(cookie_jar, groundstation=None):
    """ What connections does this groundstation have


    """
    url_gs = URL + "gs/info"
    if groundstation is None:
        return {"Error": "groundstation or sat not specified"}

    info = {"gs": groundstation['name']}
    try:
        response = requests.post(url_gs,
                                 headers=headers,
                                 json=info,
                                 cookies=cookie_jar,
                                 timeout=None)

        response = response_to_str(response)
        return response
    except E.RequestException as e_e:
        return {"Error": e_e}


def gs_sat_info(cookie_jar, groundstation=None):
    url_gs = URL + "gs/info/sat"
    if groundstation is None:
        return {"Error": "groundstation or sat not specified"}

    info = {"gs": groundstation['name']}
    try:
        response = requests.post(url_gs,
                                 headers=headers,
                                 json=info,
                                 cookies=cookie_jar,
                                 timeout=None)

        # response = response_to_str(response)
        return response
    except E.RequestException as e_e:
        return {"Error": e_e}


def get_sat_info(cookie_jar, sat_handle, info_type="position"):
    """
     Get information (location,velocity,battery) from the satellite object directly
     Arguments:
         cookie_jar   -- session id
         sat_handle   -- the satellite handle returned from the spawn command
         info_type    -- what type of info you want returned (e.g. position,battery,other)
    """

    url_sat = URL + "sat/info"
    info = {"sat_handle": sat_handle["name"], "info_type": info_type}
    try:
        response = requests.post(url_sat,
                                 headers=headers,
                                 json=info,
                                 cookies=cookie_jar,
                                 timeout=None)

        # response = response_to_str(response)
        return response
    except E.RequestException as e_e:
        return {"Error": e_e}


def sat_add_to_group(cookie_jar, sat_handle, group_name="default"):
    """
     Adds a satellite (sat_handle) to a "group". We can then "address"/send messages
     to all members of the group simulatenously. For example if we need
     to get sat position data from "starlink sats".  We would add
     each starlink sat to a group (e.g. starlink)
     Arguments:
         cookie_jar -- session id
         sat_handle -- handle from the spawn command
         group_name -- group name (string)
   """
    url_sat = URL + "sat/group"
    info = {"sat_handle": sat_handle["name"], "group_name": group_name}
    try:
        response = requests.post(url_sat,
                                 headers=headers,
                                 json=info,
                                 cookies=cookie_jar,
                                 timeout=None)

        response = response_to_str(response)
        return response
    except E.RequestException as e_e:
        return {"Error": e_e}


def sat_group_call(cookie_jar, group_name="default", type_info="position"):
    """
    Send every "sat" in the group a message
    Arguments
       cookie_jar -- session id
       group_name (str) - default value  == "default"
       type_info  -- type of message to send (default = position)
    """
    type_info = "position"
    url_sat = URL + "sat/group_call"
    info = {"group_name": group_name, "type_info": type_info}
    try:
        response = requests.post(url_sat,
                                 headers=headers,
                                 json=info,
                                 cookies=cookie_jar,
                                 timeout=None)

        return response
    except E.RequestException as e_e:
        return {"Error": e_e}


def create_topic(cookie_jar, topic_name, visible=1):
    """
    Create a topic/channel.
    Arguments
       cookie_jar -- session id
       topic_name -- topic to create
       visible    -- 0; not visible to other users
                     1; visible to all user s
    """

    url_topic_create = URL + "channel/create"
    info = {"topic": topic_name, "visible": visible}
    try:
        response = requests.post(url_topic_create,
                                 headers=headers,
                                 json=info,
                                 cookies=cookie_jar,
                                 timeout=None)

        return response.json()
    except E.RequestException as e_e:
        return {"Error": e_e}


def push_to_topic(cookie_jar, topic_handle, msg):
    """
    Push message to a topic/channel
    Arguments
       cookie_jar    -- session id
       topic_handle  -- output of the create_topic command
       msg           -- message to send (str)
    """
    url_topic_push = URL + "channel/push"
    info = {"topic": topic_handle['topic'], "msg": msg}
    try:
        response = requests.post(url_topic_push,
                                 headers=headers,
                                 json=info,
                                 cookies=cookie_jar,
                                 timeout=None)
        return response.json()
    except E.RequestException as e_e:
        return {"Error": e_e}


def list_topics(cookie_jar):
    """
     List topics
     Arguments:
        cookie_jar  -- session id
    """

    url_list_topic = URL + "channel/topics"
    try:
        response = requests.post(url_list_topic,
                                 headers=headers,
                                 json={},
                                 cookies=cookie_jar,
                                 timeout=None)
        return response.json()
    except E.RequestException as e_e:
        return {"Error": e_e}


def list_pcc_procs(cookie_jar, info_type, info_val=None):
    """
    PCC process commands
    Arguments:
        cookie_jar -- session id
        info_type  -- {key,whereis,members}
        info_val   -- {group_name,process id}
   """

    url_list_proc = URL + "swarm/info"
    try:
        info = {"key":info_type, "val": info_val}
        response = requests.post(url_list_proc,
                                 headers=headers,
                                 json=info,
                                 cookies=cookie_jar,
                                 timeout=None)

        return response.json()
    except E.RequestException as e_e:
        return {"Error": e_e}


if __name__ == '__main__':
    # c = create_user("nehalnehal@aero.org","foobar")
    user_cookie = sign_in("nehalnehal@aero.org", "foobar")
    topic_handle = create_topic(user_cookie, "testchannel")
    v = push_to_topic(user_cookie, topic_handle, "fasdfa")
    topics = list_topics(user_cookie)
    spawn_handle_45555 = spawn_proc(user_cookie, "generic", "45555", [], 0)
    spawn_handle_45394 = spawn_proc(user_cookie, "generic", "45394", [], 0)
    # gs_handle = spawn_groundstation(user_cookie, "gs2", loc=[1, 1])
    # gs_connect(user_cookie, gs_handle, spawn_handle_45555)
    # gs_connect(user_cookie, gs_handle, spawn_handle_45394)
    # gs_connect_response = gs_connection_info(user_cookie, gs_handle)
    # print(gs_connect_response)
    # response = gs_sat_info(user_cookie, gs_handle)
#   response =  sat_info(user_cookie,spawn_handle_45555)
# response =  sat_add_to_group(user_cookie,spawn_handle_45555)
# response =  sat_add_to_group(user_cookie,spawn_handle_45394)
# response =  sat_group_call(user_cookie)
# pdb.set_trace()
# print(response.json())
