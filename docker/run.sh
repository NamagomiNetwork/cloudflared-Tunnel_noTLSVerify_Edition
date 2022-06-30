#!/bin/bash

set -e

# 変数が使えるか確認
if [ -z "$TUNNEL_NAME" ]; then
echo "変数 TUNNEL_NAME が指定されていないため起動を中断します"
exit 1
fi
if [ -z "$CLOUDFLARED_HOSTNAME" ]; then
echo "変数 CLOUDFLARED_HOSTNAME が指定されていないため起動を中断します"
exit 1
fi
if [ -z "$CLOUDFLARED_SERVICE" ]; then
echo "変数 CLOUDFLARED_SERVICE が指定されていないため起動を中断します"
exit 1
fi

cat <<EOF | tee /tmp/tunnel.yml
ingress:
  - hostname: $CLOUDFLARED_HOSTNAME
    service: $CLOUDFLARED_SERVICE
    originRequest:
      noTLSVerify: true
  - service: http_status:404
EOF

if [ -z "${TUNNEL_CERT}" ]; then TUNNEL_CERT="$HOME/.cloudflared/cert.pem"; fi
if [ ! -f "${TUNNEL_CERT}" ]; then
  echo "cert.pemが見つかりません。下記のURLを使用してログインしてください"
  cloudflared tunnel login
fi

# トンネルを作り直す
cloudflared tunnel delete -f "$TUNNEL_NAME" || true
cloudflared tunnel create "$TUNNEL_NAME"

list_tunnel () {
  cloudflared tunnel list --name "$TUNNEL_NAME" --output yaml
}

get_tunnel_id () {
  list_tunnel | yq eval '.[0].id' -
}

tunnel_uuid=$(get_tunnel_id)

yq e ".ingress.[] | select(.hostname != null) | .hostname" "/tmp/tunnel.yml" \
  | xargs -n 1 cloudflared tunnel route dns --overwrite-dns "$tunnel_uuid"

# 起動
cloudflared tunnel --config "/tmp/tunnel.yml" --no-autoupdate run "$tunnel_uuid"