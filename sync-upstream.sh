#!/usr/bin/env bash
# =============================================================
#  同步上游代码 + 重建 gray 主题
#  用法: bash sync-upstream.sh
#  前提: 已经配置好 upstream(官方仓库) 和 origin(你自己的 fork)
# =============================================================
set -uo pipefail

echo "==> 1/3 拉取上游最新代码"
git fetch upstream || { echo "拉取失败，请检查网络或 upstream 配置"; exit 1; }

echo "==> 2/3 把你的修改 rebase 到上游最新代码"
if ! git rebase upstream/main; then
  echo ""
  echo "!!! 遇到冲突，需要你手动处理："
  echo "    1) 用编辑器打开有冲突的文件，找到 <<<<<<< 和 >>>>>>> 标记，保留正确内容"
  echo "    2) 处理完执行:  git add 冲突文件"
  echo "    3) 继续合并:    git rebase --continue"
  echo "    4) 想放弃本次同步: git rebase --abort"
  echo ""
  echo "    提示: resources/dist 下的 .css/.js 是编译产物，冲突时直接重建覆盖即可，不要手改："
  echo "          git checkout --theirs resources/dist && git add resources/dist"
  exit 1
fi

echo "==> 3/3 重建 gray 主题资源"
if [ ! -d node_modules ]; then
  echo "    (首次需要安装依赖，可能要几分钟)"
  npm install --no-audit --no-fund
fi
npm run prod:theme:gray

echo ""
echo "==> 同步完成。接下来："
echo "    如果上面重建后有文件变化，提交它们："
echo "        git add -A && git commit -m 'chore: 重建 gray 主题资源'"
echo "    推送到你自己的 fork："
echo "        git push origin main"