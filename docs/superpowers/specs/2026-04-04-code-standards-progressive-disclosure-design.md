# Code Standards 渐进式披露重构设计

## 背景

当前 code-standards 文档约 2500 行，采用线性结构一次性全部呈现。这导致：
- LLM 在简单任务下需要扫描全部内容才能找到相关规则
- 高频操作（日常 CRUD）没有得到优先级
- 上下文压力大，注意力稀释

## 设计目标

- **渐进式披露**：按任务复杂度分层，LLM 按需读取
- **零丢失**：所有现有规则完整保留，仅重新组织
- **LLM 优先**：简单任务用最小子集，复杂任务展开深层规则

---

## 层级结构

### Level 1: Minimal（10 条铁律）

**触发场景**：简单任务（CRUD 函数、单文件修改）
**呈现方式**：session 开始时默认可见

```
1. Backend 执掌所有业务逻辑，Frontend 只做展示
2. 函数命名用 Verb 前缀（如 GetUserByID）
3. 错误用 error 返回值，不用特殊值
4. error 不相等比较用 errors.Is()
5. 用 struct 替代 map[string]interface{}
6. 无 magic value，用常量替代
7. 无 go 关键字，用 goroutine.SafeGo
8. Frontend 不做业务计算，只接收后端预计算数据
9. gorm 字段显式 tag，只写 column
10. 提交前 gofmt + go vet + golangci-lint
```

### Level 2: Common（日常开发规则）

**触发场景**：日常功能开发（一个模块、一个 service）
**包含子集**：
- Naming & Formatting
- Error Handling
- Database Standards
- Logging
- Comments
- Guard Clauses

### Level 3: Advanced（复杂场景规则）

**触发场景**：复杂架构设计、并发、DDD
**包含子集**：
- DDD Architecture
- Goroutine & Concurrency
- Function Design
- Refactoring Principles

### Level 4: Reference（完整参考）

**触发场景**：按需展开
**包含子集**：
- All Checklists (Backend, Frontend, Security)
- Security Standards（完整内容）
- Performance Optimization
- Code Smells
- Tools

---

## 文件结构

```
code-standards/
├── SKILL.md              # 主入口（重写）
├── levels/
│   ├── L1_minimal.md    # 10 条铁律
│   ├── L2_common.md     # 日常规则
│   ├── L3_advanced.md   # 高级规则
│   └── L4_reference.md  # 完整 Checklists + Security
└── references/
    ├── code_examples.md  # 不变
    └── 01_foundations.md # 不变
    └── 02_guidelines.md  # 不变
```

---

## 迁移策略

1. **创建新文件结构**（不修改现有文件）
2. **内容重新分类**：所有现有内容按层级重新组织
3. **SKILL.md 改写**：主入口仅保留层级索引，实际内容在各 level 文件中
4. **零丢失验证**：确保每一条现有规则都能在新结构中找到对应位置

---

## 预期效果

| 场景 | 之前 | 之后 |
|------|------|------|
| 简单 CRUD | 扫描 2500 行 | 读取 L1（10 条） |
| 写一个 service | 扫描 2500 行 | 读取 L1+L2（约 40 条） |
| 设计 DDD 架构 | 扫描 2500 行 | 读取 L1+L2+L3（约 60 条） |
| Code review | 扫描 2500 行 | 按需展开 L4 Reference |

---

## 待实施清单

- [ ] 创建 `levels/` 目录结构
- [ ] 编写 `L1_minimal.md`（10 条铁律）
- [ ] 编写 `L2_common.md`（日常规则，从现有内容迁移）
- [ ] 编写 `L3_advanced.md`（高级规则，从现有内容迁移）
- [ ] 编写 `L4_reference.md`（Checklists + Security Standards）
- [ ] 重写 `SKILL.md` 为主入口（层级索引）
- [ ] 验证零丢失：对比新旧结构
