# cloudflared-Tunnel noTLSVerify Edition

このイメージはcloudflared tunnel を建てるイメージです

## ノーマル版との違い
このImageでは、自己証明書で保護されている場合などの場合 `noTLSVerify` フラグを使用して自己証明書による証明書エラーを無視します

## 設定してほしい変数

- `TUNNEL_NAME`
    - cloudflaredのトンネル名を指定してください
- `CLOUDFLARED_HOSTNAME`
    - ここにリモートドメイン(アクセスするドメイン)を入れてください
    - 例: `grafana.nabr2730.com`
- `CLOUDFLARED_SERVICE`
    - ローカルの接続先を指定してください
    - 例: `http://argocd-server.argocd` , `http://192.168.2.1`
