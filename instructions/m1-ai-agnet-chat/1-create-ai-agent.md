# task
你是一个ai agent 开发人员，请根据当前代码 @codebase  实现一个agent

## 核心能力
1. 将ai返回的健康计划，保存到数据库里

## 输入
1. Date: 当前日期，类型为Date
2. CurrentPlan: 当前健康计划，类型为json字符串
json结构为
{
      'type': 'object',
      'properties': {
        'activities': {
          'type': 'array',
          'items': {
            'type': 'object',
            'properties': {
              'title': {'type': 'string'},
              'time': {'type': 'string'},
              'kcal': {'type': 'string'},
              'type': {
                'type': 'string',
                'enum': ['activity', 'meal']
              },
              'mealItems': {
                'type': 'array',
                'items': {
                  'type': 'object',
                  'required': ['name', 'kcal'],
                  'properties': {
                    'name': {'type': 'string'},
                    'kcal': {'type': 'string'}
                  },
                  'additionalProperties': false
                }
              }
            },
            'required': ['title', 'time', 'kcal', 'type', 'mealItems'],
            'additionalProperties': false
          }
        }
      },
      'required': ['activities'],
      'additionalProperties': false
}


## 约束条件 
1. 代码保存在 lib/tools 目录里。
2. 需要检测入参的格式。
3. 需熬详细的文档。
4. 支持openai通过function calling 调用。


