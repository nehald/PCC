import json
import pdb
from flask import request,Flask
app = Flask(__name__)
app.config["DBB_URL"] = "redis://localhost:6379/0"



def pos(name,idval,x,y):
    pos = {'y_m': y, 'x_m':x, 'z_m':z}
    ret = {name:id, "pos":pos}
    return ret 

@app.route('/')
def index():
    """
    Index
    """
    return "index"


@app.route('/callbackMetronome',methods=['PUT','GET','POST'])
def metronome():
    """
     Updating the TLE database using the Celestrak date
    """
    pdb.set_trace()
    print(request.data)



    
if __name__ == '__main__':
    app.run(host="0.0.0.0",debug=True,port=8080)
