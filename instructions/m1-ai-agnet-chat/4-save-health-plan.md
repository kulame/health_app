# 实现数据库保存健康计划函数

## 核心需求
1. 在AppDatabase中实现一个函数，用来保存指定天数的健康计划。
2. 输入参数为指定日期和健康计划内容。
3. 重构数据库的数据结构，去掉morningRoutine, exercises, meals字段，增加activities字段。只需要保存activities字段。

## 约束条件
1. 实现文件为 lib/data/database.dart
2. 指定日期数据结构为DateTime类型
3. 健康计划数据类型为List<ActivityItem>


## 实现细节
1. 在AppDatabase中实现一个函数，用来保存指定天数的健康计划。
2. 输入参数为指定日期和健康计划内容。
3. 健康计划数据类型为List<ActivityItem>
4. 指定日期数据结构为DateTime类型
5. 实现逻辑，将制定日期的健康计划保存到数据

## 参考文档
1. 参考文档 @reference https://drift.simonbinder.eu/dart_api/tables/#defining-tables

请一步一步的实现，并给出每一步的解释。

