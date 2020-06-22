import ccore_test_api as cta
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
user_cookie = cta.sign_in("nehal.desaix@aero.org", "foobar")
star_dict = {}
for s in starlink[0:2]:
    temp_handle = cta.spawn_proc(user_cookie, "generic", s, [], 0)
    #response = cta.sat_info(user_cookie, temp_handle)
    response = cta.sat_add_to_group(user_cookie,temp_handle)
response = cta.sat_group_call(user_cookie)
rj=response.json()
pdb.set_trace()
