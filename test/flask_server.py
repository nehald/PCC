import json
from flask import Flask
import sat_utils

application = Flask(__name__)
application.config["DBB_URL"] = "redis://localhost:6379/0"


@application.route('/')
def index():
    """
    Index
    """
    return "index"


@application.route('/sat/update_tle_db')
def update_tle_db():
    """
     Updating the TLE database using the Celestrak date
    """
    timestamp = sat_utils.current_time()
    _, filename = sat_utils.get_sat_data()
    return_str = sat_utils.save_sat_data(filename)
    return json.dumps({"time": timestamp, "return": return_str})


@application.route("/sat/position/<satid>")
def sat_position_eci(satid):
    """
     Get the position of the satellite
    """
    timestamp = sat_utils.current_time()
    pos, lat, lon = sat_utils.sat_position_eci(satid)
    sat_dict = {
        "time": timestamp,
        "satname": satid,
        "pos_eci": pos,
        "lat": lat,
        "lon": lon
    }
    return json.dumps(sat_dict)


if __name__ == '__main__':
    application.run(debug=True)
