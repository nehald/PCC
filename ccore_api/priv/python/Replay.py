import pdb
import simpy
import json
import pandas as pd

class Replay():
    def __init__(self,
                 csvfile,
                 send_msg=None,
                 time_factor=1.0,
                 time_column_header="time"):

        df = pd.read_csv(csvfile)
        columns = [c.lower() for c in df.columns]
        has_time_column = time_column_header in columns
        if has_time_column == False:
            print("no time column")
        else:
            self.df = df
            self.time_diff = df[time_column_header].diff()
            self.time_factor = time_factor
            self.csv_file = csvfile
            self.send_msg = send_msg
        # setup simpy env
        env = simpy.rt.RealtimeEnvironment(factor=time_factor)
        self.env = env

    def std_print(self, msg):
        print(msg)

    def _replay(self):
        env = self.env
        if self.send_msg is not None:
            send_msg = self.send_msg
        else:
            send_msg = self.std_print

        time_diff = self.time_diff[1:]
        for index, delta_t in enumerate(time_diff):
            try:
                x = self.df.iloc[index]
                xx = x.to_json()
                print(xx)
                # send_msg("jjj")
                # send_msg(message=self.df.iloc[index])
                yield env.timeout(delta_t)
            except:
                pass

    def playback(self, time_factor=1):
        env = self.env
        proc = env.process(self._replay())
        env.run(until=proc)


# if __name__ =='__main__':
#    C = Replay("/tmp/test.csv")
#    C.playback()
