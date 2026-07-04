#!/bin/bash
REPO=~/Downloads/shopping
DL=~/Downloads
NEWEST=$(ls -t "$DL"/index*.html 2>/dev/null | head -1)
if [ -z "$NEWEST" ]; then
  echo "❌ No index*.html found in Downloads"
  exit 1
fi
echo "📄 Found: $NEWEST"
cp "$NEWEST" "$REPO/index.html"
BUILD=$(date +%s)
sed -i '' "s/__BUILD__/$BUILD/" "$REPO/index.html"
cd "$REPO"
git add index.html manifest.json icon.svg deploy.sh 2>/dev/null
git commit -m "Update shopping list $(date '+%H:%M') build $BUILD"
if [ $? -eq 0 ]; then
  git push
  echo ""
  echo "✅ Deployed build $BUILD! Refresh on iPhone in ~30 seconds."
else
  echo "⚠️  No changes to deploy (same file)."
fi
