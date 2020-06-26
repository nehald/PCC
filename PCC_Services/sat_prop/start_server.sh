#/bin/csh 
redis-server  --daemonize yes
source ~/vv/bin/activate
gunicorn --daemon --bind 0.0.0.0:5000 wsgi
python sat_utils.py  
