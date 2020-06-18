import ccore_test_api as cta
import pdb

user_cookie = cta.sign_in("nehal.desaix@aero.org", "foobar")
spawn_handle_45555 = cta.spawn_proc(user_cookie, "generic", "45555", [], 0)
pdb.set_trace()
cta.info_proc(user_cookie,spawn_handle_45555) 

