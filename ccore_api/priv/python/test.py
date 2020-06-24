# import erlport modules and functions
from erlport.erlang import set_message_handler, cast
from erlport.erlterms import Atom
import Replay as R

MESSAGE_HANDLER = None  # reference to the elixir process to send result to


def cast_message(message):
    cast(MESSAGE_HANDLER, (Atom('python'), message))


def register_handler(pid):
    """
     Args:  pid
     Returns:  None
    """
    # save message handler pid
    global MESSAGE_HANDLER
    MESSAGE_HANDLER = pid


def handle_message(csvfile):
    """ 
	Args csvfile(str):  The csv file to playback
        Returns:  None
    """
    replay_class = R.Replay(csvfile, cast_message)
    replay_class.playback()


# set handle_message to receive all messages sent to this python instance
set_message_handler(handle_message)
