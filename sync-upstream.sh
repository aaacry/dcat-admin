#!/usr/bin/env bash
# =============================================================
#  同步上游代码 + 重建 gray 主题
#  用法: bash sync-upstream.sh
#
#  脚本会自动检测远程仓库配置：
#    - 没有 upstream（官方仓库）时，自动添加，无需手动操作
#    - 没有 origin（你自己的 fork）时，给出提示（因为不知道你的账号名）
# =============================================================
set -uo pipefail

UPSTREAM_URL="https://github.com/dcat-x/dcat-admin.git"

echo "==> 0/4 检查远程仓库配置"
if git remote | grep -qx 'upstream'; then
  echo "    ✓ upstream 已存在，跳过"
else
  echo "    + 未发现 upstream，自动添加：${UPSTREAM_URL}"
  git remote add upstream "$UPSTREAM_URL"
fi

if git remote | grep -qx 'origin'; then
  echo "    ✓ origin 已存在，跳过"
else
  echo "    ! 未发现 origin（你自己的 fork）。同步仍会继续，但最后无法推送。"
  echo "      之后请执行一次（把「你的账号」换成实际用户名）："
  echo "          git remote add origin https://github.com/你的账号/dcat-admin.git"
fi

echo "==> 1/4 拉取上游最新代码"
git fetch upstream || { echo "拉取失败，请检查网络"; exit 1; }

echo "==> 2/4 把你的修改 rebase 到上游最新代码"
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

echo "==> 3/4 重建 gray 主题资源"
if [ ! -d node_modules ]; then
  echo "    (首次需要安装依赖，可能要几分钟)"
  npm install --no-audit --no-fund
fi
npm run prod:theme:gray

echo "==> 4/4 完成检查"
echo ""
if git remote | grep -qx 'origin'; then
  echo "    同步完成。接下来："
  echo "      1) 如果有文件变化，提交它们："
  echo "           git add -A && git commit -m 'chore: 重建 gray 主题资源'"
  echo "      2) 推送到你自己的 fork："
  echo "           git push origin main"
else
  echo "    同步完成，但还没有 origin，无法推送。请先添加你的 fork："
  echo "        git remote add origin https://github.com/你的账号/dcat-admin.git"
  echo "    然后推送："
  echo "        git push -u origin main"
fi