from typing import List
from schema.process_information import ProcessInformation


class TotalInformation(ProcessInformation):
    status: int = None
    uid: str = None
    cid: str = None
    query: str = None
    history_chat:List[str] = None
    process_data: List[ProcessInformation] = None

    def append(self, role: str, readout: str):
        if self.process_data is None:
            self.process_data = []
        self.process_data.append(ProcessInformation(role=role, readout=readout))


    def get_result(self):
        return self.process_data[-1].readout