import os
import time
import pdb
import copy
import json
import datetime
import redis
import requests
import astropy
from skyfield.api import load, EarthSatellite
# save formatted (from get_sat_data) celetrak


def current_time():
    return datetime.datetime.now().isoformat()


def _r(host="localhost", db=0, socket_timeout=10):
    """ Connect to redis
    Arguments:
        db -- redis database
        socket_time -- time to wait before redis connectios
                       times outs
    Return:
        redis connection
    """

    redis_db = None
    try:
        redis_db = redis.Redis(host, db=db, socket_timeout=socket_timeout)
        if redis_db.ping():
            return redis_db
    except:
        return "no redis server"
    return redis_db


def save_sat_data(filename="celestrak.txt", dbid=0):
    """
     Save the celestrak data to Redis.  We need
     to do for persistence
    """
    redis_db = _r(db=dbid)
    time = current_time()
    sat = open(filename).readlines()
    try:
        for i in range(0, len(sat), 3):
            _sat = sat[i].strip()
            redis_db.rpush('sat_list', _sat)
            line1 = sat[i + 1].strip()
            line2 = sat[i + 2].strip()
            noradid = line2.split()[1]
            sat_val = {
                "line1": str(line1),
                "line2": str(line2),
                "name": noradid,
                "last_update_time": time
            }
            noradid_val = {
                "line1": str(line1),
                "line2": str(line2),
                "name": _sat,
                "last_update_time": time
            }
            redis_db.hmset(str(_sat), sat_val)
            redis_db.hmset(str(noradid), noradid_val)
    except:
        pass
    return "Sat DB updated"


# get list of sats
def get_sat_list(dbid=0, by="name"):
    """
      Get list of sat
      Argument:
          dbid -- redis database
    """
    redis_db = _r(db=dbid)
    sat_list = [
        i.decode('utf-8') for i in redis_db.lrange("sat_list", 0, 1000)
    ]
    pdb.set_trace()
    return_dict = {}
    return_dict['sat_list'] = copy.copy(sat_list)
    return_json = json.dumps(return_dict)
    return return_json


# Download TLE dataset from Celestrak
# Reformat and save to file (default = celestrak.txt)


def get_sat_data(
        celestrak_url="https://celestrak.com/NORAD/elements/starlink.txt",
        default_name=None):
    """
       get_sat_data from celestrak website
       Argument:
           celestak_url -- url for the tle data
    """

    if default_name is None:
        default_name = "celestrak.txt"
    file_handle = open(default_name, "w")
    try:
        request = requests.get(celestrak_url)
        request_content = request.content.decode('utf-8').split("\r\n")
        for content in request_content:
            file_handle.write(content.strip() + "\n")
        file_handle.close()
        return (celestrak_url, default_name)
    except:
        return (celestrak_url, "no_file")


# get a SAT TLE
def get_sat_tle(satname, dbid=0):
    """
    Get the tle from a particular sat
    Arguments
        satname -- satellite name or NORAD id
    """
    redis_db = _r(db=dbid)
    line1 = redis_db.hmget(satname, keys="line1")[0].decode("utf-8")
    line2 = redis_db.hmget(satname, keys="line2")[0].decode("utf-8")
    return ((satname, line1, line2))


def sat_position(satname, dbid=0, ref="eci"):
    """
      Satellite position in eci and lat,lon
    """
    ## get sat
    since_last_update = (time.time() -
                         os.stat("celestrak.txt").st_ctime) / 3600.00
    ## if file is greater then 8 hrs. Get new tle file
    if since_last_update > 3600 * 8.0:
        _, name = get_sat_data()
        if "no_file" in name:
            return "error in celestrak file"
        dbid = save_sat_data()

    satname, line1, line2 = get_sat_tle(satname, dbid)
    ts = load.timescale(builtin=True)
    satellite = EarthSatellite(line1, line2, satname, ts)
    satellite_model = satellite.at(ts.now())
    position = satellite_model.position.km
    if ref == 'ecef':
        position = satellite_model.itrf_xyz().km

    ## get the subpoint
    subpoint = satellite_model.subpoint()
    lat = subpoint.latitude.degrees
    lon = subpoint.longitude.degrees
    return (position.tolist(), lat, lon)


if __name__ == '__main__':
    #get_sat_list()
    #pdb.set_trace()
    #url, filename = get_sat_data()
    #dbid = save_sat_data()
    pos, sat_lat, sat_lon = sat_position("45555")
    pos, sat_lat, sat_lon = sat_position("45555", ref="eci")
    pdb.set_trace()
    print(sat_lat, sat_lon)
