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