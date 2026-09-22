#!/usr/bin/env bash
#
# req 技能仓库完整性校验
#
# 设计目标：把 CONTRIBUTING.md 里的「双版本同步规则」从"人眼看 diff 数差异块"
# 变成可执行断言。原有的自查方式不可机械验证——两个 SKILL.md 实际有 6 个差异块，
# 而文档只说了"四处"，靠人数必然对不上。
#
# 这里改用**内容特征归一化**：把允许不同的 6 行替换成占位符后再比对全文，
# 因此插入/删除无关行不会造成误报，只有"清单外的真差异"才会失败。
#
# 零依赖、零联网：只用 POSIX shell + diff/sed/grep/od。
# 用法：bash scripts/check-skill.sh
# 退出码：0 = 通过（可以有 WARN）；1 = 有 FAIL

set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

WB=skills/req-workbuddy/SKILL.md
OA=skills/req-openai/SKILL.md
WB_ICON=skills/req-workbuddy/assets/icon.svg
OA_ICON=skills/req-openai/assets/icon.svg

# 允许两版不同的位置（内容特征，不是行号）
ALLOWED_N=6
SZ_WARN=24000

FAIL=0
WARN=0
pass() { printf '  [ OK ] %s\n' "$1"; }
fail() { printf '  [FAIL] %s\n' "$1"; FAIL=$((FAIL + 1)); }
warn() { printf '  [WARN] %s\n' "$1"; WARN=$((WARN + 1)); }
head_() { printf '\n%s\n' "$1"; }

hashof() {
  if command -v md5sum >/dev/null 2>&1; then md5sum "$1" | cut -d' ' -f1
  else md5 -q "$1"; fi
}

# 取 YAML frontmatter 正文（首行 --- 与下一个 --- 之间）
fm() { awk 'NR==1{next} /^---$/{exit} {print}' "$1"; }

# 把允许不同的行归一化为同一占位符
normalize() {
  sed -E \
    -e 's/^description: .*/«DIFF-DESCRIPTION»/' \
    -e 's/^### 提问.*$/«DIFF-S3-HEADING»/' \
    -e 's/^(本宿主提供的原生结构化提问工具|宿主若提供原生结构化提问工具).*$/«DIFF-S3-BODY»/' \
    -e 's/^(参数规则（最终以工具自身定义为准）|宿主工具的参数规则（若与下表不同，以工具自身定义为准）).*$/«DIFF-S3-LEAD»/' \
    -e 's/^先展示完整简报，再用.*$/«DIFF-S8-CONFIRM»/' \
    -e 's/^- 本技能.*不宣称已切换到计划模式.*$/«DIFF-S9-MODE»/' \
    "$1"
}

# ─── 1. 必需文件 ───────────────────────────────────────────────
head_ '1. 必需文件'
for f in "$WB" "$OA" "$WB_ICON" "$OA_ICON" \
         skills/req-openai/agents/openai.yaml \
         README.md LICENSE CHANGELOG.md CONTRIBUTING.md; do
  if [ -f "$f" ]; then pass "$f"; else fail "$f 缺失"; fi
done

# ─── 2. frontmatter ────────────────────────────────────────────
head_ '2. SKILL.md frontmatter'
for f in "$WB" "$OA"; do
  if [ "$(sed -n '1p' "$f")" = '---' ]; then pass "$f 首行 ---"; else fail "$f 首行不是 ---"; fi
  if fm "$f" | grep -q '^name: req$'; then pass "$f  name: req"; else fail "$f 缺少 name: req"; fi
  if fm "$f" | grep -q '^description: .'; then pass "$f  description 非空"; else fail "$f 缺少 description"; fi
done

# ─── 3. 结构不变量 ─────────────────────────────────────────────
head_ '3. 结构不变量'
for f in "$WB" "$OA"; do
  n=$(grep -cE '^## [0-9]+\. ' "$f")
  if [ "$n" = '9' ]; then pass "$f 九个编号章节"; else fail "$f 编号章节数=$n（应为 9）"; fi

  n=$(sed -n '/^## 7\. /,/^## 8\. /p' "$f" | grep -c '^- \[ \]')
  if [ "$n" = '7' ]; then pass "$f §7 七条收口条件"; else fail "$f §7 勾选项=$n（应为 7）"; fi

  n=$(( $(sed -n '/^## 4\. /,/^## 5\. /p' "$f" | grep -cE '^\| [^ -]') - 1 ))
  if [ "$n" = '8' ]; then pass "$f §4 八个查漏视角"; else fail "$f §4 视角数=$n（应为 8）"; fi

  if grep -q '用户已确认／证据已核实／AI 建议／待决定／暂不做' "$f"; then
    pass "$f 五态决策记录措辞完整"
  else
    fail "$f 五态决策记录措辞被改动"
  fi

  if grep -q '直接标“待确认”' "$f"; then
    pass "$f 图示未知项使用源文件口径（待确认）"
  else
    fail "$f 图示未知项标记被改动（应为待确认）"
  fi
done

# ─── 4. 双版本同步规则（核心）──────────────────────────────────
head_ '4. 双版本同步规则'
nwb=$(normalize "$WB" | grep -c '«DIFF-')
noa=$(normalize "$OA" | grep -c '«DIFF-')
if [ "$nwb" = "$ALLOWED_N" ] && [ "$noa" = "$ALLOWED_N" ]; then
  pass "归一化命中 $ALLOWED_N 处允许差异（两版一致）"
else
  fail "归一化命中数 workbuddy=$nwb openai=$noa，应为 $ALLOWED_N/$ALLOWED_N —— 允许差异清单已过期"
fi

d=$(diff <(normalize "$WB") <(normalize "$OA") || true)
if [ -z "$d" ]; then
  pass '归一化后两版逐字一致（差异仅限清单内）'
else
  fail '归一化后仍有差异，即出现了清单外的改动：'
  printf '%s\n' "$d" | sed 's/^/         /'
fi

h1=$(hashof "$WB_ICON"); h2=$(hashof "$OA_ICON")
if [ "$h1" = "$h2" ]; then pass "两版 icon.svg 一致（$h1）"; else fail '两版 icon.svg 不一致'; fi

# ─── 5. 行尾必须为 LF ──────────────────────────────────────────
head_ '5. 行尾'
cr_files=''
while IFS= read -r f; do
  [ -f "$f" ] || continue
  # binary 宏包含 -text；二进制资源中的 0d 字节不是文本行尾。
  case "$(git check-attr text -- "$f" 2>/dev/null)" in
    *': text: unset') continue ;;
  esac
  n=$(od -An -v -tx1 "$f" | tr ' ' '\n' | grep -c '^0d$')
  [ "$n" != '0' ] && cr_files="$cr_files $f($n)"
done <<EOF
$(git ls-files 2>/dev/null || find . -type f -not -path './.git/*')
EOF
if [ -z "$cr_files" ]; then pass '所有入库文本文件均为 LF（无 CR 字节）'; else fail "文本文件存在 CR 字节：$cr_files"; fi

# ─── 6. 技能正文不得含个人信息 / 本机路径 ──────────────────────
head_ '6. 技能正文卫生'
leak=0
for pat in '老大' 'Cunzhang' 'C:\\' 'D:\\' '/Users/' 'C:/' 'D:/'; do
  if grep -q -- "$pat" "$WB" "$OA" 2>/dev/null; then
    fail "SKILL.md 含疑似个人信息或本机路径：$pat"; leak=1
  fi
done
[ "$leak" = '0' ] && pass '两个 SKILL.md 均无称呼、作者名与本机路径'

# ─── 7. 体积守门（技能每次调用都会载入全文）───────────────────
head_ '7. 体积（上下文成本）'
for f in "$WB" "$OA"; do
  b=$(wc -c < "$f" | tr -d ' ')
  if [ "$b" -gt "$SZ_WARN" ]; then
    warn "$f ${b} 字节，超过软上限 $SZ_WARN —— 技能每次调用都会载入全文，注意上下文成本"
  else
    pass "$f ${b} 字节（软上限 $SZ_WARN）"
  fi
done

# ─── 8. CHANGELOG ─────────────────────────────────────────────
head_ '8. CHANGELOG'
if grep -qE '^## \[[0-9]+\.[0-9]+\.[0-9]+\]' CHANGELOG.md; then pass '存在版本段'; else fail 'CHANGELOG 缺少版本段'; fi
if grep -q '^## \[未发布\]' CHANGELOG.md; then pass '存在 [未发布] 段'; else warn '缺少 [未发布] 段'; fi

# ─── 汇总 ──────────────────────────────────────────────────────
printf '\n──────────────────────────────\n'
printf 'FAIL=%d  WARN=%d\n' "$FAIL" "$WARN"
if [ "$FAIL" -eq 0 ]; then printf '结果：通过\n'; exit 0; fi
printf '结果：不通过\n'; exit 1
