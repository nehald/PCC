import pcc_api as pcc 
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
user_cookie = pcc.sign_in("nehal.desaix@aero.org", "foobar")
star_dict = {}
for s in starlink[0:2]:
    temp_handle = pcc.spawn_proc(user_cookie, "generic", s, [], 0)
    #response = pcc.sat_info(user_cookie, temp_handle)
    response = pcc.sat_add_to_group(user_cookie,temp_handle)
response = pcc.sat_group_call(user_cookie)
print(response)
pdb.set_trace()
