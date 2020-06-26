
import pdb
import pcc_api as pcc
#import greenfield_api as ga  
import redis
import pydot
# get starlink sat from database


def get_starlink():

    r = redis.Redis()
    starlink_keys = [
        k.decode('utf-8') for k in r.keys() if 'STAR' in k.decode('utf-8')
    ]
    return (starlink_keys)

def make_graph(dot_data):
    pdb.set_trace()
    G = pydot.graph_from_dot_data(dot_data)
    G[0].write_pdf("graph1.pdf")
    return {"dotfile":"graph1.pdf"}


starlink = get_starlink()
##
## sign into Praire Common Core 
## 
user_cookie = pcc.sign_in("nehal.desaix@aero.org", "foobar")
star_dict = {}
s_handle = pcc.spawn_proc(user_cookie, "generic", starlink[0], [], 0)
graph_dot = pcc.graph_info(user_cookie)
pdb.set_trace()
for s in starlink[1:3]:
    ## spawn a  satellite processes 
    temp_handle = pcc.spawn_proc(user_cookie, "generic", s, [], 0)
    ## add each sat to a group (collection of sats)
    response = pcc.sat_add_to_group(user_cookie, temp_handle)
    ## add connections
    pcc.graph_add_edge(user_cookie,s_handle,temp_handle)  
    graph_dot = pcc.graph_info(user_cookie)
    make_graph(graph_dot)



## start greenfield simulation 
simulation_server = "http://theshire.aero.org:3000"
#ga.start_sim()


## send a "position message" to the 
#for i in range(0,3):
#	starlink_positions = pcc.sat_group_call(user_cookie,info_type = "position")
#	starlink_positions_json = starlink_positions.json()
#	print(starlink_positions_json)
