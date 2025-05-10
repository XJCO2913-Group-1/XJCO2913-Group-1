from schema.total_information import TotalInformation


class ChatPipeline:
    def __init__(self):
        self.process_list: list
        self.process_list = None

    def process(self, data: TotalInformation) -> None:
        # 运行process_list中的类，改变data的值
        if self.process_list is not None:
            for processor in self.process_list:
                processor.process(data=data)
    def add_process(self, process_name) -> None:
        # 将不同的类放进process_list中。
        if self.process_list is None:
            self.process_list = []
        self.process_list.append(process_name)