# Code Standards 强制 Chain of Thought 重构设计

## 背景

### 问题：LLM 为何会"知法犯法"

当前 code-standards 采用 progressive disclosure 结构组织规则，但 LLM 在应用这些规则时仍然会系统性违规，根本原因有两个：

**1. 注意力漂移（Attention Drift）**
大模型在处理长文本时，注意力分配不均。当 prompt 中同时包含大量代码、业务逻辑和一份 Checklist 时，LLM 在生成针对特定规则的审查意见时，注意力会更多聚焦在"代码本身"和"常规优化建议"上，对开头或结尾的关键规则注意力权重下降，导致"遗忘"。

**2. 预训练肌肉记忆（Pretraining Muscle Memory）**
LLM 在预训练阶段阅读了海量的开源代码。在 Go + GORM 场景中，使用 GORM tag 定义索引是绝大多数人的做法，这种海量数据训练出来的"肌肉记忆"权重极高。当看到 `type User struct` 且没有索引时，底层的概率模型会本能地倾向于生成"建议添加 gorm index tag"的补全，压倒了 prompt 中提供的局部规则。

### 当前结构的局限性

现有的 progressive disclosure 结构解决了"读取什么"的问题，但没有解决"如何确保规则被遵守"的问题。LLM 看到规则 ≠ LLM 执行规则。

## 设计目标

1. **对抗注意力漂移**：强制 LLM 在给出结论前先输出验证链，让规则检查过程可见
2. **对抗预训练肌肉记忆**：通过强制思维链，打破"看到代码就建议 GORM tag"的惯性思维
3. **零额外认知负担**：CoT 流程作为 Review 的标准操作步骤，不增加 LLM 的理解成本

## 解决方案概述

在 SKILL.md 入口定义一个**标准 Review 操作流程模板**（LLM-Review-Process），所有层级的代码审查都必须遵循此模板执行。

核心约束：**三步强制顺序** — Rule Localization → Inspection Process → Conclusion Output

---

## 模板格式：LLM-Review-Process

```markdown
## LLM Review 操作流程（强制）

在进行任何代码审查或给出修改建议前，必须按以下顺序执行：

### Step 1：规则定位
在开始审查前，先确认本次 Review 涉及的规则层级和具体条目。

本次 Review 涉及：
- 规则来源：[L1 / L2 / L3 / L4]
- 具体规则：[规则编号] [规则一句话描述]

### Step 2：检查过程
对每条涉及规则，逐条执行以下检查步骤：

规则 [编号]：[描述]
检查内容：
- [具体检查项1]：结果
- [具体检查项2]：结果
- [具体检查项3]：结果

### Step 3：结论输出
综合 Step 2 的检查结果，给出最终结论：

结论：[合规 / 不合规 / 需改进]
依据：[引用了哪些规则的哪些检查项]
建议：[如有，需基于 Step 2 的检查结果自然导出]
```

**强制要求**：
- 不得在未完成 Step 1-2 的情况下跳到 Step 3
- 结论必须直接源于 Step 2 的检查结果，不得引入 Step 2 未覆盖的新检查项
- 如 Review 过程中发现规则未涵盖的场景，在结论中注明"规则无覆盖，建议人工确认"

---

## 与现有 Progressive Disclosure 层级的整合

### L1 Minimal（10条铁律）

每条铁律前增加 `[@CoT-required]` 标注，表示该规则的审查必须触发完整三步流程：

```markdown
## [@CoT-required] 规则 9：gorm 字段显式 tag，只写 column

[规则内容...]

[@CoT-trigger]: 当审查 GORM model 定义时，此规则必须激活
```

**10条铁律的 CoT 标注**：

| 编号 | 规则 | CoT 要求 |
|------|------|---------|
| 1 | Backend 执掌所有业务逻辑 | [@CoT-required] |
| 2 | 函数命名用 Verb 前缀 | [@CoT-required] |
| 3 | 错误用 error 返回值 | [@CoT-required] |
| 4 | error 比较用 errors.Is() | [@CoT-required] |
| 5 | 用 struct 替代 map[string]interface{} | [@CoT-required] |
| 6 | 无 magic value，用常量替代 | [@CoT-required] |
| 7 | 无 go 关键字，用 goroutine.SafeGo | [@CoT-required] |
| 8 | Frontend 不做业务计算 | [@CoT-required] |
| 9 | gorm 字段显式 tag，只写 column | [@CoT-required] |
| 10 | 提交前 gofmt + go vet + revive | [@CoT-required] |

### L2 Common（日常开发规则）

各子章节（Naming, Error Handling, Database, Logging 等）的开头增加 CoT 强制说明：

```markdown
## 本章节使用说明

本章节规则审查**强制启用 CoT 流程**。
在 Review 本章节涉及的内容时，必须先执行 LLM-Review-Process 的 Step 1-2，
再给出 Step 3 的结论。
```

### L3 Advanced（复杂架构规则）

与 L2 相同的整合方式，在各子章节（DDD Architecture, Concurrency 等）开头增加 CoT 强制说明。

### L4 Reference（Checklists）

Checklist 页面本身作为 CoT 的 **Step 2 检查项清单** 使用，模板格式调整为：

```markdown
## [场景] Checklist

在开始审查前，先执行 LLM-Review-Process Step 1（规则定位），确认涉及本 Checklist 的哪些条目。
本 Checklist 的每一项对应 Step 2 的一个检查点。
```

---

## 文件改动清单

| 文件 | 改动类型 | 改动内容 |
|------|---------|---------|
| `code-standards/SKILL.md` | 修改 | 入口处新增「LLM Review 操作流程（强制）」section，作为所有 Review 场景的前置要求 |
| `code-standards/levels/L1_minimal.md` | 修改 | 每条铁律前增加 `[@CoT-required]` 标注 |
| `code-standards/levels/L2_common.md` | 修改 | 各子章节开头增加 CoT 强制说明 |
| `code-standards/levels/L3_advanced.md` | 修改 | 各子章节开头增加 CoT 强制说明 |
| `code-standards/levels/L4_reference.md` | 修改 | Checklist 页面增加模板引用和 Step 1 执行说明 |

---

## 预期效果

### LLM Review GORM 模型索引（Before/After）

**Before（当前行为）**：
```
建议在 email 字段上添加唯一索引：
```go
type User struct {
    Email string `gorm:"uniqueIndex"`
}
```

**After（强制 CoT 后）**：
```
本次 Review 涉及：
- 规则来源：L1
- 具体规则：[规则9] gorm 字段显式 tag，只写 column

规则 9 检查过程：
- 检查 GORM model 定义中是否有 index 相关 tag：发现 `gorm:"uniqueIndex"` tag
- 检查是否存在对应的 ddl.sql 索引定义：找到 ddl.sql 中无 EMAIL 唯一索引定义
- 对比规范要求：规范明确要求"索引必须且只能通过 ddl.sql 管理"

结论：不合规
依据：规则9，违反"gorm 字段只写 column，禁止 index tag"
建议：在 ddl.sql 中添加 EMAIL 唯一索引定义
```

### 效果对比

| 指标 | Before | After |
|------|--------|-------|
| 规则引用明确性 | 无 | 每步都引用具体规则编号 |
| 检查过程可见性 | 无 | Step 2 完整展示检查链路 |
| 肌肉记忆触发率 | 高（看到 model 就建议 tag） | 低（先执行检查，再导出结论） |
| 注意力漂移容忍度 | 低（长上下文中遗忘规则） | 高（每步都需完成规则定位） |

---

## 实施注意事项

1. **不引入新文件**：所有改动都在现有文件上修改，不创建新文件
2. **零丢失原则**：现有规则内容完全保留，仅增加 CoT 标注和强制说明
3. **渐进生效**：CoT 强制要求从 L1 开始，L2/L3/L4 逐步覆盖
4. **与 verifier skill 的关系**：verifier skill 的 adversarial testing 可以验证 CoT 流程是否被执行

---

## 待实施清单

- [ ] 在 `SKILL.md` 新增 LLM-Review-Process 模板
- [ ] 在 `L1_minimal.md` 的 10 条铁律前增加 `[@CoT-required]` 标注
- [ ] 在 `L2_common.md` 各子章节开头增加 CoT 强制说明
- [ ] 在 `L3_advanced.md` 各子章节开头增加 CoT 强制说明
- [ ] 在 `L4_reference.md` Checklist 页面增加模板引用说明
- [ ] 验证零丢失：对比新旧结构，确保所有现有规则完整保留
