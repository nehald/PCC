import json
import pdb
import requests

class Greenfield:
    """ Greenfield class """
    def __init__(self):
        self.sim_url = "http://theshire.aero.org:3000/api/"
        self.callback_url = "http://howard.aero.org:8080/"
        self.start_payload = {
            "simRunning": True,
            "metronomePeriod_sec": 1.0,
            "numRxNodes": 3,
            "clienturlPhyTxBegin": "http://localhost:8000",
            "clienturlPhyRxBegin": "http://localhost:8000",
            "clienturlPhyRxEnd": "http://localhost:8000",
            "clienturlPhyRxDrop": "http://localhost:8000",
            "clienturlMacRx": "http://localhost:8000",
            "clienturlSockRx": self.callback_url + "callbackSockRx",
            "clienturlMetronome": self.callback_url + "callbackMetronome"
        }

        self.stop_payload = {"simRunning": False}
        self._start = json.dumps(self.start_payload)
        self._stop = json.dumps(self.stop_payload)
        self.header = {'content-type': 'application/json'}

    def set_callback_url(self, callback_url):
        """ Set the callback url
            Arguments
              callback_url
        """
        self.callback_url = callback_url
        self.start_payload['clienturlSockRx'] = callback_url
        self.start_payload['clienturlMetronome'] = callback_url

    def _request(self, data):
        response = requests.put(self.sim_url + "simulation",
                                headers=self.header,
                                data=data)
        return response.content

    def start(self):
        """ Start the simulation"""
        pdb.set_trace()
        req = self._request(self._start)
        return req

    def stop(self):
        """ Stop the simulation """
        req = self._request(self._stop)
        return req


if __name__ == '__main__':
    G = Greenfield()
    pdb.set_trace()
    print(G.stop())
