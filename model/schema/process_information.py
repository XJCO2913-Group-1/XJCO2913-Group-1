from pydantic import BaseModel


class ProcessInformation(BaseModel):
    role: str
    readout: str
    role = None
    readout = None
