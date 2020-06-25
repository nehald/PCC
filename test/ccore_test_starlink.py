import pcc_api as pcc
#import greenfield_api as ga  
import redis
import pdb

# get starlink sat from database


def get_starlink():

    r = redis.Redis()
    starlink_keys = [
        k.decode('utf-8') for k in r.keys() if 'STAR' in k.decode('utf-8')
    ]
    return (starlink_keys)


starlink = get_starlink()
## sign into Praire Common Core 
user_cookie = pcc.sign_in("nehal.desaix@aero.org", "foobar")
star_dict = {}
for s in starlink[0:200]:
    ## spawn a  satellite processes 
    temp_handle = pcc.spawn_proc(user_cookie, "generic", s, [], 0)
    ## add each sat to a group (collection of sats)
    pdb.set_trace()
    response = pcc.sat_add_to_group(user_cookie, temp_handle)



## start greenfield simulation 
simulation_server = "http://theshire.aero.org:3000"
#ga.start_sim()


## send a "position message" to the 
for i in range(0,100):
	starlink_positions = pcc.sat_group_call(user_cookie,info_type = "position")
	starlink_positions_json = starlink_positions.json()
	print(starlink_positions_json)
