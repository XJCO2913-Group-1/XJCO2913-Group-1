from chat_pipe import ChatPipe
from transform_input_to_total_information import TransformInputToTotalInformation
from get_answer_firstly import GetAnswerFirstly

pipeline=ChatPipe()
model=GetAnswerFirstly()
def chat_bot(Input):

    container = TransformInputToTotalInformation().process(Input)
    data=pipeline.process(data=container)
    if data.status==-1:
        return {"status":-1,"uid":data.uid,"cid":data.cid,"answer":data.get_result()}
    answer=model.process(data=data)
    print("-----------------")
    print(data)
    print("_________________")
    for i in answer:
        if data.status==-1:
            return {"status":-1,"uid":data.uid,"cid":data.cid,"answer":answer}
        yield {"status":1,"uid":data.uid,"cid":data.cid,"answer":i}
