
import time
import sys
# import erlport modules and functions
from erlport.erlang import set_message_handler, cast
from erlport.erlterms import Atom
import functools
message_handler = None  # reference to the elixir process to send result to
import Replay as R

def cast_message( message):
    cast(message_handler, (Atom('python'),message))


def register_handler(pid):
    # save message handler pid
    global message_handler
    message_handler = pid

def handle_message(csvfile):
    C = R.Replay(csvfile,cast_message) 
    C.playback() 

# set handle_message to receive all messages sent to this python instance
set_message_handler(handle_message)
