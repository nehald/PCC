import pdb
import json
import requests
import numpy as np
from scipy.spatial import distance 

def los_to_earth(position, pointing):
    """Find the intersection of a pointing vector with the Earth

    Finds the intersection of a pointing vector u and starting point s with the WGS-84 geoid

    Args:
        position (np.array): length 3 array defining the starting point location(s) in meters
        pointing (np.array): length 3 array defining the pointing vector(s) (must be a unit vector)

    Returns:
        np.array: length 3 defining the point(s) of intersection with the surface of the Earth in meters
    """

    a = 6371008.7714
    b = 6371008.7714
    c = 6356752.314245
    x = position[0]
    y = position[1]
    z = position[2]
    u = pointing[0]
    v = pointing[1]
    w = pointing[2]
 
    pdb.set_trace()
    value = -a**2*b**2*w*z - a**2*c**2*v*y - b**2*c**2*u*x
    radical = a**2*b**2*w**2 + a**2*c**2*v**2 - a**2*v**2*z**2 + 2*a**2*v*w*y*z - a**2*w**2*y**2 + b**2*c**2*u**2 - b**2*u**2*z**2 + 2*b**2*u*w*x*z - b**2*w**2*x**2 - c**2*u**2*y**2 + 2*c**2*u*v*x*y - c**2*v**2*x**2
    magnitude = a**2*b**2*w**2 + a**2*c**2*v**2 + b**2*c**2*u**2

    if radical < 0:
        raise ValueError("The Line-of-Sight vector does not point toward the Earth")
    d = (value - a*b*c*np.sqrt(radical)) / magnitude

    if d < 0:
        raise ValueError("The Line-of-Sight vector does not point toward the Earth")

    return np.array([
        x + d * u,
        y + d * v,
        z + d * w,
    ])

pdb.set_trace()
val_45555 = requests.get("http://localhost:5000/sat/position/45555")
val_44760 = requests.get("http://localhost:5000/sat/position/44760")
l1=np.array(val_45555.json()['pos_eci'])
l2=np.array(val_44760.json()['pos_eci'])
v = (l1-l2)
n = np.linalg.norm(v)
v=v/n
for d in range(0,6000,10):
    l3=l2+d*v
    dist=distance.euclidean(l3,l1)
    if dist > dist_old:
        print(dist_old)
        sys.exit(-1) 	
    s="{0},{1},{2}".format(l3,l1,dist)
    print(s)
pdb.set_trace()
los_to_earth(l1,v)

