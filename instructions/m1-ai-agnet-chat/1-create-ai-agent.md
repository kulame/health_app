# task
修改ai智能体

## 要求
1. 需要读取用户当前的健康计划
2. 根据用户当前的健康计划和用户聊天内容，重新调整用户健康计划
3. 调整后的健康计划需要保存到数据库中 
4. ai总结自己调整的健康计划，并告知用户

## 约束条件
1. 代码保存在lib/services/gpt_service.dart

## 实现
1 @GptService  chat接口增加一个参数activites  类型是List<ActivityItem>  用来记录用户当前的健康计划。
2 修改相关调用chat接口的函数，传入activities。
3 chat函数将activities transform成字符串，一并传给chatgpt 让gpt可以获得用户当前计划的上下文
4 实现一个工具类 用来管理List<ActivityItem> 数据结构
5 实现一个同样参数的chat函数， 
逻辑和agent函数唯一的差异是，
只有单纯的对话逻辑
去掉调整健康计划的功能
去掉tool调用逻辑
6 参考chat函数 实现一个新的函数 chatWithModified
该函数需要额外增加一个参数 ，previousActivities 用来存储修改之前的健康计划
在和ai聊天的时候，需要把修改前和修改后的健康计划同时传入ai聊天上下文
ai在对比修改前和修改后的聊天记录的时候，给出修改原因，并将聊天结果返回