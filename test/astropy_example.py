from astropy import coordinates as coord
from astropy import units as u
from astropy.time import Time
import pdb
now = Time('2017-09-27 12:22:00')
# position of satellite in GCRS or J20000 ECI:
pdb.set_trace()
cartrep = coord.CartesianRepresentation(x=5713846.540659178, 
                                        y=3298890.8383577876,
                                        z=0., unit=u.m)
gcrs = coord.GCRS(cartrep, obstime=now)
itrs = gcrs.transform_to(coord.ITRS(obstime=now))
loc = coord.EarthLocation(*itrs.cartesian.cartrep )
print(loc.lat, loc.lon, loc.height)
