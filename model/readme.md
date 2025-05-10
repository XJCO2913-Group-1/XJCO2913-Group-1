# 目的

实现课程作业中的客服功能

# 接口

**接口地址**: `http://119.45.26.22:3389/qwen`

**请求方式**: `POST`

**Content-Type**: `application/json`

**返回类型**: `text/event-stream` (支持流式返回)

| 参数名         | 类型   | 说明                     |
| -------------- | ------ | ------------------------ |
| `uid`          | string | 用户 ID                  |
| `cid`          | string | 会话 ID                  |
| `status`       | int    | 状态码（固定为 0）       |
| `query`        | string | 用户提问内容             |
| `history_chat` | list   | 聊天历史（此处为空列表） |



history_chat是历史对话，按照一问一答的形式排列。长度应该为偶数。

例如：

用户：你好

AI：你好

用户:你是谁

AI：我是AI

那么

```
history_chat=["你好","你好","你是谁","我是AI"]
```

按照最新传入最后10条历史对话记录，建议这个作为config设置。





query是当前提问：

用户：你好

AI：你好

用户:你是谁

AI：我是AI

用户：”哦“



那么”哦“就是当前提问

```
query=”哦“
```



## 返回(流式)

```
{
"status":int,
"uid":str,
"cid":str,
"answer":str
}
```

实际返回：

```
data:{"status":int,"uid":str,"cid":str,"answer":str}\n\n
```

